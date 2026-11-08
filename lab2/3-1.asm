; ============================================================
; Задание 3, п.1: решить cos(lg(x - a)) = b
; a = 1.0, b = 0.5
;
; Решение: x = a + 10^(±arccos(b))
;   x1 = a + 10^( arccos(b))
;   x2 = a + 10^(-arccos(b))
; ============================================================

default rel
%include 'io64.inc'
extern printf

section .rodata
    fmt_x1: db "x1 = %.6f", 10, 0
    fmt_x2: db "x2 = %.6f", 10, 0

    a:      dd 1.0
    b:      dd 0.5
    one:    dd 1.0
    ten:    dd 10.0

section .bss
    x1:     resd 1
    x2:     resd 1
    acosb:  resd 1

section .text
global main

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; ---------------------------------------------------------
    ; 1) acosb = arccos(b)  — через x87 (в SSE нет arccos)
    ;    arccos(b) = atan2(sqrt(1 - b^2), b)
    ;    x87: FPATAN вычисляет arctg(ST1/ST0)
    ;    Загрузим: ST0 = b, ST1 = sqrt(1 - b^2)
    ;    Тогда FPATAN даст arctg(sqrt(1-b^2)/b) = arccos(b)
    ; ---------------------------------------------------------
    fld     dword [b]              ; ST0 = b
    fld     st0                    ; ST0 = b, ST1 = b
    fmul    st0, st0               ; ST0 = b^2
    fld1                           ; ST0 = 1, ST1 = b^2
    fsubrp  st1, st0               ; ST1 = 1 - b^2, ST0 = b^2 (pop)
    ; Хм, надо аккуратнее. Сделаем иначе:
    ; очистим стек и перепишем корректно
    fstp    st0                    ; вытолкнуть (стек очищен)
    fstp    st0

    ; --- корректная последовательность ---
    ; Хотим получить: ST1 = sqrt(1-b^2), ST0 = b
    fld     dword [b]              ; ST0 = b
    fld     st0                    ; ST0 = b, ST1 = b
    fmul    st0, st0               ; ST0 = b^2, ST1 = b
    fld1                           ; ST0 = 1, ST1 = b^2, ST2 = b
    fsub    st0, st1               ; ST0 = 1 - b^2, ST1 = b^2, ST2 = b
    fsqrt                          ; ST0 = sqrt(1-b^2), ST1 = b^2, ST2 = b
    fstp    st1                    ; ST0 = sqrt(1-b^2), ST1 = b (b^2 убрали)
    fxch    st1                    ; ST0 = b, ST1 = sqrt(1-b^2)
    fpatan                         ; ST0 = arctg(sqrt(1-b^2)/b) = arccos(b)
    fstp    dword [acosb]          ; сохранили, стек пуст

    ; ---------------------------------------------------------
    ; 2) x1 = a + 10^(acosb)
    ;    10^y = 2^(y * log2(10))
    ;    Через x87: F2XM1 + FSCALE
    ; ---------------------------------------------------------
    fld     dword [acosb]
    fldl2t                         ; ST0 = log2(10), ST1 = acosb
    fmulp   st1, st0               ; ST1 = acosb * log2(10) = y*log2(10)
    ; теперь ST0 = y*log2(10) — надо вычислить 2^ST0
    ; разложим на целую и дробную части
    fld     st0                    ; ST0 = z, ST1 = z
    frndint                        ; ST0 = round(z), ST1 = z
    fsub    st1, st0               ; ST1 = z - round(z) = дробная часть
    fxch    st1                    ; ST0 = дробная часть, ST1 = целая часть
    f2xm1                          ; ST0 = 2^дробн - 1
    fld1
    faddp   st1, st0               ; ST0 = 2^дробн
    fscale                         ; ST0 = 2^дробн * 2^целая = 2^z = 10^acosb
    fstp    st1                    ; вытолкнули целую часть, оставили результат
    fadd    dword [a]              ; ST0 = a + 10^acosb = x1
    fstp    dword [x1]             ; стек пуст

    ; ---------------------------------------------------------
    ; 3) x2 = a + 10^(-acosb)
    ; ---------------------------------------------------------
    fld     dword [acosb]
    fchs                           ; ST0 = -acosb
    fldl2t
    fmulp   st1, st0               ; ST0 = -acosb * log2(10)
    fld     st0
    frndint
    fsub    st1, st0
    fxch    st1
    f2xm1
    fld1
    faddp   st1, st0
    fscale
    fstp    st1
    fadd    dword [a]
    fstp    dword [x2]             ; стек пуст

    ; ---------------------------------------------------------
    ; 4) Вывод
    ; ---------------------------------------------------------
    cvtss2sd xmm0, [x1]
    lea     rdi, [fmt_x1]
    mov     eax, 1

    cvtss2sd xmm0, [x2]
    lea     rdi, [fmt_x2]
    mov     eax, 1

    xor     eax, eax
    leave
    ret