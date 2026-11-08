; ============================================================
; Задание 2, вариант 2: косинус между векторами
; Векторные SSE-инструкции (packed).
; a = {1, 2, 3, 4},  b = {4, 3, 2, 1}
; ============================================================

default rel
%include 'io64.inc'
extern printf

section .rodata
    fmt:    db "vector: cos = %.6f", 10, 0

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
    sub     rsp, 32

    ; ---- dot: mulps + 2×haddps ----
    movaps  xmm0, [a]              ; {a0,a1,a2,a3}
    movaps  xmm1, [b]              ; {b0,b1,b2,b3}
    mulps   xmm0, xmm1             ; {a0b0, a1b1, a2b2, a3b3}
    haddps  xmm0, xmm0             ; [x0+x1, x2+x3, x0+x1, x2+x3]
    haddps  xmm0, xmm0             ; [dot, ...]

    ; ---- |a|^2 ----
    movaps  xmm1, [a]
    mulps   xmm1, xmm1
    haddps  xmm1, xmm1
    haddps  xmm1, xmm1             ; xmm1[0] = |a|^2

    ; ---- |b|^2 ----
    movaps  xmm2, [b]
    mulps   xmm2, xmm2
    haddps  xmm2, xmm2
    haddps  xmm2, xmm2             ; xmm2[0] = |b|^2

    ; ---- cos ----
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