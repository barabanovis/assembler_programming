#include <stdio.h>

int main() {
    int i = 0;
    short arr[100];
    int n;

    if (scanf("%d", &n) != 1) goto end_main;
    if (n <= 0 || n > 100) goto end_main;

read_loop:
    if (i >= n) goto short_start;
    scanf("%hd", &arr[i]);
    i++;
    goto read_loop;

short_start:
    int gap = n / 2;  // сразу задаём gap = n/2, без лишнего присваивания

gap_outer:
    if (gap <= 0) goto print_start;

    int ii = gap;     // ii нужен для сортировки — оставляем

i_loop:
    if (ii >= n) goto next_gap;

    short temp = arr[ii];
    int jj = ii;      // jj нужен для внутреннего цикла — оставляем

j_inner:
    if (jj < gap) goto place_temp;

    int idx_prev = jj - gap;
    short val_prev = arr[idx_prev];

    // Условие: если предыдущий элемент НЕ меньше текущего, выходим из внутреннего цикла
    if (!(val_prev < temp)) goto place_temp;

    arr[jj] = val_prev;
    jj = jj - gap;
    goto j_inner;

place_temp:
    arr[jj] = temp;
    ii++;
    goto i_loop;

next_gap:
    gap /= 2;         // сокращённая запись gap = gap / 2
    goto gap_outer;

print_start:
    i = 0;

print_loop:
    if (i >= n) goto end_main;
    printf("%hd ", arr[i]);
    i++;
    goto print_loop;

end_main:
    return 0;
}