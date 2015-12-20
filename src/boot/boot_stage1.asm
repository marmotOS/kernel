; Copyright (C) 2013-2015  Bryant Moscon - bmoscon@gmail.com
; 
; Please see the LICENSE file for the terms and conditions associated with
; the use of this software
;
	
BITS 16
ORG 0x0


;; BIOS Parameter Block (BPB)
dw 0x3CEB       ; a short jmp to end of BPB (remember Intel is little endian) 
db 0x90         ; no op
db "        "   ; 8 byte OEM ID - not used per FAT spec
dw 0x200        ; bytes per sector
db 0x01         ; sectors per cluster
dw 0x01         ; number of reserver sectors
db 0x02         ; number of file allocation tables on media
dw 0xE0         ; number of directory entries
; 1.44 MB double sided floppies have 2 heads, 80 tracks per head, 
; 18 sectors per track, and 512 bytes per sector.
dw 0xB40        ; number of sectors (if zero, value is stored in last double world)
db 0xF0         ; media descriptor type - 0xF0 for Floppy, 0xF8 for hard disk
dw 0x9          ; sectors per allocation table
dw 0x12         ; sectors per track
dw 0x2          ; number of heads or sides
dd 0x0          ; number of hidden sectors (i.e. LBA)
dd 0x0          ; large number of sectors (if number of sectors word is set to 0)

;; Extended Boot Record
db 0x0           ; drive number, not used, get from DL
db 0x0           ; reserved
db 0x29          ; extended signature
dd 0x0           ; volume ID
db "           " ; volume label string
db "        "    ; system ID, FAT spec says to ignore  
	
start:
	cli
	mov ax, 0x07C0		; set DS to the correct data segment (bios loads us to 07C0:0000)
	mov ds, ax
	mov ss, ax
	mov sp, start
        sti
        mov [drive_number], dl  ; save off drive number since 64bit check will clobber it	
	mov si, loading_string	; load string address into SI
	call print
	call x64_check         ; check if CPU supports 64bit
	jc .not_supported
	mov si, yes_64_mode
	call print
        call stage2    ; load 2nd state of bootloader into memory from disk


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
	
	test eax, eax           ; if eax is 1, then CPUID is supported
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

stage2:
	;; since the sector thats been loaded by the bios is only 512 bytes, 
	;; we need to load a 2nd stage bootloader into memory from disk, and jump 
	;; to the new stage, which will be responsible for the bulk of the setup and 
	;; initialization before loading the kernel
	;;
	;; 1. reset floppy controller
        ;; 2. read sectors into memory from the disk
        ;; 3. jump to 2nd stage

        xor ax,ax
	mov dl, [drive_number]
	int 0x13                  ; AH = 0, reset drive
        jc .bad_boot 
        mov ah, 0x2               ; AH = 2, read sectors from drive number in DL
	mov al, 0x2               ; AL = num sectors to read
	xor ch,ch                 ; CH = cylinder
	mov cl, 0x2               ; CL = sector note that sectors start at 1, there is no 0th sector
	xor dh,dh                 ; DH = head
	mov bx, 0x100             ; ES:BX points to the location we are writing to
	mov es, bx                ; in this case, its 0x100:0 (or 0x1000 in a flat address space)
	xor bx, bx                
	int 0x13
	jc .bad_boot
	jmp 0x100:0x0 	          ; jump to 2nd stage

.bad_boot:
	mov si, bad_boot
	call print
	hlt
	jmp $


%include 'common.asm'
	
loading_string     db "Loading MarmotOS...", 0x0A, 0x0D, 0
no_64_mode         db "Error: CPU does not support 64 bit mode", 0x0A, 0x0D, 0
yes_64_mode        db "64 bit support detected", 0x0A, 0x0D, 0
bad_boot           db "Error: unable to boot from disk", 0x0A, 0x0D, 0
drive_number       db 0x0 ; DL is set to the current drive at power on
	
;; place the 0xAA55 signature at end of 512 byte boot sector.
TIMES 	510-($-$$) DB 0	
                   DW 0xAA55		
