struct S {
    int   field0;  // [rdx + 0]
    int   field4;  // [rdx + 4]
    float field8;  // [rdx + 8]
    float field12; // [rdx + 0xC]
};

extern "C" void access2(float a, const S& s, int c) {
    // Константы dword_418 и dword_414 обычно равны 1.0f и 0.0f
    float k1 = 1.0f;
    float k2 = 0.0f;

    // xmm1 = a + (field0 * field12)
    float val1 = a + ((float)s.field0 * s.field12);

    // xmm0 = (k1 * field8) + field4 - k2
    float val2 = (k1 * s.field8) + (float)s.field4 - k2;

    if (val2 <= val1) {
        // loc_DA
        printf("Access granted\n");
    }
    else {
        printf("Access denied\n");
    }
}