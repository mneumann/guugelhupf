#include "libmlton.h"

void
Pack_word(Word db, Pointer str) {
  assert (GC_arrayNumElements(str) >= sizeof(Word));

  *((Word*)str) = db;
}
