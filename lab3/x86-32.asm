; ============================================================
; Лабораторная 3, Задание 1, сложный уровень.
; Архитектура: x86-32, cdecl.
;
; Что сделано:
;  - %include "io.inc" — штатный способ SASM для x86.
;  - CEXTERN автоматически добавит '_' к printf/scanf/malloc/free.
;  - Массив short выделяется через malloc и освобождается free.
;  - Все переменные (n, gap, temp, i, j, arr) лежат в стеке.
;  - Сообщения в консоль добавлены.
; ============================================================

%include "io.inc"

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

; CEXTERN сам разберется с префиксами для x86-32
CEXTERN printf
CEXTERN scanf
CEXTERN malloc
CEXTERN free

main:
    push ebp
    mov  ebp, esp
    sub  esp, 32             ; выделяем место под локальные переменные

    ; [ebp-4]  n
    ; [ebp-8]  gap
    ; [ebp-12] temp
    ; [ebp-16] i
    ; [ebp-20] j
    ; [ebp-24] arr (short*)

    ; ---------- "Enter n: " ----------
    push dword msg_n
    call printf
    add  esp, 4

    ; ---------- scanf("%d", &n) ----------
    lea  eax, [ebp-4]
    push eax
    push dword fmt_int
    call scanf
    add  esp, 8

    mov  eax, [ebp-4]
    test eax, eax
    jle  .exit

    ; ---------- malloc(n * 2) ----------
    mov  eax, [ebp-4]
    shl  eax, 1
    push eax
    call malloc
    add  esp, 4
    mov  [ebp-24], eax
    test eax, eax
    jz   .exit

    ; ---------- "Enter array elements: " ----------
    push dword msg_arr
    call printf
    add  esp, 4

    ; ---------- Ввод массива ----------
    mov  dword [ebp-16], 0
.read_loop:
    mov  eax, [ebp-16]
    cmp  eax, [ebp-4]
    jge  .sort_start

    mov  edx, [ebp-24]
    lea  eax, [edx + eax*2]
    push eax
    push dword fmt_short
    call scanf
    add  esp, 8

    inc  dword [ebp-16]
    jmp  .read_loop

.sort_start:
    mov  eax, [ebp-4]
    shr  eax, 1
    mov  [ebp-8], eax          ; gap = n / 2

.gap_outer:
    cmp  dword [ebp-8], 0
    jle  .print
    mov  eax, [ebp-8]
    mov  [ebp-16], eax         ; i = gap

.i_loop:
    mov  eax, [ebp-16]
    cmp  eax, [ebp-4]
    jge  .next_gap

    ; temp = arr[i]
    mov  ecx, [ebp-24]
    mov  eax, [ebp-16]
    movsx edx, word [ecx + eax*2]
    mov  [ebp-12], edx

    ; j = i
    mov  eax, [ebp-16]
    mov  [ebp-20], eax

.inner_loop:
    mov  eax, [ebp-20]
    cmp  eax, [ebp-8]
    jl   .place_temp           ; if j < gap -> break

    ; проверяем arr[j - gap] > temp
    mov  ecx, [ebp-24]
    mov  eax, [ebp-20]
    sub  eax, [ebp-8]
    movsx edx, word [ecx + eax*2]

    cmp  edx, [ebp-12]
    jle  .place_temp           ; if arr[j-gap] <= temp -> break

    ; arr[j] = arr[j - gap]
    mov  ecx, [ebp-24]
    mov  eax, [ebp-20]
    mov  [ecx + eax*2], dx

    ; j -= gap
    mov  eax, [ebp-8]
    sub  [ebp-20], eax
    jmp  .inner_loop

.place_temp:
    ; arr[j] = temp
    mov  ecx, [ebp-24]
    mov  eax, [ebp-20]
    mov  edx, [ebp-12]
    mov  [ecx + eax*2], dx

    inc  dword [ebp-16]
    jmp  .i_loop

.next_gap:
    mov  eax, [ebp-8]
    shr  eax, 1
    mov  [ebp-8], eax
    jmp  .gap_outer

.print:
    ; ---------- "Sorted array: " ----------
    push dword msg_sorted
    call printf
    add  esp, 4

    mov  dword [ebp-16], 0
.print_loop:
    mov  eax, [ebp-16]
    cmp  eax, [ebp-4]
    jge  .free_exit

    mov  edx, [ebp-24]
    mov  eax, [ebp-16]
    movsx eax, word [edx + eax*2]
    push eax
    push dword fmt_short_sp
    call printf
    add  esp, 8

    inc  dword [ebp-16]
    jmp  .print_loop

.free_exit:
    ; ---------- free(arr) ----------
    push dword [ebp-24]
    call free
    add  esp, 4

.exit:
    ; Перевод строки
    push dword fmt_nl
    call printf
    add  esp, 4

    xor  eax, eax
    leave
    ret