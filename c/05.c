#include <stddef.h>
#include <limits.h>

static size_t part(int jumps[], size_t len, int min) {
  size_t n = 0;
  for (size_t pc = 0; pc < len; ++n) {
    pc += jumps[pc] > min ? jumps[pc]-- : jumps[pc]++;
  }
  return n;
}

size_t part1(int jumps[], size_t len) {
  return part(jumps, len, INT_MAX);
}

size_t part2(int jumps[], size_t len) {
  return part(jumps, len, 2);
}
