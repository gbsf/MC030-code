#!/bin/bash

[[ -f lena_std.tif ]] || exit 1
[[ -f 'GIMP built-in Linear sRGB.icc' ]] || exit 1

function to_rgb {
    width=$1
    if ! [[ -f lena_std_f$width.tif ]]; then
        convert lena_std.tif \
            -define quantum:format=floating-point \
            -depth $width \
            -colorspace RGB \
            -profile 'GIMP built-in Linear sRGB.icc' \
            lena_std_f$width.tif
        convert lena_std_f$width.tif \
            -define quantum:format=floating-point \
            -depth $width \
            lena_std_f$width.rgb
    fi
}

function from_rgb {
    width=$1
    name=$2
    if [[ -z $name ]]; then
        name=f$width
    fi
    if [[ -f lena_sobel_$name.rgb ]]; then
        convert -set colorspace RGB -size 512x512 \
            -define quantum:format=floating-point \
            -depth $width lena_sobel_$name.rgb \
            -define quantum:format=floating-point \
            -depth $width -colorspace RGB \
            -profile 'GIMP built-in Linear sRGB.icc' \
            lena_sobel_$name.tif
    fi
}

function compare_sobel {
    width=$1
    name=$2
    if [[ -z $name ]]; then
        name=f$width
    fi
    [[ -f lena_sobel_$name.tif ]] || return 1
    [[ -f lena_sobel_gimp_f$width.tif ]] || return 1
    convert -set colorspace RGB "lena_sobel_$name.tif[510x510+1+1]" +repage -depth 16 -colorspace sRGB -strip lena_fpnew_$name.png
    convert -set colorspace RGB "lena_sobel_gimp_f$width.tif[510x510+2+2]" +repage -depth 16 -colorspace sRGB -strip lena_gimp_f$width.png
    echo -n "Structural Similarity ($width-bits): "
    compare lena_fpnew_$name.png lena_gimp_f$width.png -metric SSIM lena_compare_$name.png
    echo -en "\nStructural Similarity ($width-bits) (no-conversion): "
    compare "lena_sobel_$name.tif[510x510+1+1]" "lena_sobel_gimp_f$width.tif[510x510+2+2]" -metric SSIM lena_compare_${name}_noconv.png
    echo
}

to_rgb 16
to_rgb 32
to_rgb 64

from_rgb 16
from_rgb 32
from_rgb 64
from_rgb 32 float
from_rgb 64 double

compare_sobel 16 || true
compare_sobel 32 || true
compare_sobel 64 || true
compare_sobel 32 float || true
compare_sobel 64 double || true

echo "Cross Compare"
echo -n "Fp16<->GIMP64 "; compare lena_fpnew_f16.png lena_gimp_f64.png -metric SSIM lena_compare_16_64.png; echo
echo -n "Fp16<->FUZZ64 "; compare -fuzz 0.1% lena_fpnew_f16.png lena_gimp_f64.png -metric SSIM lena_compare_16_64_fuzz.png; echo
echo -n "Fp32<->GIMP64 "; compare lena_fpnew_f32.png lena_gimp_f64.png -metric SSIM lena_compare_32_64.png; echo

echo "Direct"
echo -n "Fp16<D>GIMP64 "; compare "lena_sobel_f16.tif[510x510+1+1]"  "lena_sobel_gimp_f64.tif[510x510+2+2]" -metric SSIM lena_compare_16_64_noconv.png; echo
echo -n "Fp32<D>GIMP64 "; compare "lena_sobel_f32.tif[510x510+1+1]"  "lena_sobel_gimp_f64.tif[510x510+2+2]" -metric SSIM lena_compare_32_64_noconv.png; echo

for png in *.png; do
    [[ $png =~ .*_indexed.png$ ]] && continue
    convert $png +dither -colors 256 -type Palette PNG8:${png/%.png/_indexed.png}
done
