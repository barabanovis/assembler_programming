; ============================================================
; Задание 2, Средний уровень (вариант 2).
; Обход access2 с использованием точных констант (3.0f, 1.0f, 1.0 double)
; ============================================================

BITS 64

section .data
    align 16
    ; Структура S (16 байт)
    s_struct:
        dd 0                ; [rdx+0]   int field0 = 0
        dd 10               ; [rdx+4]   int field4 = 10 (val2 = 3*0 + 10 - 1 = 9)
        dd 0.0              ; [rdx+8]   float field8 = 0.0
        dd 0.0              ; [rdx+0Ch] float field12 = 0.0

    ; Первый аргумент 'a' делаем нулем (val1 = 0)
    val_a: dd 0.0

    ; Значение для xmm2 (тип double, строго больше 1.0)
    val_double: dq 2.0

section .text
global main

extern access2

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32        ; Shadow space

    ; 1-й аргумент: float a -> в XMM0
    movss xmm0, [val_a]
    
    ; 2-й аргумент: int b -> в RCX
    xor  ecx, ecx       
    
    ; 3-й аргумент: const S& s -> в RDX
    lea  rdx, [s_struct]

    ; ВАЖНО: загружаем в XMM2 64-битное double (2.0), чтобы пройти comisd
    movsd xmm2, [val_double]

    ; Вызов функции
    call access2

    ; Эпилог
    add  rsp, 32
    leave
    ret