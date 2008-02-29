/*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 */

#include "libmlton.h"

void
Pack_word(Word val, Pointer str) {
  assert (GC_arrayNumElements(str) >= sizeof(Word));

  *((Word*)str) = val;
}

Word
Unpack_word(Pointer str) {
  assert (GC_arrayNumElements(str) >= sizeof(Word));
  return *((Word*)str);
}
