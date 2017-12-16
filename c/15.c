#include <stdint.h>

static uint64_t next(uint64_t g, uint16_t factor) {
  g *= factor;
  // This is an optimised way to take remainder modulo a Mersenne prime.
  // But newer versions of GCC might already know how to optimise that!
  // So might not be necessary to explicitly do this.
  while (g >= 0x7fffffff) {
    g = (g & 0x7fffffff) + (g >> 31);
  }
  return g;
}

static uint64_t part(uint64_t a, uint64_t b, uint64_t limit, uint8_t mod_a, uint8_t mod_b) {
  uint64_t c = 0;
  for (uint64_t i = 0; i < limit; ++i) {
    do {
      a = next(a, 16807);
    } while (a % mod_a != 0);
    do {
      b = next(b, 48271);
    } while (b % mod_b != 0);
    if ((a & 0xffff) == (b & 0xffff)) {
      c += 1;
    }
  }
  return c;
}

uint64_t part1(uint64_t a, uint64_t b) {
  return part(a, b, 40000000, 1, 1);
}

uint64_t part2(uint64_t a, uint64_t b) {
  return part(a, b, 5000000, 4, 8);
}
