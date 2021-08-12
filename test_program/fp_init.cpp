// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

#include <cstdlib>
#include <cstdint>
#include <cstdio>

#include <fcntl.h>
#include <sys/mman.h>

namespace {
    constexpr uintptr_t FPGA_BRIDGE_BASE = 0xC000'0000;
    constexpr uintptr_t PERIPHERAL_BASE  = 0x0002'0000;
    constexpr uintptr_t MAP_SIZE = 4096;
    constexpr uintptr_t MAP_MASK = MAP_SIZE-1;
}

struct ops;
struct status;

extern "C" {
    uintptr_t OP0 = 0;
    uintptr_t OP1 = 0;
    uintptr_t OP2 = 0;
    uintptr_t RES = 0;

    volatile ops *oper_reg = nullptr;
    volatile status *status_reg = nullptr;
}

struct FpInit {
    FpInit();
};

FpInit::FpInit() {
    int fd;
    if (fd = open("/dev/mem", O_RDWR | O_SYNC); fd == -1) {
        fprintf(stderr, "Cannot open /dev/mem\n");
        exit(1);
    }

    uintptr_t map_base = (uintptr_t) mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (FPGA_BRIDGE_BASE + PERIPHERAL_BASE) & ~MAP_MASK);
    if (map_base == -1) {
        fprintf(stderr, "Cannot map peripheral\n");
        exit(2);
    }

    OP0 = map_base + 0x00;
    OP1 = map_base + 0x08;
    OP2 = map_base + 0x10;
    RES = map_base + 0x20;

    oper_reg = reinterpret_cast<volatile ops *>(map_base + 0x18);
    status_reg = reinterpret_cast<volatile status *>(map_base + 0x28);
}

FpInit __init;
