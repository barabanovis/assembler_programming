#include <stdio.h>

struct S {
    int   field0;
    int   field4;
    float field8;
    float field12;
};

// Объявляем функцию из библиотеки
extern "C" void access2(float a, const S& s, int c);

int main() {
    S s;
    s.field0 = 0;
    s.field4 = 0;
    s.field8 = 0.0f;
    s.field12 = 0.0f;

    // Передаем 100.0f, чтобы левая часть (val2) точно была меньше правой (val1)
    access2(100.0f, s, 0);

    return 0;
}