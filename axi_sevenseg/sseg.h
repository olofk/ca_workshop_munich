#include <stdint.h>

typedef struct {
  uint8_t data[8] = {0};
  int last_seg = -1;
} sseg_context_t;

uint32_t sseg_to_int(uint8_t *data);

bool do_sseg(sseg_context_t *context, uint8_t an, uint8_t ca);
