#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include "libmlton.h"

Int
IO_write_char(Fd handle, Char v) {
  return write(handle, (void*) &v, sizeof(Char));
}

Int 
IO_write_word8(Fd handle, Word v) {
  return write(handle, (void*) &v, 1);
}

Int 
IO_write_word(Fd handle, Word v) {
  return write(handle, (void*) &v, sizeof(Word));
}

Int 
IO_write_int(Fd handle, Int v) {
  return write(handle, (void*) &v, sizeof(Int));
}

Int
IO_write_string(Fd handle, Pointer v) {
  return write(handle, (void*) v, GC_arrayNumElements(v));
}

Int
IO_write_wordArray(Fd handle, Pointer v) {
  return write(handle, (void*) v, GC_arrayNumElements(v)*sizeof(Word));
}
