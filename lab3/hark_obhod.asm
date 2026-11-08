; ============================================================
; Задание 2, СЛОЖНЫЙ уровень (вариант 1).
; Вызов access1 из библиотеки hard.a
; ============================================================

BITS 64

section .data
    align 16
    ; Структура S (передается по ссылке)
    ; S[0] = 0xFE, S[1] = 0, остальные нули.
    s_struct:
        db 0xFE, 0, 0, 0, 0, 0, 0, 0

    ; Класс C (передается по значению в ECX)
    ; C = 1, так как ~0xFE == 1
    c_val: dd 1

section .text
global main

extern access1

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32        ; Shadow space

    ; 1-й аргумент (C) -> в ECX
    mov  ecx, [c_val]
    
    ; 2-й аргумент (S) -> в RDX (передаем АДРЕС структуры)
    lea  rdx, [s_struct]

    ; Вызов функции
    call access1

    ; Эпилог
    add  rsp, 32
    leave
    ret