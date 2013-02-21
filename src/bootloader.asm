; Copyright (C) 2013  Bryant Moscon - bmoscon@gmail.com
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to 
; deal in the Software without restriction, including without limitation the 
; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
; sell copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; 1. Redistributions of source code must retain the above copyright notice, 
; this list of conditions, and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice, 
; this list of conditions and the following disclaimer in the documentation 
; and/or other materials provided with the distribution, and in the same 
; place and form as other copyright, license and disclaimer information.
;
; 3. The end-user documentation included with the redistribution, if any, must 
; include the following acknowledgment: "This product includes software 
; developed by Bryant Moscon (http://www.bryantmoscon.org/)", in the same 
; place and form as other third-party acknowledgments. Alternately, this 
; acknowledgment may appear in the software itself, in the same form and 
; location as other such third-party acknowledgments.
;
; 4. Except as contained in this notice, the name of the author, Bryant Moscon,
; shall not be used in advertising or otherwise to promote the sale, use or 
; other dealings in this Software without prior written authorization from 
; the author.
;
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
; THE SOFTWARE
	
BITS 16
	
start:
	cli
	mov ax, 0x07C0		; set DS to the correct data segment (bios loads us to 07C0:0000)
	mov ds, ax
	mov ss, ax
	mov sp, start
	
	mov si, loading_string	; load string address into SI
	call print
	call x64_check           
	jc .not_supported
	mov si, yes_64_mode
	call print

	jmp $			; todo: add code here

.not_supported:
	mov si, no_64_mode
	call print
	hlt
	jmp $	

	;; Steps to determine if 64bit mode is supported:
	;; 1. check if CPUID is a supported instruction. This is done
	;;    by checking if we can set/clear bit 21 in EFLAGS
	;; 2. if we have CPUID, we have to check if extension 0x80000001 is supported.
	;;    this can be done by calling with extension 0x80000000.
	;; 3. if we have the extension, we can call CPUID with that extension and check
	;;    bit 29 in EDX
x64_check:
	pushfd 			; push EFLAGS onto stack
	
	pop eax                 ; pop them into EAX
	or eax, 0x200000        ; set bit 21
	push eax                ; push eax and then pop it into EFLAGS
	popfd                   
	pushfd                 	; push the flags and then pop them into eax
	pop eax
	and eax, 0x200000       ; check and see if bit 21 is set
	shr eax, 21 
	and eax, 1              
	
	test eax, eax           ; is eax is 1 CPUID is supported
	jz .error
 
	mov eax, 0x80000000   	; check if CPUID extensions are supported
	cpuid                   ; (everything from P4 on supports them)
 
	cmp eax, 0x80000001     ; make sure value we get back is at least 0x80000001
	jb .error               
 
	mov eax, 0x80000001	; if we support it, check bit 29 in EDX
	cpuid
        shr edx, 29
	and edx, 1
	test edx, edx
	jz .error
 
	ret
 
.error:
	stc
	ret	

print:				; Print routine (EH mode of int10. char goes into AL)
	mov ah, 0Eh		

.repeat:
	lodsb			; Get char from DS:SI and stick in AL
	or  al, al              ; is char a zero (i..e end of string)?
	jz .done		; if AL is zero, we're done
	int 10h			
	jmp .repeat             ; loop til string is printed

.done:
	ret

loading_string db "Loading MarmotOS...", 0x0A, 0x0D, 0
no_64_mode db "Error: CPU does not support 64 bit mode", 0x0A, 0x0D, 0
yes_64_mode db "64 bit support detected", 0x0A, 0x0D, 0
	
	; place the 0xAA55 signature at end of 512 byte boot sector.
TIMES 	510-($-$$) DB 0 	; Unfortunately, NASM != MASM 
	DW 0xAA55		; so we cannot ORG 510 this...