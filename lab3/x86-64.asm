; ============================================================
; Лабораторная 3, Задание 1, сложный уровень.
; Архитектура: x86-64.
; ABI: Microsoft x64 (SASM/MinGW Windows).
;
; Что сделано:
;   - массив short в куче: malloc(n * 2);
;   - free(ptr) после работы;
;   - n, gap, temp, i, j, arr — локальные переменные в стеке;
;   - ввод/вывод через scanf/printf;
;   - добавлены сообщения в консоль:
;       "Enter n: ", "Enter array elements: ", "Sorted array: ".
;
; Почему так:
;   - сложный уровень запрещает буферы в .data/.bss;
;   - malloc/free — стандартное динамическое выделение памяти;
;   - локальные переменные в стеке не нарушают стандартный кадр;
;   - перед printf/scanf RSP выровнен по 16 байт;
;   - для vararg-функций Microsoft x64 AL = 0.
; ============================================================

%include "io64.inc"          ; нужен для CEXTERN в SASM

default rel

section .rodata
    fmt_int:      db "%d", 0
    fmt_short:    db "%hd", 0
    fmt_short_sp: db "%hd ", 0
    fmt_nl:       db 10, 0
    msg_n:        db "Enter n: ", 0
    msg_arr:      db "Enter array elements: ", 0
    msg_sorted:   db "Sorted array: ", 0

section .text
global main

CEXTERN printf
CEXTERN scanf
CEXTERN malloc
CEXTERN free

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 96

    ; [rbp-8]  n
    ; [rbp-16] gap
    ; [rbp-24] temp
    ; [rbp-32] i
    ; [rbp-40] j
    ; [rbp-48] arr (short*)

    ; ---------- Сообщение "Enter n: " ----------
    lea  rcx, [msg_n]
    xor  eax, eax
    call printf

    ; ---------- Ввод n ----------
    lea  rcx, [fmt_int]
    lea  rdx, [rbp-8]
    xor  eax, eax
    call scanf

    mov  eax, [rbp-8]
    test eax, eax
    jle  .exit

    ; ---------- malloc(n * 2) ----------
    mov  ecx, [rbp-8]
    shl  rcx, 1
    call malloc
    mov  [rbp-48], rax
    test rax, rax
    jz   .exit

    ; ---------- Сообщение "Enter array elements: " ----------
    lea  rcx, [msg_arr]
    xor  eax, eax
    call printf

    ; ---------- Ввод массива ----------
    mov  dword [rbp-32], 0
.read_loop:
    mov  eax, [rbp-32]
    cmp  eax, [rbp-8]
    jge  .sort_start

    lea  rcx, [fmt_short]
    mov  rdx, [rbp-48]
    mov  eax, [rbp-32]
    lea  rdx, [rdx + rax*2]
    xor  eax, eax
    call scanf

    inc  dword [rbp-32]
    jmp  .read_loop

.sort_start:
    mov  eax, [rbp-8]
    shr  eax, 1
    mov  [rbp-16], eax

.gap_outer:
    mov  eax, [rbp-16]
    test eax, eax
    jz   .print
    mov  [rbp-32], eax

.i_loop:
    mov  eax, [rbp-32]
    cmp  eax, [rbp-8]
    jge  .next_gap

    mov  rdx, [rbp-48]
    mov  eax, [rbp-32]
    movsx eax, word [rdx + rax*2]
    mov  [rbp-24], eax

    mov  eax, [rbp-32]
    mov  [rbp-40], eax

.inner_loop:
    mov  eax, [rbp-40]
    cmp  eax, [rbp-16]
    jl   .place_temp

    mov  rdx, [rbp-48]
    mov  eax, [rbp-40]
    sub  eax, [rbp-16]
    movsx eax, word [rdx + rax*2]

    cmp  eax, [rbp-24]
    jle  .place_temp

    mov  rdx, [rbp-48]
    mov  ecx, [rbp-40]
    mov  r8d, [rbp-40]
    sub  r8d, [rbp-16]
    mov  ax, word [rdx + r8*2]
    mov  word [rdx + rcx*2], ax

    mov  eax, [rbp-16]
    sub  [rbp-40], eax
    jmp  .inner_loop

.place_temp:
    mov  rdx, [rbp-48]
    mov  eax, [rbp-40]
    mov  ecx, [rbp-24]
    mov  word [rdx + rax*2], cx

    inc  dword [rbp-32]
    jmp  .i_loop

.next_gap:
    mov  eax, [rbp-16]
    shr  eax, 1
    mov  [rbp-16], eax
    jmp  .gap_outer

.print:
    ; ---------- Сообщение "Sorted array: " ----------
    lea  rcx, [msg_sorted]
    xor  eax, eax
    call printf

    ; ---------- Вывод массива ----------
    mov  dword [rbp-32], 0
.print_loop:
    mov  eax, [rbp-32]
    cmp  eax, [rbp-8]
    jge  .free_exit

    lea  rcx, [fmt_short_sp]
    mov  rdx, [rbp-48]
    mov  eax, [rbp-32]
    movsx edx, word [rdx + rax*2]
    xor  eax, eax
    call printf

    inc  dword [rbp-32]
    jmp  .print_loop

.free_exit:
    mov  rcx, [rbp-48]
    call free

.exit:
    lea  rcx, [fmt_nl]
    xor  eax, eax
    call printf

    xor  eax, eax
    leave
    ret