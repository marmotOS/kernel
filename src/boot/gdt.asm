; Copyright (C) 2016  Bryant Moscon - bmoscon@gmail.com
; 
; Please see the LICENSE file for the terms and conditions associated with
; the use of this software
;


BITS 16

gdt:	
	;; NULL descriptor
	.null: equ $ - gdt
	dq 0x0

	.code: equ $ - gdt
	dw 0x0			 ; lower limit
	dw 0x0                   ; lower base
	db 0x0                   ; middle base
	db 10011010b             ; code seg, so read/execute access
	db 00100000b             ; granularity
	db 0x0                   ; upper base
	.data: equ $ - gdt
	dw 0x0
	dw 0x0
	db 0x0
	db 10010010b             ; data seg, so read/write access
	db 00000000b
	db 0x0
        .ptr:
	dw $ - gdt - 1
	dq gdt
	
	
	
