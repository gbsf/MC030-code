// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

#include <vector>

#include <cstdio>

#include "fp_class.hpp"

using namespace std;

#ifndef FPTYPE
#define FPTYPE Fp16
#endif

constexpr float WEIGHT1 = 1.f;
constexpr float WEIGHT2 = 2.f;

constexpr size_t STRIDE = 3;

constinit double scale_factor = sqrt(32.);

void sobel_x(size_t x, size_t y, const vector<FPTYPE> &input, vector<FPTYPE> &output) {
    // Do corners first
    output[0] = input[STRIDE  ]*WEIGHT2+input[(x+1)*STRIDE  ]*WEIGHT1;
    output[1] = input[STRIDE+1]*WEIGHT2+input[(x+1)*STRIDE+1]*WEIGHT1;
    output[2] = input[STRIDE+2]*WEIGHT2+input[(x+1)*STRIDE+2]*WEIGHT1;

    output[(x-1)*STRIDE  ] = -input[(x-2)*STRIDE  ]*WEIGHT2-input[(2*x-2)*STRIDE  ]*WEIGHT1;
    output[(x-1)*STRIDE+1] = -input[(x-2)*STRIDE+1]*WEIGHT2-input[(2*x-2)*STRIDE+1]*WEIGHT1;
    output[(x-1)*STRIDE+2] = -input[(x-2)*STRIDE+2]*WEIGHT2-input[(2*x-2)*STRIDE+2]*WEIGHT1;

    output[(x*(y-1))*STRIDE  ] = input[(x*(y-2)+1)*STRIDE  ]*WEIGHT1+input[(x*(y-1)+1)*STRIDE  ]*WEIGHT2;
    output[(x*(y-1))*STRIDE+1] = input[(x*(y-2)+1)*STRIDE+1]*WEIGHT1+input[(x*(y-1)+1)*STRIDE+1]*WEIGHT2;
    output[(x*(y-1))*STRIDE+2] = input[(x*(y-2)+1)*STRIDE+2]*WEIGHT1+input[(x*(y-1)+1)*STRIDE+2]*WEIGHT2;

    output[(x*y-1)*STRIDE  ] = -input[(x*(y-1)-2)*STRIDE  ]*WEIGHT1-input[(x*y-2)*STRIDE  ]*WEIGHT2;
    output[(x*y-1)*STRIDE+1] = -input[(x*(y-1)-2)*STRIDE+1]*WEIGHT1-input[(x*y-2)*STRIDE+1]*WEIGHT2;
    output[(x*y-1)*STRIDE+2] = -input[(x*(y-1)-2)*STRIDE+2]*WEIGHT1-input[(x*y-2)*STRIDE+2]*WEIGHT2;

    // Do edges second
    for (size_t t = 1; t < x-1; t++) {
        output[t*STRIDE  ] = (input[(t+1)*STRIDE  ]-input[(t-1)*STRIDE  ])*WEIGHT2+(input[(x+t+1)*STRIDE  ]-input[(x+t-1)*STRIDE  ])*WEIGHT1; // Top
        output[t*STRIDE+1] = (input[(t+1)*STRIDE+1]-input[(t-1)*STRIDE+1])*WEIGHT2+(input[(x+t+1)*STRIDE+1]-input[(x+t-1)*STRIDE+1])*WEIGHT1;
        output[t*STRIDE+2] = (input[(t+1)*STRIDE+2]-input[(t-1)*STRIDE+2])*WEIGHT2+(input[(x+t+1)*STRIDE+2]-input[(x+t-1)*STRIDE+2])*WEIGHT1;

        output[(x*(y-1)+t)*STRIDE  ] = (input[(x*(y-2)+t+1)*STRIDE  ]-input[(x*(y-2)+t-1)*STRIDE  ])*WEIGHT2+(input[(x*(y-1)+t+1)*STRIDE  ]-input[(x*(y-1)+t-1)*STRIDE  ])*WEIGHT1; // Bottom
        output[(x*(y-1)+t)*STRIDE+1] = (input[(x*(y-2)+t+1)*STRIDE+1]-input[(x*(y-2)+t-1)*STRIDE+1])*WEIGHT2+(input[(x*(y-1)+t+1)*STRIDE+1]-input[(x*(y-1)+t-1)*STRIDE+1])*WEIGHT1;
        output[(x*(y-1)+t)*STRIDE+2] = (input[(x*(y-2)+t+1)*STRIDE+2]-input[(x*(y-2)+t-1)*STRIDE+2])*WEIGHT2+(input[(x*(y-1)+t+1)*STRIDE+2]-input[(x*(y-1)+t-1)*STRIDE+2])*WEIGHT1;
    }

    for (size_t t = 1; t < y-1; t++) {
        output[(x*t)*STRIDE  ] = input[(x*(t-1)+1)*STRIDE  ]*WEIGHT1+input[(x*t+1)*STRIDE  ]*WEIGHT2+input[(x*(t+1)+1)*STRIDE  ]*WEIGHT1; // Left
        output[(x*t)*STRIDE+1] = input[(x*(t-1)+1)*STRIDE+1]*WEIGHT1+input[(x*t+1)*STRIDE+1]*WEIGHT2+input[(x*(t+1)+1)*STRIDE+1]*WEIGHT1;
        output[(x*t)*STRIDE+2] = input[(x*(t-1)+1)*STRIDE+2]*WEIGHT1+input[(x*t+1)*STRIDE+2]*WEIGHT2+input[(x*(t+1)+1)*STRIDE+2]*WEIGHT1;

        output[(x*(t+1)-1)*STRIDE  ] = -input[(x*t-2)*STRIDE  ]*WEIGHT1-input[(x*(t+1)-2)*STRIDE  ]*WEIGHT2-input[(x*(t+2)-2)*STRIDE  ]*WEIGHT1; // Right
        output[(x*(t+1)-1)*STRIDE+1] = -input[(x*t-2)*STRIDE+1]*WEIGHT1-input[(x*(t+1)-2)*STRIDE+1]*WEIGHT2-input[(x*(t+2)-2)*STRIDE+1]*WEIGHT1;
        output[(x*(t+1)-1)*STRIDE+2] = -input[(x*t-2)*STRIDE+2]*WEIGHT1-input[(x*(t+1)-2)*STRIDE+2]*WEIGHT2-input[(x*(t+2)-2)*STRIDE+2]*WEIGHT1;
    }

    // Do the middle
    for (size_t j = 1; j < y-1; j++)
        for (size_t i = 1; i < x-1; i++) {
            // R
            output[(j*x+i)*STRIDE  ] = (input[((j-1)*x+(i+1))*STRIDE]-input[((j-1)*x+(i-1))*STRIDE])*WEIGHT1 +
                                       (input[(j*x+(i+1))*STRIDE]-input[(j*x+(i-1))*STRIDE])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE]-input[((j+1)*x+(i-1))*STRIDE])*WEIGHT1;
            // G
            output[(j*x+i)*STRIDE+1] = (input[((j-1)*x+(i+1))*STRIDE+1]-input[((j-1)*x+(i-1))*STRIDE+1])*WEIGHT1 +
                                       (input[(j*x+(i+1))*STRIDE+1]-input[(j*x+(i-1))*STRIDE+1])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE+1]-input[((j+1)*x+(i-1))*STRIDE+1])*WEIGHT1;
            // B
            output[(j*x+i)*STRIDE+2] = (input[((j-1)*x+(i+1))*STRIDE+2]-input[((j-1)*x+(i-1))*STRIDE+2])*WEIGHT1 +
                                       (input[(j*x+(i+1))*STRIDE+2]-input[(j*x+(i-1))*STRIDE+2])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE+2]-input[((j+1)*x+(i-1))*STRIDE+2])*WEIGHT1;
        }
}

