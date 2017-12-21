#include <stddef.h>

void twist(unsigned char buf[], unsigned char lengths[], size_t nlengths, size_t nrounds) {
  unsigned char pos = 0;
  unsigned char skip_size = 0;

  for (size_t round = 0; round < nrounds; ++round) {
    for (size_t i = 0; i < nlengths; ++i) {
      unsigned char len = lengths[i];
      unsigned char left = pos;
      unsigned char right = left + len - 1;
      for (unsigned char j = 0; j < len / 2; ++j, ++left, --right) {
        unsigned char swap = buf[right];
        buf[right] = buf[left];
        buf[left] = swap;
      }
      pos += len + skip_size;
      ++skip_size;
    }
  }
}
