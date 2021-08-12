// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

#include <bit>
#include <type_traits>
#include <limits>
#include <complex>

#include <cstdint>
#include <cmath>

using namespace std;

namespace {
    enum roundmode_e : uint32_t {
        RNE, RTZ, RDN, RUP, RMM, DYN = 0b111
    };

    enum operation_e : uint32_t {
        FMADD, FNMSUB, ADD, MUL,     // ADDMUL operation group
        DIV, SQRT,                   // DIVSQRT operation group
        SGNJ, MINMAX, CMP, CLASSIFY, // NONCOMP operation group
        F2F, F2I, I2F, CPKAB, CPKCD  // CONV operation group
    };

    enum fp_format_e : uint32_t {
        FP32, FP64, FP16, FP8, FP16ALT
    };

    enum int_format_e : uint32_t {
        INT8, INT16, INT32, INT64
    };

    union ops {
        struct {
            roundmode_e  round_mode :  3;
            operation_e  operation  :  4;
            bool         op_mod     :  1;
            fp_format_e  src_fmt    :  3;
            fp_format_e  dst_fmt    :  3;
            int_format_e int_fmt    :  2;
            bool         vec_op     :  1;
            uint32_t                : 15;
        };
        volatile uint32_t _all;
    };
    static_assert(sizeof(ops) == sizeof(uint32_t));

    union status {
        struct {
            uint8_t nx : 1;
            uint8_t uf : 1;
            uint8_t of : 1;
            uint8_t dz : 1;
            uint8_t nv : 1;
            uint8_t    : 3;
        };
        volatile uint8_t _all;
    };
    static_assert(sizeof(status) == sizeof(uint8_t));
}

extern "C" {
    extern uintptr_t OP0;
    extern uintptr_t OP1;
    extern uintptr_t OP2;
    extern uintptr_t RES;

    extern volatile ops *oper_reg;
    extern volatile status *status_reg;
}

struct FpInit {
    FpInit();
};

struct FType16 {
    using storage = uint16_t;
    using native = void;

    constexpr static auto fp_type = FP16;
};

struct FType32 {
    using storage = uint32_t;
    using native = float;

    constexpr static auto fp_type = FP32;
};

struct FType64 {
    using storage = uint64_t;
    using native = double;

    constexpr static auto fp_type = FP64;
};

struct FType8 {
    using storage = uint8_t;
    using native = void;

    constexpr static auto fp_type = FP8;
};

struct FType16alt {
    using storage = uint16_t;
    using native = void;

    constexpr static auto fp_type = FP16ALT;
};

