#include <stdio.h>


int main() {
	short arr[100];
	int n, gap, i, j;
	short temp;

	if (scanf("%d", &n) != 1 || n <= 0 || n > 100) {
		return 0;
	}

	for (i = 0; i < n; ++i) {
		scanf("%hd", &arr[i]);
	}

	for (gap = n / 2; gap > 0; gap /= 2) {
		for (i = gap; i < n; ++i) {
			temp = arr[i];
			for (j = i; j >= gap && arr[j - gap] > temp; j -= gap) {
				arr[j] = arr[j - gap];
			}
			arr[j] = temp;
		}
	}

	for (i = 0; i < n; ++i) {
		printf("%hd ", arr[i]);
	}
	return 0;
}