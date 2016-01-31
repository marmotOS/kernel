; Copyright (C) 2013-2016  Bryant Moscon - bmoscon@gmail.com
; 
; Please see the LICENSE file for the terms and conditions associated with
; the use of this software
;

BITS 16

start:
        mov ax, 0x100
	mov ds, ax
	mov ax, 0x200
	mov ss, ax
	xor sp, sp
	mov si, stage_2	
	call print
        hlt 
        jmp $
	;; todo
	;; * load 64bit kernel to well known address
        ;; * setup page table
        ;; * setup IDT (interrupt descriptor table)
        ;; * enable long mode directly
	mov eax, 10100000b	; set physical address extension and page global enabled bits in CR4
	mov cr4, eax
	mov edx, edi            ; set Page Map Level 4
	mov cr3, edx            
	mov ecx, 0xC0000080     ; set up to read Extended Feature Enable Register
	rdmsr
	or eax, 0x00000100      ; Long mode enable bit set
	wrmsr
	mov ebx, cr0            ; enable long mode directly by setting up paging and mem protection
	or ebx,0x80000001
	mov cr0, ebx
        ;; * Setup Global Descriptor Table (GDT)
	lgdt [gdt.ptr]
        ;; * jump to 64bit kernel at well known address
	
	
%include 'common.asm'
%include 'gdt.asm'	

stage_2 db "Stage 2 loaded", 0x0A, 0x0D, 0




TIMES 	1024-($-$$) DB 0

