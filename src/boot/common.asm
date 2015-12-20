; Copyright (C) 2013-2015  Bryant Moscon - bmoscon@gmail.com
; 
; Please see the LICENSE file for the terms and conditions associated with
; the use of this software
;
 
BITS 16

print:                 ; Print routine (0x0E mode of int10. char goes into AL)
        mov ah, 0x0E

.repeat:
        lodsb          ; Get char from DS:SI and stick in AL
        or  al, al     ; is char a zero (i..e end of string)?
        jz .done       ; if AL is zero, we're done
        int 0x10
        jmp .repeat    ; loop til string is printed

.done:
        ret

