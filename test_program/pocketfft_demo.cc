#include <complex>
#include <cmath>
#include <vector>
#include <iostream>
#include "pocketfft_hdronly.h"
#include "fp_class.hpp"

using namespace std;
using namespace pocketfft;

template<typename T> void crand(vector<complex<T>> &v) {
    for (auto & i:v)
        i = complex<T>(drand48()-0.5, drand48()-0.5);
}

template<typename T1, typename T2> long double l2err(const vector<T1> &v1, const vector<T2> &v2) {
    double sum1=0, sum2=0;
    for (size_t i=0; i<v1.size(); ++i) {
        double dr = static_cast<double>(v1[i].real())-static_cast<double>(v2[i].real()),
               di = static_cast<double>(v1[i].imag())-static_cast<double>(v2[i].imag());
        double t1 = sqrt(dr*dr+di*di), t2 = abs(v1[i]);
        sum1 += t1*t1;
        sum2 += t2*t2;
    }
    return sqrt(sum1/sum2);
}

int main() {
    for (int x = 0; x < 10; x++) {
        constexpr size_t len=65536;
        shape_t shape{len};
        stride_t stridef16(shape.size()),
                 stridef32(shape.size()),
                 stridef64(shape.size()),
                 strided(shape.size());
        size_t tmpf16=sizeof(complex<Fp16>),
               tmpf32=sizeof(complex<Fp32>),
               tmpf64=sizeof(complex<Fp64>),
               tmpd=sizeof(complex<double>);
        for (int i=shape.size()-1; i>=0; --i) {
            stridef16[i]=tmpf16;
            tmpf16*=shape[i];
            stridef32[i]=tmpf32;
            tmpf32*=shape[i];
            stridef64[i]=tmpf64;
            tmpf64*=shape[i];
            strided[i]=tmpd;
            tmpd*=shape[i];
        }
        size_t ndata=1;
        for (size_t i=0; i<shape.size(); ++i)
            ndata*=shape[i];

        vector<complex<Fp16>> dataf16(ndata);
        vector<complex<Fp32>> dataf32(ndata);
        vector<complex<Fp64>> dataf64(ndata);
        vector<complex<double>> datad(ndata);
        crand(dataf16);
        for (size_t i=0; i<ndata; ++i) {
            dataf32[i] = complex<Fp16>{dataf16[i].real(), dataf16[i].imag()}; // Explicit constructor for GCC
            dataf64[i] = complex<Fp32>{dataf16[i].real(), dataf16[i].imag()};
            datad[i] = complex<double>{dataf16[i].real(), dataf16[i].imag()};
        }
        shape_t axes;
        for (size_t i=0; i<shape.size(); ++i)
            axes.push_back(i);
        auto resd = datad;
        auto resf16 = dataf16;
        auto resf32 = dataf32;
        auto resf64 = dataf64;
        c2c(shape, strided, strided, axes, FORWARD,
                datad.data(), resd.data(), 1.);
        c2c(shape, stridef16, stridef16, axes, FORWARD,
                dataf16.data(), resf16.data(), Fp16(1.f));
        c2c(shape, stridef32, stridef32, axes, FORWARD,
                dataf32.data(), resf32.data(), Fp32(1.f));
        c2c(shape, stridef64, stridef64, axes, FORWARD,
                dataf64.data(), resf64.data(), Fp64(1.f));
        cout << l2err(resd, resf16) << " " << l2err(resd, resf32) << " " << l2err(resd, resf64) << endl;
    }
}
