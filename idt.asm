[bits 32]

global i686_IDT_Load
i686_IDT_Load:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    lidt [eax]
    mov esp,ebp
    mov ebp
    ret