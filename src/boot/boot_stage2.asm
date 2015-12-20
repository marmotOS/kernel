; Copyright (C) 2013-2015  Bryant Moscon - bmoscon@gmail.com
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
        ;; * Setup Global Descriptor Table (GDT)
        ;; * enable long mode
        ;; * jump to 64bit kernel at well known address
        
%include 'common.asm'	

stage_2 db "Stage 2 loaded", 0x0A, 0x0D, 0




TIMES 	1024-($-$$) DB 0

