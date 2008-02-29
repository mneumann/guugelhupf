/*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 */

#include "libmlton.h"

unsigned long
sdbm_hash(Pointer str) {
  unsigned long hash = 0;
  int length = GC_arrayNumElements(str);
  
  while (length--) 
    hash = (*((unsigned char*)str)++) + (hash << 6) + (hash << 16) - hash;

  return hash;
}
