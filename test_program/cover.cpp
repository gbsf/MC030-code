// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

#include <cstdio>
#include <cmath>
#include <cinttypes>
#include <cfenv>
#ifndef SKIP_FP
#include "fp_class.hpp"
#endif

#ifndef FPTYPE
#define FPTYPE Fp64
#endif

constexpr uint64_t SIZE = 64ull*1024;

static FPTYPE Af[SIZE], Bf[SIZE];
static double Ad[SIZE], Bd[SIZE];

struct abserr_t {
    double add, sub, mul, div;
};

abserr_t ae{0};

uint64_t error = 0;

constexpr uint64_t hlfpct = SIZE*SIZE/200;

int main() {
    srand48(0x9B23F81C);

    for (uint64_t i = 0; i < SIZE; i++) {
        Ad[i] = Af[i] = (lrand48()&0xFFFFFFF)*2*(drand48()-0.5);
        Bd[i] = Bf[i] = (lrand48()&0xFFFFFFF)*2*(drand48()-0.5);
    }

    printf("Coverage Start\n");
    fesetround(FE_TONEAREST);

    for (uint64_t i = 0; i < SIZE; i++)
        for (uint64_t j = 0; j < SIZE; j++) {
            auto add_f = Af[i] + Bf[j];
            auto sub_f = Af[i] - Bf[j];
            auto mul_f = Af[i] * Bf[j];
            auto div_f = Af[i] / Bf[j];

            auto add_d = Ad[i] + Bd[j];
            auto sub_d = Ad[i] - Bd[j];
            auto mul_d = Ad[i] * Bd[j];
            auto div_d = Ad[i] / Bd[j];

            auto add = abs((add_d-(double)add_f));
            auto sub = abs((sub_d-(double)sub_f));
            auto mul = abs((mul_d-(double)mul_f));
            auto div = abs((div_d-(double)div_f));

            ae.add += add;
            ae.sub += sub;
            ae.mul += mul;
            ae.div += div;

            if (add != 0 || sub != 0 || mul != 0 || div != 0)
                error++;

            if ((i*SIZE+j) % hlfpct == 0) {
                printf("%.1f%%: %e %e %e %e total: %" PRIu64 "/%" PRIu64 "\n", ((double)(i*SIZE+j))/hlfpct/2., ae.add, ae.sub, ae.mul, ae.div, error, i*SIZE+j);
                fflush(nullptr);
            }
        }

    printf("%e %e %e %e %" PRIu64 "\n", ae.add, ae.sub, ae.mul, ae.div, error);
    printf("%e %e %e %e\n", ae.add/SIZE/SIZE, ae.sub/SIZE/SIZE, ae.mul/SIZE/SIZE, ae.div/SIZE/SIZE);
    return 0;
}
