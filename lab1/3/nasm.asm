%include "io64.inc"
section .bss
buffer: resb 65
section .text
global main
main:
 ; Переменные:
 ; EAX - string
 ; EDI - shift

    lea rdi, [buf]
.read:
    GET_CHAR eax
    cmp al, 10                    ; Enter
    je .read_done
    mov [rdi], al
    inc rdi
    jmp .read

.read_done:
    mov byte [rdi], 0

GET_UDEC 4, eax

ret