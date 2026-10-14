#include <stdio.h>


int main() {
	// Сами числа 
	unsigned int a;
	unsigned int b;
	scanf("%u %u", &a, &b);

	// max{a,b} <= НОК(a,b) <= ab
	// без огр. общности a>=b
	unsigned int tmp = a;
	if (!(a <= b)) goto if_end;
	a = b;
	b = tmp;
if_end:
	unsigned int x = b-1;
cycle_start:
	x += 1;
	if (!(x % a == 0 && x % b == 0)) goto cycle_start;
	printf("%i", x);
	return 0;
}