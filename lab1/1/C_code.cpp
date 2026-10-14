#include <stdio.h>


int main() {
	// Сами числа 
	unsigned int a;
	unsigned int b;
	scanf("%u %u", &a, &b);

	// max{a,b} <= НОК(a,b) <= ab
	// без огр. общности a>=b
	if (b > a) {
		unsigned int tmp = a;
		a = b;
		b = tmp;
	}

	for (int x = b; x <= a * b; x++) {
		if (x % a == 0 && x % b == 0) {
			printf("%i", x);
			return 0;
		}
	}
	return 0;
}