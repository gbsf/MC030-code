// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

#include "fp_class.hpp"

int main() {
    Fp16 one16 = 1.;
    printf("%f+%f = %f (16)\n", one16, one16, one16+one16);
    Fp32 one32 = 1.;
    printf("%f+%f = %f (32)\n", one32, one32, one32+one32);
    Fp64 one64 = 1.;
    printf("%f+%f = %f (64)\n", one64, one64, one64+one64);
    Fp16a one16a = 1.;
    printf("%f+%f = %f (16a)\n", one16a, one16a, one16a+one16a);
    Fp8 one8 = 1.;
    printf("%f+%f = %f (8)\n", one8, one8, one8+one8);
    Fp16 fp1 = Fp16::raw(0xC900);
    Fp16 fp2 = Fp16::raw(0xCD00);

    double d1 = fp1+fp2;
    printf("-10 + -20 = %lf\n", d1);
    Fp16 fp3 = Fp16::raw(0x4000);
    Fp16 fp4 = Fp16::raw(0x4200);

    double d2 = fp3*fp4;
    printf("2 * 3 = %lf\n", d2);

    Fp16 fp5(17.0);
    Fp16 fp6(25.f);
    float d3 = fp5*fp6;
    printf("17 * 25 = %f\n", d3);

    Fp16 fp7(931.f);
    Fp16 fp8(49.);
    float d4 = fp7/fp8;
    printf("931 / 49 = %f\n", d4);

    Fp16 fp9 = -100.;
    printf("(int)-100.0 = %d\n", static_cast<int>(fp9));

    Fp16 fp10 = 625.;
    printf("sqrt(625) = %f\n", (float)Fp16::sqrt(fp10));

    Fp16 fp11 = -10;
    Fp16 fp12 = (short)-10;
    Fp16 fp13 = (unsigned short)10u;
    printf("(float)-10  = %f\t(int)(float16)-10 =\t%d\n(float)-10s = %f\t(short)(float16)-10s =\t%hd\n(float)10us = % f\t(ushort)(float16)10us =\t%hu\n",
		    (float)fp11, (int)fp11, static_cast<float>(fp12), (short)fp12, (float)fp13, (unsigned short)fp13);

    return 0;
}