template<typename FT>
class Fp {
private:
    using storage_t = typename FT::storage;
    storage_t storage;

public:
    template<typename FO> requires (!is_same_v<FT, FO>)
    Fp(const Fp<FO> &other) {
        *reinterpret_cast<volatile typename FO::storage *>(OP0) = other.storage;
        ops oper{{.operation = F2F, .src_fmt = FO::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(float fp32) {
        *reinterpret_cast<volatile float *>(OP0) = fp32;
        ops oper{{.operation = F2F, .src_fmt = FP32, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(double fp64) {
        *reinterpret_cast<volatile double *>(OP0) = fp64;
        ops oper{{.operation = F2F, .src_fmt = FP64, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(signed long int64) {
        *reinterpret_cast<volatile signed long *>(OP0) = int64;
        ops oper{{.operation = I2F, .dst_fmt = FT::fp_type, .int_fmt = INT64}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(unsigned long uint64) {
        *reinterpret_cast<volatile unsigned long *>(OP0) = uint64;
        ops oper{{.operation = I2F, .op_mod = true, .dst_fmt = FT::fp_type, .int_fmt = INT64}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(signed int int32) {
        *reinterpret_cast<volatile signed int *>(OP0) = int32;
        ops oper{{.operation = I2F, .dst_fmt = FT::fp_type, .int_fmt = INT32}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(unsigned int uint32) {
        *reinterpret_cast<volatile unsigned int *>(OP0) = uint32;
        ops oper{{.operation = I2F, .op_mod = true, .dst_fmt = FT::fp_type, .int_fmt = INT32}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(signed short int16) {
        *reinterpret_cast<volatile signed short *>(OP0) = int16;
        ops oper{{.operation = I2F, .dst_fmt = FT::fp_type, .int_fmt = INT16}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(unsigned short uint16) {
        *reinterpret_cast<volatile unsigned short *>(OP0) = uint16;
        ops oper{{.operation = I2F, .op_mod = true, .dst_fmt = FT::fp_type, .int_fmt = INT16}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(signed char int8) {
        *reinterpret_cast<volatile signed char *>(OP0) = int8;
        ops oper{{.operation = I2F, .dst_fmt = FT::fp_type, .int_fmt = INT8}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    Fp(unsigned char uint8) {
        *reinterpret_cast<volatile unsigned char *>(OP0) = uint8;
        ops oper{{.operation = I2F, .op_mod = true, .dst_fmt = FT::fp_type, .int_fmt = INT8}};
        oper_reg->_all = oper._all;
        storage = *reinterpret_cast<volatile storage_t *>(RES);
    }

    explicit Fp() noexcept : storage(0) {}
    Fp(const Fp<FT> &other) noexcept : storage(other.storage) {}
    Fp(Fp<FT> &&other) noexcept : storage(other.storage) {}

    Fp<FT> operator =(const Fp<FT> &other) noexcept {
        storage = other.storage;
        return *this;
    }

    Fp<FT> operator =(Fp<FT> &&other) noexcept {
        storage = other.storage;
        return *this;
    }

private:
    constexpr Fp(storage_t raw, bool _b) : storage(raw) {}

public:
    Fp(long double float80) : Fp(static_cast<double>(float80)) {}

    constexpr ~Fp() = default;

    constexpr static Fp<FT> raw(storage_t r) {
        return Fp<FT>(r, true);
    }

    Fp<FT> operator +(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP1) = storage;
        *reinterpret_cast<volatile storage_t *>(OP2) = rhs.storage;
        ops oper{{.operation = ADD, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES), true);
    }

    Fp<FT> operator -(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP1) = storage;
        *reinterpret_cast<volatile storage_t *>(OP2) = rhs.storage;
        ops oper{{.operation = ADD, .op_mod = true, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES), true);
    }

    Fp<FT> operator *(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = rhs.storage;
        ops oper{{.operation = MUL, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES), true);
    }

    Fp<FT> operator /(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = rhs.storage;
        ops oper{{.operation = DIV, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES), true);
    }

    static Fp<FT> abs(const Fp<FT> &rhs) {
        return Fp<FT>(rhs.storage & ~(1LL << (sizeof(storage_t)*8-1)), true);
    }

    static Fp<FT> fma(const Fp<FT> &a, const Fp<FT> &b, const Fp<FT> &c) {
        *reinterpret_cast<volatile storage_t *>(OP0) = a.storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = b.storage;
        *reinterpret_cast<volatile storage_t *>(OP2) = c.storage;
        ops oper{{.operation = FMADD, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES));
    }

    static Fp<FT> sqrt(const Fp<FT> &rhs) {
        *reinterpret_cast<volatile storage_t *>(OP0) = rhs.storage;
        ops oper{{.operation = SQRT, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return Fp<FT>(*reinterpret_cast<volatile storage_t *>(RES), true);
    }

    operator double() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2F, .src_fmt = FT::fp_type, .dst_fmt = FP64}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile double *>(RES);
    }

    operator float() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2F, .src_fmt = FT::fp_type, .dst_fmt = FP32}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile float *>(RES);
    }

    operator signed long() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .src_fmt = FT::fp_type, .int_fmt = INT64}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile signed long *>(RES);
    }

    operator unsigned long() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .op_mod = true, .src_fmt = FT::fp_type, .int_fmt = INT64}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile unsigned long *>(RES);
    }

    operator signed int() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .src_fmt = FT::fp_type, .int_fmt = INT32}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile signed int *>(RES);
    }

    operator unsigned int() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .op_mod = true, .src_fmt = FT::fp_type, .int_fmt = INT32}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile unsigned int *>(RES);
    }

    operator signed short() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .src_fmt = FT::fp_type, .int_fmt = INT16}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile signed short *>(RES);
    }

    operator unsigned short() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .op_mod = true, .src_fmt = FT::fp_type, .int_fmt = INT16}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile unsigned short *>(RES);
    }

    operator signed char() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .src_fmt = FT::fp_type, .int_fmt = INT8}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile signed char *>(RES);
    }

    operator unsigned char() const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        ops oper{{.operation = F2I, .op_mod = true, .src_fmt = FT::fp_type, .int_fmt = INT8}};
        oper_reg->_all = oper._all;
        return *reinterpret_cast<volatile unsigned char *>(RES);
    }

    // Rounding mode defines comparison: RNE: this <= rhs, RTZ: this < rhs, RDN: this == rhs
    bool operator <=(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = rhs.storage;
        ops oper{{.round_mode = RNE, .operation = CMP, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return !!*reinterpret_cast<volatile bool *>(RES);
    }

    bool operator <(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = rhs.storage;
        ops oper{{.round_mode = RTZ, .operation = CMP, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return !!*reinterpret_cast<volatile bool *>(RES);
    }

    bool operator ==(const Fp<FT> &rhs) const {
        *reinterpret_cast<volatile storage_t *>(OP0) = storage;
        *reinterpret_cast<volatile storage_t *>(OP1) = rhs.storage;
        ops oper{{.round_mode = RDN, .operation = CMP, .src_fmt = FT::fp_type, .dst_fmt = FT::fp_type}};
        oper_reg->_all = oper._all;
        return !!*reinterpret_cast<volatile bool *>(RES);
    }

    // Unary
    constexpr Fp<FT> operator -() const {
        return Fp<FT>(storage ^ (1LL << (sizeof(storage_t)*8-1)), true);
    }

    friend Fp<FT> operator +(const Fp<FT> &rhs) {
        return rhs;
    }

    bool operator >=(const Fp<FT> &rhs) const {
        return !operator <(rhs);
    }

    bool operator >(const Fp<FT> &rhs) const {
        return !operator <=(rhs);
    }

    bool operator !=(const Fp<FT> &rhs) const {
        return !operator ==(rhs);
    }

    // Assign-op
    Fp<FT> operator +=(const Fp<FT> &rhs) {
        storage = (*this + rhs).storage;
        return *this;
    }

    Fp<FT> operator -=(const Fp<FT> &rhs) {
        storage = (*this - rhs).storage;
        return *this;
    }

    Fp<FT> operator *=(const Fp<FT> &rhs) {
        storage = (*this * rhs).storage;
        return *this;
    }

    Fp<FT> operator /=(const Fp<FT> &rhs) {
        storage = (*this / rhs).storage;
        return *this;
    }

    // Type promotion

    template<typename T> requires (is_arithmetic_v<T>)
    Fp<FT> operator +(const T &rhs) const {
        return operator +(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend Fp<FT> operator +(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator +(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    Fp<FT> operator -(const T &rhs) const {
        return operator -(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend Fp<FT> operator -(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator -(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    Fp<FT> operator *(const T &rhs) const {
        return operator *(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend Fp<FT> operator *(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator *(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    Fp<FT> operator /(const T &rhs) const {
        return operator /(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend Fp<FT> operator /(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator /(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator <=(const T &rhs) const {
        return operator <=(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator <=(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator <=(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator <(const T &rhs) const {
        return operator <(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator <(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator <(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator >=(const T &rhs) const {
        return operator >=(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator >=(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator >=(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator >(const T &rhs) const {
        return operator >(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator >(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator >(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator ==(const T &rhs) const {
        return operator ==(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator ==(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator ==(rhs);
    }

    template<typename T> requires (is_arithmetic_v<T>)
    bool operator !=(const T &rhs) const {
        return operator !=(Fp<FT>(rhs));
    }

    template<typename T> requires (is_arithmetic_v<T>)
    friend bool operator !=(const T &lhs, const Fp<FT> &rhs) {
        return Fp<FT>(lhs).operator !=(rhs);
    }

    // For storage access
    template<typename> friend class Fp;
};

using Fp16  = Fp<FType16>;
using Fp32  = Fp<FType32>;
using Fp64  = Fp<FType64>;
using Fp8   = Fp<FType8>;
using Fp16a = Fp<FType16alt>;

static_assert(sizeof(Fp32) == sizeof(float));

// Convert Fp<FT> to double for printf

template<typename T>
struct printf_conv {
    using type = T;
};

template<typename FT>
struct printf_conv<Fp<FT>> {
    using type = double;
};

template<typename T>
using printf_t = typename printf_conv<T>::type;

template<typename... Ts>
int printf(const char* format, Ts... pack) {
    return std::printf(format, static_cast<printf_t<Ts>>(pack)...);
}

template<typename... Ts>
int fprintf(FILE* fp, const char* format, Ts... pack) {
    return std::fprintf(fp, format, static_cast<printf_t<Ts>>(pack)...);
}

// For Clang: complex<Fp>::abs
template<typename FT>
Fp<FT> hypot(const Fp<FT> &real, const Fp<FT> &imag) {
    return Fp<FT>::sqrt(real*real + imag*imag);
}

// For GCC
template<typename FT>
Fp<FT> sqrt(const Fp<FT> &val) {
    return Fp<FT>::sqrt(val);
}

template<typename FT>
Fp<FT> abs(const Fp<FT> &val) {
    return Fp<FT>::abs(val);
}

// Unqualified lookup
template<typename FT>
Fp<FT> log(const Fp<FT> &val) {
    return Fp<FT>(std::log(static_cast<double>(val)));
}

template<typename FT>
Fp<FT> exp(const Fp<FT> &val) {
    return Fp<FT>(std::exp(static_cast<double>(val)));
}

template<typename FT>
Fp<FT> fabs(const Fp<FT> &val) {
    return Fp<FT>::abs(val);
}
