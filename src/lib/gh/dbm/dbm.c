#include <fcntl.h>
#include <ndbm.h>
#include <stdlib.h>
#include <string.h>
#include "libmlton.h"

const Word DBM_O_RDONLY = O_RDONLY;
const Word DBM_O_RDWR = O_RDWR;
const Word DBM_O_CREAT = O_CREAT;
const Word DBM_O_EXCL = O_EXCL;
const Word DBM_O_FSYNC = O_FSYNC;
const Word DBM_O_NOFOLLOW = O_NOFOLLOW;

const Word DBM_INSERT_C = DBM_INSERT;
const Word DBM_REPLACE_C = DBM_REPLACE;

/* NOTE: base must be null-terminated */
Word
DBM_open(Pointer base, Word flags, Word mode) {
  return (Word) dbm_open(base, flags, mode);
}

void
DBM_close(Word db) {
  dbm_close((DBM*) db);
}

Int
DBM_store(Word db, Pointer key, Pointer data, Word flags) {
  return dbm_store((DBM*) db, 
      (datum){key, GC_arrayNumElements(key)},
      (datum){data, GC_arrayNumElements(data)}, flags);
}

Int
DBM_delete(Word db, Pointer key) {
  return dbm_delete((DBM*) db, (datum){key, GC_arrayNumElements(key)});
}

/* 
 * Return -1 if no element to fetch, otherwise size of data.
 * The pointer to the data is stored in "buf".
 */
Int
DBM_fetch(Word db, Pointer key, Pointer buf) {
  datum res;

  assert (GC_arrayNumElements(buf) >= sizeof(Word));

  res = dbm_fetch((DBM*) db, (datum){key, GC_arrayNumElements(key)});
  if (NULL == res.dptr) return -1;

  *((Word*)buf) = (Word)res.dptr;
  return res.dsize; 
}

void
DBM_fetch_buf(Pointer buf, Pointer data) {
  Word res;
  int sz = GC_arrayNumElements(data);

  assert (GC_arrayNumElements(buf) >= sizeof(Word));

  res = *((Word*)buf);
  memcpy((void*)data, (void*)res, sz);
}

Word 
DBM_error(Word db) {
  return dbm_error((DBM*) db);
}

Int
DBM_clearerr(Word db) {
  return dbm_clearerr((DBM*) db);
}

Int
DBM_dirfno(Word db) {
  return dbm_dirfno((DBM*) db);
}
