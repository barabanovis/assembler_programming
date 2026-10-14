%include "io64.inc"          ; подключаем стандартные макросы SASM (GET_DEC, PRINT_DEC, PRINT_CHAR, NEWLINE)

section .bss                 ; секция неинициализированных глобальных данных
    arr:  resw 100           ; резервируем 100 слов (short, 2 байта) = 200 байт под массив arr

section .text                ; секция кода
global main                  ; делаем main видимой для C-обёртки SASM (точка входа)

main:                        ; точка входа
    push rbp                 ; сохраняем кадр стека вызывающей функции
    mov  rbp, rsp            ; rbp = rsp — устанавливаем свой кадр стека
    sub  rsp, 16             ; выделяем 16 байт под локальные переменные (кратно 16 — требование ABI для вызова printf/scanf)

    ; раскладка локальных переменных относительно rbp:
    ; [rbp-4]  -> n    (int, 4 байта)
    ; [rbp-8]  -> gap  (int, 4 байта)
    ; [rbp-12] -> temp (int, 4 байта)

    ; ---------- Ввод N ----------
    GET_DEC 4, eax           ; макрос SASM: читает знаковое десятичное число (4 байта) в eax
    mov [rbp-4], eax         ; сохраняем введённое n в [rbp-4]
    cmp eax, 0               ; сравниваем n с 0
    jle .exit                ; если n <= 0 — на выход (пустой/некорректный массив)
    cmp eax, 100             ; сравниваем n с 100
    jg  .exit                ; если n > 100 — на выход (массив arr вмещает только 100 элементов)

    ; ---------- Ввод массива ----------
    xor ecx, ecx             ; ecx = 0 — счётчик-индекс i
.read_loop:                  ; метка начала цикла чтения
    cmp ecx, [rbp-4]         ; сравниваем i с n
    jge .sort_start          ; если i >= n — все элементы прочитаны, переходим к сортировке
    GET_DEC 4, eax           ; читаем очередное число в eax
    mov [arr + rcx*2], ax    ; arr[i] = ax (пишем младшие 2 байта, т.к. элемент short; rcx*2 — шаг 2 байта)
    inc ecx                  ; i++
    jmp .read_loop           ; повторяем цикл

.sort_start:                 ; начало сортировки Шелла
    mov eax, [rbp-4]         ; eax = n
    shr eax, 1               ; eax = n / 2 (логический сдвиг вправо на 1 = деление на 2)
    mov [rbp-8], eax         ; gap = n / 2 (начальный шаг сортировки)

.gap_outer:                  ; внешний цикл по значению gap
    test eax, eax            ; проверяем gap == 0 ?
    jz .print                ; если gap == 0 — сортировка завершена, переходим к выводу
    mov edi, eax             ; edi = gap (счётчик ii пробега по массиву)

.i_loop:                     ; цикл по ii = gap .. n-1
    cmp edi, [rbp-4]         ; сравниваем ii с n
    jge .next_gap            ; если ii >= n — переходим к уменьшению gap
    movsx eax, word [arr + rdi*2]  ; eax = arr[ii] (movsx — расширение знака при загрузке short в int)
    mov [rbp-12], eax        ; temp = arr[ii]
    mov esi, edi             ; esi = jj = ii (внутренний индекс)

.inner_loop:                 ; цикл сдвига элементов, отстоящих на gap
    cmp esi, [rbp-8]         ; сравниваем jj с gap
    jl .place_temp           ; если jj < gap — выходим из внутреннего цикла
    mov ebx, esi             ; ebx = jj
    sub ebx, [rbp-8]         ; ebx = jj - gap (индекс предыдущего элемента)
    movsx ebx, word [arr + rbx*2]  ; ebx = arr[jj - gap]
    cmp ebx, [rbp-12]        ; сравниваем arr[jj-gap] с temp
    jle .place_temp          ; если arr[jj-gap] <= temp — нашли место для temp
    mov [arr + rsi*2], bx    ; arr[jj] = arr[jj - gap] (сдвигаем элемент вправо)
    sub esi, [rbp-8]         ; jj -= gap
    jmp .inner_loop          ; повторяем внутренний цикл

.place_temp:                 ; вставка temp на найденное место
    mov ax, [rbp-12]         ; ax = temp (младшие 2 байта)
    mov [arr + rsi*2], ax    ; arr[jj] = temp
    inc edi                  ; ii++
    jmp .i_loop              ; продолжаем цикл по ii

.next_gap:                   ; переход к следующему (меньшему) значению gap
    mov eax, [rbp-8]         ; eax = gap
    shr eax, 1               ; eax = gap / 2
    mov [rbp-8], eax         ; gap = gap / 2
    jmp .gap_outer           ; повторяем внешний цикл

.print:                      ; вывод отсортированного массива
    xor ecx, ecx             ; ecx = 0 — счётчик i
.print_loop:
    cmp ecx, [rbp-4]         ; сравниваем i с n
    jge .exit                ; если i >= n — вывод завершён
    movsx eax, word [arr + rcx*2]  ; eax = arr[i]
    PRINT_DEC 2, ax          ; макрос SASM: печатает знаковое число размером 2 байта из ax
    PRINT_CHAR ' '           ; макрос SASM: печатает символ-пробел
    inc ecx                  ; i++
    jmp .print_loop          ; повторяем цикл вывода

.exit:                       ; завершение программы
    NEWLINE                  ; макрос SASM: печатает перевод строки '\n'
    xor eax, eax             ; возвращаем 0 (успех) — код возврата из main
    leave                    ; восстанавливаем rsp = rbp, затем pop rbp (эпилог)
    ret                      ; возврат в C-обёртку SASM