#include <stdio.h>

char cesar_shift(const char c, const int shift) {
	char res = c + shift;
	if (res > 'Z') {
		res -= 28;
	}
	return res;
}

int main() {
	
}