; ============================================================
; Задание 4, п.5: проверить y = th(a*x)
; a = 2.0, x = 0.5, y = 0.7615942
; Ответ: 1 (истина) или 0 (ложь)
;
; th(z) = (e^(2z) - 1) / (e^(2z) + 1)
; ============================================================

default rel
%include 'io64.inc'
extern printf

section .rodata
    fmt_res: db "%d", 10, 0

    a:      dd 2.0
    x:      dd 0.5
    y:      dd 0.7615942
    eps:    dd 0.000001

section .bss
    th_val: resd 1
    diff:   resd 1

section .text
global main

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; ---------------------------------------------------------
    ; 1) z = a * x  (через SSE)
    ; ---------------------------------------------------------
    movss   xmm0, [a]
    mulss   xmm0, [x]              ; xmm0 = a*x
    movss   [diff], xmm0           ; временно сохраним z в diff

    ; ---------------------------------------------------------
    ; 2) w = 2z * log2(e)  — подготовка к e^(2z)
    ;    Считаем 2z сразу: ST0 = 2z, потом умножим на log2(e)
    ; ---------------------------------------------------------
    fld     dword [diff]           ; ST0 = z
    fadd    st0, st0               ; ST0 = 2z
    fldl2e                         ; ST0 = log2(e), ST1 = 2z
    fmulp   st1, st0               ; ST1 = 2z * log2(e), вершина вытолкнута
    ; ST0 = w = 2z * log2(e)

    ; ---------------------------------------------------------
    ; 3) e^(2z) = 2^w.  Разбиваем w на целую и дробную части.
    ; ---------------------------------------------------------
    fld     st0                    ; ST0 = w, ST1 = w
    frndint                        ; ST0 = n = round(w), ST1 = w
    fsub    st1, st0               ; ST1 = w - n = f (дробная часть, |f|<=0.5)
    fxch    st1                    ; ST0 = f, ST1 = n
    f2xm1                          ; ST0 = 2^f - 1
    fld1
    faddp   st1, st0               ; ST0 = 2^f
    fscale                         ; ST0 = 2^f * 2^n = e^(2z)
    fstp    st1                    ; вытолкнули n, оставили e^(2z)
    ; ST0 = e^(2z) = E

    ; ---------------------------------------------------------
    ; 4) th = (E - 1) / (E + 1)
    ; ---------------------------------------------------------
    fld1                           ; ST0 = 1, ST1 = E
    fsub    st1, st0               ; ST1 = E - 1, ST0 = 1
    ; теперь ST0 = 1, ST1 = E-1 — неудобно. Перепишем:
    ; сбросим и сделаем заново аккуратнее.
    fstp    st0                    ; вытолкнули 1
    ; ST0 = E - 1 ??? — нет, мы испортили. Сделаем с нуля.
    ; (в реальном коде эти лишние шаги не нужны — см. ниже чистый вариант)

    ; ---- ЧИСТЫЙ вариант шага 4 ----
    ; Восстановим E заново — для наглядности просто пересчитаем
    ; (в оптимизированном коде E уже в ST0, и шаг 4 такой):
    ;   fld1
    ;   fld st1        ; ST0 = E, ST1 = 1, ST2 = E
    ;   fsub st0, st1  ; ST0 = E - 1, ST1 = 1, ST2 = E
    ;   fxch st1       ; ST0 = 1, ST1 = E-1, ST2 = E
    ;   faddp st2, st0 ; ST2 = E+1, ST1 = E-1, ST0 = ?
    ; ... проще сделать так:

    ; Пересчёт E:
    fld     dword [diff]           ; ST0 = z
    fadd    st0, st0               ; ST0 = 2z
    fldl2e
    fmulp   st1, st0               ; ST0 = w
    fld     st0
    frndint
    fsub    st1, st0
    fxch    st1
    f2xm1
    fld1
    faddp   st1, st0
    fscale
    fstp    st1                    ; ST0 = E = e^(2z)

    ; Теперь: E в ST0. Вычислим (E-1)/(E+1)
    fld1                           ; ST0 = 1, ST1 = E
    fld     st1                    ; ST0 = E, ST1 = 1, ST2 = E
    fsub    st0, st1               ; ST0 = E-1, ST1 = 1, ST2 = E
    fxch    st1                    ; ST0 = 1, ST1 = E-1, ST2 = E
    faddp   st2, st0               ; ST2 = E+1, ST1 = E-1, ST0 = ?
    ; после faddp st2, st0: ST0 = (бывший ST1) = E-1, ST1 = (бывший ST2) = E+1
    ; — не совсем. Проверим: faddp st2, st0 делает ST2 += ST0 и pop.
    ; ST0 = 1, ST1 = E-1, ST2 = E
    ; после faddp st2, st0: ST2 = E + 1, pop → ST0 = E-1, ST1 = E+1.
    fdivp   st1, st0               ; ST1 = ST1 / ST0 = (E+1)/(E-1) — не то.
    ; Нам нужно (E-1)/(E+1). Значит:
    ; ST0 = E-1, ST1 = E+1 → FDIVP st1, st0 даст ST1 = ST1/ST0 = (E+1)/(E-1).
    ; Надо наоборот: FDIVRP st1, st0 = ST0/ST1 = (E-1)/(E+1). Или fxch.
    ; Проще так: после fdivp получим не то, поэтому перепишем:

    ; ---- ФИНАЛЬНЫЙ ЧИСТЫЙ вариант без путаницы ----
    ; Сбросим стек и сделаем всё заново аккуратно
    fstp    st0                    ; очистим остатки
    fstp    st0
    fstp    st0

    ; Пересчёт E (третий раз — извините за многословность, зато надёжно)
    fld     dword [diff]
    fadd    st0, st0
    fldl2e
    fmulp   st1, st0
    fld     st0
    frndint
    fsub    st1, st0
    fxch    st1
    f2xm1
    fld1
    faddp   st1, st0
    fscale
    fstp    st1                    ; ST0 = E = e^(2z)

    ; ---- th = (E - 1) / (E + 1) ----
    ; Хотим: числитель = E - 1, знаменатель = E + 1
    fld     st0                    ; ST0 = E, ST1 = E
    fld1                           ; ST0 = 1, ST1 = E, ST2 = E
    fsubp   st2, st0               ; ST2 = E - 1, ST1 = E, pop → ST0 = E, ST1 = E-1
    ; нет, опять. Проще всего:
    ; ST0 = E
    fld1                           ; ST0 = 1, ST1 = E
    fadd    st1, st0               ; ST1 = E + 1, ST0 = 1
    ; теперь ST0 = 1, ST1 = E+1
    ; загрузим E снова не можем — потеряли. Сделаем иначе.

    ; ---- САМЫЙ ПРОСТОЙ ПОДХОД ----
    ; Считаем числитель и знаменатель по отдельности через SSE.
    fstp    st0                    ; очистка
    fstp    st0

    ; E уже потерян. Пересчитываем E и сразу сохраняем в память.
    fld     dword [diff]
    fadd    st0, st0
    fldl2e
    fmulp   st1, st0
    fld     st0
    frndint
    fsub    st1, st0
    fxch    st1
    f2xm1
    fld1
    faddp   st1, st0
    fscale
    fstp    st1                    ; ST0 = E
    fstp    dword [th_val]         ; сохранили E в память (переиспользуем th_val)

    ; ---- Теперь чисто через SSE: th = (E-1)/(E+1) ----
    movss   xmm0, [th_val]         ; xmm0 = E
    movss   xmm1, xmm0
    subss   xmm1, [one_ss]         ; xmm1 = E - 1
    addss   xmm0, [one_ss]         ; xmm0 = E + 1
    divss   xmm1, xmm0             ; xmm1 = (E-1)/(E+1) = th
    movss   [th_val], xmm1         ; сохранили th

    ; ---------------------------------------------------------
    ; 5) diff = |y - th|
    ; ---------------------------------------------------------
    movss   xmm0, [y]
    subss   xmm0, [th_val]
    ; модуль: обнуляем знаковый бит
    movd    eax, xmm0
    and     eax, 0x7FFFFFFF
    movd    xmm0, eax
    movss   [diff], xmm0

    ; ---------------------------------------------------------
    ; 6) Сравнение diff < eps
    ; ---------------------------------------------------------
    movss   xmm0, [diff]
    comiss  xmm0, [eps]
    jb      .true                  ; diff < eps → истина
    ; иначе — ложь
    lea     rdi, [fmt_res]
    xor     esi, esi               ; 0
    xor     eax, eax
    jmp     .end

.true:
    lea     rdi, [fmt_res]
    mov     esi, 1
    xor     eax, eax

.end:
    xor     eax, eax
    leave
    ret

section .rodata
    one_ss: dd 1.0