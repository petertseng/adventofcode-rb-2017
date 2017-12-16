#!/bin/sh

dir=$(cd "$(dirname "$0")" && pwd)

gcc -std=c99 -O3 -Wall -shared -o $dir/lib15.so -fPIC $dir/15.c