void sobel_y(size_t x, size_t y, const vector<FPTYPE> &input, vector<FPTYPE> &output) {
    // Do corners first
    output[0] = input[x*STRIDE  ]*WEIGHT2+input[(x+1)*STRIDE  ]*WEIGHT1;
    output[1] = input[x*STRIDE+1]*WEIGHT2+input[(x+1)*STRIDE+1]*WEIGHT1;
    output[2] = input[x*STRIDE+2]*WEIGHT2+input[(x+1)*STRIDE+2]*WEIGHT1;

    output[(x-1)*STRIDE  ] = input[(2*x-2)*STRIDE  ]*WEIGHT1+input[(2*x-1)*STRIDE  ]*WEIGHT2;
    output[(x-1)*STRIDE+1] = input[(2*x-2)*STRIDE+1]*WEIGHT1+input[(2*x-1)*STRIDE+1]*WEIGHT2;
    output[(x-1)*STRIDE+2] = input[(2*x-2)*STRIDE+2]*WEIGHT1+input[(2*x-1)*STRIDE+2]*WEIGHT2;

    output[(x*(y-1))*STRIDE  ] = -input[(x*(y-2))*STRIDE  ]*WEIGHT2-input[(x*(y-2)+1)*STRIDE  ]*WEIGHT1;
    output[(x*(y-1))*STRIDE+1] = -input[(x*(y-2))*STRIDE+1]*WEIGHT2-input[(x*(y-2)+1)*STRIDE+1]*WEIGHT1;
    output[(x*(y-1))*STRIDE+2] = -input[(x*(y-2))*STRIDE+2]*WEIGHT2-input[(x*(y-2)+1)*STRIDE+2]*WEIGHT1;

    output[(x*y-1)*STRIDE  ] = -input[(x*(y-1)-2)*STRIDE  ]*WEIGHT1-input[(x*(y-1)-1)*STRIDE  ]*WEIGHT2;
    output[(x*y-1)*STRIDE+1] = -input[(x*(y-1)-2)*STRIDE+1]*WEIGHT1-input[(x*(y-1)-1)*STRIDE+1]*WEIGHT2;
    output[(x*y-1)*STRIDE+2] = -input[(x*(y-1)-2)*STRIDE+2]*WEIGHT1-input[(x*(y-1)-1)*STRIDE+2]*WEIGHT2;

    // Do edges second
    for (size_t t = 1; t < x-1; t++) {
        output[t*STRIDE  ] = input[(x+t-1)*STRIDE  ]*WEIGHT1+input[(x+t)*STRIDE  ]*WEIGHT2+input[(x+t+1)*STRIDE  ]*WEIGHT1; // Top
        output[t*STRIDE+1] = input[(x+t-1)*STRIDE+1]*WEIGHT1+input[(x+t)*STRIDE+1]*WEIGHT2+input[(x+t+1)*STRIDE+1]*WEIGHT1;
        output[t*STRIDE+2] = input[(x+t-1)*STRIDE+2]*WEIGHT1+input[(x+t)*STRIDE+2]*WEIGHT2+input[(x+t+1)*STRIDE+2]*WEIGHT1;

        output[(x*(y-1)+t)*STRIDE  ] = -input[(x*(y-2)+t-1)*STRIDE  ]*WEIGHT1-input[(x*(y-2)+t)*STRIDE  ]*WEIGHT2-input[(x*(y-2)+t+1)*STRIDE  ]*WEIGHT1; // Bottom
        output[(x*(y-1)+t)*STRIDE+1] = -input[(x*(y-2)+t-1)*STRIDE+1]*WEIGHT1-input[(x*(y-2)+t)*STRIDE+1]*WEIGHT2-input[(x*(y-2)+t+1)*STRIDE+1]*WEIGHT1;
        output[(x*(y-1)+t)*STRIDE+2] = -input[(x*(y-2)+t-1)*STRIDE+2]*WEIGHT1-input[(x*(y-2)+t)*STRIDE+2]*WEIGHT2-input[(x*(y-2)+t+1)*STRIDE+2]*WEIGHT1;
    }

    for (size_t t = 1; t < y-1; t++) {
        output[(x*t)*STRIDE  ] = (input[(x*(t+1))*STRIDE  ]-input[(x*(t-1))*STRIDE  ])*WEIGHT2+(input[(x*(t+1)+1)*STRIDE  ]-input[(x*(t-1)+1)*STRIDE  ])*WEIGHT1; // Left
        output[(x*t)*STRIDE+1] = (input[(x*(t+1))*STRIDE+1]-input[(x*(t-1))*STRIDE+1])*WEIGHT2+(input[(x*(t+1)+1)*STRIDE+1]-input[(x*(t-1)+1)*STRIDE+1])*WEIGHT1;
        output[(x*t)*STRIDE+2] = (input[(x*(t+1))*STRIDE+2]-input[(x*(t-1))*STRIDE+2])*WEIGHT2+(input[(x*(t+1)+1)*STRIDE+2]-input[(x*(t-1)+1)*STRIDE+2])*WEIGHT1;

        output[(x*(t+1)-1)*STRIDE  ] = (input[(x*(t+2)-2)*STRIDE  ]-input[(x*t-2)*STRIDE  ])*WEIGHT1+(input[(x*(t+2)-1)*STRIDE  ]-input[(x*t-1)*STRIDE  ])*WEIGHT2; // Right
        output[(x*(t+1)-1)*STRIDE+1] = (input[(x*(t+2)-2)*STRIDE+1]-input[(x*t-2)*STRIDE+1])*WEIGHT1+(input[(x*(t+2)-1)*STRIDE+1]-input[(x*t-1)*STRIDE+1])*WEIGHT2;
        output[(x*(t+1)-1)*STRIDE+2] = (input[(x*(t+2)-2)*STRIDE+2]-input[(x*t-2)*STRIDE+2])*WEIGHT1+(input[(x*(t+2)-1)*STRIDE+2]-input[(x*t-1)*STRIDE+2])*WEIGHT2;
    }

    // Do the middle
    for (size_t j = 1; j < y-1; j++)
        for (size_t i = 1; i < x-1; i++) {
            // R
            output[(j*x+i)*STRIDE  ] = (input[((j+1)*x+(i-1))*STRIDE]-input[((j-1)*x+(i-1))*STRIDE])*WEIGHT1 +
                                       (input[((j+1)*x+i)*STRIDE]-input[((j-1)*x+i)*STRIDE])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE]-input[((j-1)*x+(i+1))*STRIDE])*WEIGHT1;

            // G
            output[(j*x+i)*STRIDE+1] = (input[((j+1)*x+(i-1))*STRIDE+1]-input[((j-1)*x+(i-1))*STRIDE+1])*WEIGHT1 +
                                       (input[((j+1)*x+i)*STRIDE+1]-input[((j-1)*x+i)*STRIDE+1])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE+1]-input[((j-1)*x+(i+1))*STRIDE+1])*WEIGHT1;

            // B
            output[(j*x+i)*STRIDE+2] = (input[((j+1)*x+(i-1))*STRIDE+2]-input[((j-1)*x+(i-1))*STRIDE+2])*WEIGHT1 +
                                       (input[((j+1)*x+i)*STRIDE+2]-input[((j-1)*x+i)*STRIDE+2])*WEIGHT2 +
                                       (input[((j+1)*x+(i+1))*STRIDE+2]-input[((j-1)*x+(i+1))*STRIDE+2])*WEIGHT1;
        }
}

