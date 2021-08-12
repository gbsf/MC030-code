#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo This test suite must be run as root
    exit -1
fi

umask 011

# Sobel
for w in 16 32 64; do
    echo Sobel $w
    ./sobel_Fp$w 512 512 lena_std_f$w.rgb lena_sobel_f$w.rgb
done
# Native types
echo Sobel native
./sobel_float 512 512 lena_std_f32.rgb lena_sobel_float.rgb
./sobel_double 512 512 lena_std_f64.rgb lena_sobel_double.rgb

# PocketFFT
echo PocketFFT
./pocketfft_demo > pocketfft.txt

# Parsec
## simsmall
for w in 16 32 64 16a 8; do
    echo Parsec small $w
    ./blackscholes_Fp$w 1 blackscholes_in_4K.txt blackscholes_f${w}_small.txt || true
done
 Native
for f in float double; do
    echo Parsec small $f
    ./blackscholes_$f 1 blackscholes_in_4K.txt blackscholes_${f}_small.txt || true
done

## simlarge
for w in 16 32 64 16a 8; do # 16
    echo Parsec large $w
    ./blackscholes_Fp$w 1 blackscholes_in_64K.txt blackscholes_f${w}_large.txt || true
done
 Native
for f in float double; do
    echo Parsec large $f
    ./blackscholes_$f 1 blackscholes_in_64K.txt blackscholes_${f}_large.txt || true
done

# Reduced Swaptions
for w in 16 32 64 16a 8; do
    echo Parsec tiny $w
    ./swaptions_Fp$w -ns 32 -sm 1000 -nt 1 -sd 1235627 > swaptions_f${w}_tiny.txt 2>&1 || true
done
for f in float double; do
    echo Parsec tiny $f
    ./swaptions_$f -ns 32 -sm 1000 -nt 1 -sd 1235627 > swaptions_${f}_tiny.txt 2>&1 || true
done

# Paranoia
for w in 16 32 64 16a; do
    echo Paranoia $w
    ./paranoia_Fp$w > paranoia$w.txt
done

# Fp64 coverage test
echo Coverage
./cover > cover_Fp64.txt
