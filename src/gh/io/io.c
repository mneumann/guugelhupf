/*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *
 * TODO: better error handling for reading functions 
 */

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include "libmlton.h"

/* WRITING */

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

/* READING */

Char
IO_read_char(Fd handle) {
  Char v;
  int c;
  c = read(handle, (void*) &v, sizeof(Char));
  assert(c == sizeof(Char));
  return v;
}

Word 
IO_read_word8(Fd handle) {
  Word v = 0L;
  int c;
  c = read(handle, (void*) &v, 1);
  assert(c == 1);
  return v;
}

Word 
IO_read_word(Fd handle) {
  Word v;
  int c;
  c = read(handle, (void*) &v, sizeof(Word));
  assert(c == sizeof(Word));
  return v;
}

Int 
IO_read_int(Fd handle) {
  Int v;
  int c;
  c = read(handle, (void*) &v, sizeof(Int));
  assert(c == sizeof(Int));
  return v;
}

void
IO_read_string(Fd handle, Pointer v) {
  int c;
  Word len = GC_arrayNumElements(v);
  c = read(handle, (void*) v, len);
  assert(c == len);
}

void
IO_read_wordArray(Fd handle, Pointer v) {
  int c;
  Word len = GC_arrayNumElements(v) * sizeof(Word);
  c = read(handle, (void*) v, len);
  assert(c == len);
}