int main(int argc, char *argv[]) {

    if (argc != 5) {
        fprintf(stderr, "Usage: sobel <x> <y> <input> <output>\n");
        return 10;
    }

    size_t x = strtoul(argv[1], nullptr, 10);
    size_t y = strtoul(argv[2], nullptr, 10);

    FILE* input = fopen(argv[3], "r");
    if (!input) {
        perror("Cannot open input file");
        exit(1);
    }
    FILE* output = fopen(argv[4], "w");
    if (!output) {
        perror("Cannot open output file");
        exit(1);
    }

    vector<FPTYPE> input_vector(x*y*STRIDE);
    vector<FPTYPE> output_vector(x*y*STRIDE);
    vector<FPTYPE> output_x_vector(x*y*STRIDE);
    vector<FPTYPE> output_y_vector(x*y*STRIDE);
    size_t readb = fread(input_vector.data(), sizeof(FPTYPE), x*y*STRIDE, input);
    if (errno) {
        perror("Cannot read input file");
        exit(1);
    }
    if (readb != x*y*STRIDE) {
        fprintf(stderr, "Couldn't read entire file\n");
        exit(1);
    }
    if (fgetc(input) != EOF) {
        fprintf(stderr, "Input has extra bytes\n");
        exit(1);
    }
    fclose(input);

    sobel_x(x, y, input_vector, output_x_vector);
    sobel_y(x, y, input_vector, output_y_vector);
    
    for (size_t j = 0; j < y; j++)
        for (size_t i = 0; i < x; i++) {
            output_vector[(j*x+i)*STRIDE  ] = hypot(output_x_vector[(j*x+i)*STRIDE  ], output_y_vector[(j*x+i)*STRIDE  ])/scale_factor; // R
            output_vector[(j*x+i)*STRIDE+1] = hypot(output_x_vector[(j*x+i)*STRIDE+1], output_y_vector[(j*x+i)*STRIDE+1])/scale_factor; // G
            output_vector[(j*x+i)*STRIDE+2] = hypot(output_x_vector[(j*x+i)*STRIDE+2], output_y_vector[(j*x+i)*STRIDE+2])/scale_factor; // B
        }

    int writeb = fwrite(output_vector.data(), sizeof(FPTYPE), x*y*STRIDE, output);
    if (errno) {
        perror("Cannot write output file");
        exit(1);
    }
    if (writeb != x*y*STRIDE) {
        fprintf(stderr, "Couldn't write entire file\n");
        exit(1);
    }
    fclose(output);

    return 0;
}
