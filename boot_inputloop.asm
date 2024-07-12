[org 0x7c00]

loop:
    mov ah, 0
    int 0x16

    call comp
    jmp loop

comp:
    mov bl,al

    cmp al,0xD
    je eq

    mov ah, 0x0E
    mov al,bl
    int 0x10
    ret
eq:
    mov ah, 0x0E
    mov al, 0xD
    int 0x10

    mov ah, 0x0E
    mov al, 0xA
    int 0x10
    ret

times 510-($-$$) db 0
db 0x55, 0xAA