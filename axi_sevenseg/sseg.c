#include <stdio.h>
#include "sseg.h"

uint32_t sseg_to_int(uint8_t *data) {
  uint32_t res = 0;
  uint8_t digit;
  for (int i=0;i<8;i++) {
    switch (data[i]) {
    case 0x40 : digit = 0x0; break;
    case 0x79 : digit = 0x1; break;
    case 0x24 : digit = 0x2; break;
    case 0x30 : digit = 0x3; break;
    case 0x19 : digit = 0x4; break;
    case 0x12 : digit = 0x5; break;
    case 0x02 : digit = 0x6; break;
    case 0x78 : digit = 0x7; break;
    case 0x00 : digit = 0x8; break;
    case 0x18 : digit = 0x9; break;
    case 0x08 : digit = 0xA; break;
    case 0x03 : digit = 0xB; break;
    case 0x46 : digit = 0xC; break;
    case 0x21 : digit = 0xD; break;
    case 0x06 : digit = 0xE; break;
    case 0x0e : digit = 0xF; break;
    default   : digit = 0x0; printf("Decode error\n");
    }
    res |= digit << (i*4);
  }
  return res;
}

bool do_sseg(sseg_context_t *context, uint8_t an, uint8_t ca) {
  int cur_seg = -1;
  for (int i=0;i<8;i++)
    if ((~an) & (1<<i))
      cur_seg = i;

  if (cur_seg == -1)
    return false;
  if (cur_seg == context->last_seg)
    return false;

  //printf("Seg %d->%d\n", context->last_seg, cur_seg);
  context->last_seg = cur_seg;

  if (ca == context->data[cur_seg])
    return false;

  //printf("Data[%d] %x->%x\n", cur_seg, context->data[cur_seg], ca);
  
  context->data[cur_seg] = ca;
  return true;
}

