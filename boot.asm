[org 0x7c00]

mov ah,0x0E
mov bx,msg

printLoop:
    mov al, [bx]
    cmp al, 0
    je end
    int 0x10
    inc bx
    jmp printLoop
end:

KERNEL_LOCATION equ 0x1000

mov [BOOT_DISK], dl

xor ax, ax
mov es, ax
mov ds, ax
mov bp, 0x8000
mov sp, bp

mov bx, KERNEL_LOCATION
mov dh, 2

mov ah, 0x02
mov al, dh
mov ch, 0x00
mov dh, 0x00
mov cl, 0x02
mov dl, [BOOT_DISK]
int 0x13

mov ah, 0x0
mov al, 0x3
int 0x10

CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start

cli
lgdt [GDT_Descriptor]
mov eax, cr0
or eax,1
mov cr0,eax ; NOW IN PM
jmp CODE_SEG:start_protected_mode

jmp $

BOOT_DISK: db 0

GDT_Start:
	null_descriptor: ;empty descriptor required
		dd 0
		dd 0
	code_descriptor: ;confusing!! must be in this exact format
		dw 0xffff ;first 16 bits of limit
		dw 0 ;first 16 bits of the base
		db 0 ;next 8 bits of the base
		db 0b10011010 ;pres,priv,type,type flags
		db 0b11001111 ;other flags, last four bits of limit
		db 0 ;last 8 bits of base
	data_descriptor: ;confusing!! must be in this exact format
		dw 0xffff ;first 16 bits of limit
		dw 0 ;first 16 bits of the base
		db 0 ;next 8 bits of the base
		db 0b10010010 ;pres,priv,type,type flags
		db 0b11001111 ;other flags, last four bits of limit
		db 0 ;last 8 bits of base
GDT_End:

GDT_Descriptor:
    dw GDT_End - GDT_Start - 1 ;size
    dd GDT_Start ;start

[bits 32]
start_protected_mode:
    ; PM mode
    ; videoMemory starts at 0xb800
    ; byte 1 = character, byte 2 = colour
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    jmp KERNEL_LOCATION

msg: db "Hello, world! -from Real mode",0

times 510-($-$$) db 0
db 0x55, 0xAA
