; ============================================================
; Задание 2, вариант 1: косинус между векторами
; Скалярные SSE-инструкции (суффикс SS).
; a = {1, 2, 3, 4},  b = {4, 3, 2, 1}
; ============================================================

default rel
%include 'io64.inc'
extern printf

section .rodata
    fmt:    db "scalar: cos = %.6f", 10, 0

    align 16
    a:      dd 1.0, 2.0, 3.0, 4.0
    b:      dd 4.0, 3.0, 2.0, 1.0

section .bss
    cos_res: resd 1

section .text
global main

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32                ; выравнивание стека

    ; ---- dot = a0*b0 + a1*b1 + a2*b2 + a3*b3 ----
    movss   xmm0, [a]
    mulss   xmm0, [b]
    movss   xmm1, [a+4]
    mulss   xmm1, [b+4]
    addss   xmm0, xmm1
    movss   xmm1, [a+8]
    mulss   xmm1, [b+8]
    addss   xmm0, xmm1
    movss   xmm1, [a+12]
    mulss   xmm1, [b+12]
    addss   xmm0, xmm1             ; xmm0 = dot

    ; ---- |a|^2 ----
    movss   xmm1, [a]
    mulss   xmm1, xmm1
    movss   xmm2, [a+4]
    mulss   xmm2, xmm2
    addss   xmm1, xmm2
    movss   xmm2, [a+8]
    mulss   xmm2, xmm2
    addss   xmm1, xmm2
    movss   xmm2, [a+12]
    mulss   xmm2, xmm2
    addss   xmm1, xmm2             ; xmm1 = |a|^2

    ; ---- |b|^2 ----
    movss   xmm2, [b]
    mulss   xmm2, xmm2
    movss   xmm3, [b+4]
    mulss   xmm3, xmm3
    addss   xmm2, xmm3
    movss   xmm3, [b+8]
    mulss   xmm3, xmm3
    addss   xmm2, xmm3
    movss   xmm3, [b+12]
    mulss   xmm3, xmm3
    addss   xmm2, xmm3             ; xmm2 = |b|^2

    ; ---- cos = dot / sqrt(|a|^2 * |b|^2) ----
    mulss   xmm1, xmm2
    sqrtss  xmm1, xmm1
    divss   xmm0, xmm1

    movss   [cos_res], xmm0

    ; ---- printf ----
    cvtss2sd xmm0, [cos_res]
    lea     rdi, [fmt]
    mov     eax, 1

    xor     eax, eax
    leave
    ret