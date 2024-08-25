#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef uint64_t ui;

const int BLOCK_SIZE = 8;

const int RADIX = 1 << BLOCK_SIZE;

const int MASK = RADIX - 1;

void copy(ui *out, ui *in, int len){
    for(int i = 0; i < len; i++){
        out[i] = in[i];
    }
}

void zero_out(int *arr, int len){
    for(int i = 0; i < n; i++){
        arr[i] = 0;
    }
}

ui extract_digit(ui n, int k){
    return (n >> (k * BLOCK_SIZE)) & MASK;
}

int *histogram(ui *arr, int len, int k){
    int *hist = malloc(RADIX * sizeof(int));
    zero_out(hist, RADIX);
    for(int i = 0; i < len; i++){
        ui digit = extract_digit(arr[i], k);
        hist[digit] ++;
    }
    return hist;
}

int *prefixe_sums(int *hist, int len){
    int *sums = malloc(len * sizeof(int));
    int s = 0;
    for(int i = 0; i < len; i++){
        sums[i] = s;
        s += hist[i];
    }
    return sums;
}

void radix_pass(ui *out, ui *in, int len, int k){
    int *hist = histogram(in, len, k);
    int *sums = prefixe_sums(hist, RADIX);
    for(int i = 0; i < len; i++){
        ui digit = extract_digit(in[i], k);
        out[sums[digit]] = in[i];
        sums[digit] ++;
    }
    free(hist);
    free(sums);
}

void radix_sort(ui *in, int len){
    int nb_digits = 1 + (sizeof(ui) * 8 - 1) / BLOCK_SIZE;
    for(int k = 0; k < nb_digits; k++){
        ui *tmp = malloc(len * sizeof(ui));
        radix_pass(tmp, in, len, k);
        copy(in, tmp, len);
        free(tmp);
    }
}

