namespace hard {
    namespace var1 {
        struct S {
            // Поля структуры (мы пока не знаем какие, но размер <= 8 байт)
        };

        class C {
        public:
            int value; // Поле, которое лежит по адресу [rbp+10h]
            bool check(S s) const;
        };

        bool check(bool b) {
            return b;
        }

        extern "C" void access1(C c, S s) {
            check(false); // Вызов из начала функции
            bool result = c.check(s);
            check(result);
        }
    }
}