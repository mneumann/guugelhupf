#if (defined (__FreeBSD__))
#include <sys/types.h>
#endif

#include <sys/mman.h>
#include "libmlton.h"

#ifndef MIN
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#endif

struct MmapTokenizer {
  char *ptr; /* start address of memory */
  char *cur_ptr; /* current position in memory */
  char *end_ptr; /* last address of memeory frame */
  unsigned long length; /* length of memory frame */
};

const int MmapTokenizer_structSize = sizeof(struct MmapTokenizer);
const int MmapTokenizer_maxWordLen = 255;

bool 
MmapTokenizer_init(Pointer p, Fd handle, Size length) {
  struct MmapTokenizer *s = (struct MmapTokenizer*) p; 

  assert (GC_arrayNumElements(p) >= sizeof(struct MmapTokenizer));

  s->ptr = mmap(NULL, length, PROT_READ, MAP_PRIVATE, handle, 0); 
 
  if (s->ptr == MAP_FAILED) {
    return FALSE;
  }

  s->length = length;

  s->cur_ptr = s->ptr;
  s->end_ptr = s->ptr + s->length;
  return TRUE;
}

void 
MmapTokenizer_free(Pointer p) {
  struct MmapTokenizer *s = (struct MmapTokenizer*) p; 

  assert (GC_arrayNumElements(p) >= sizeof(struct MmapTokenizer));

  munmap(s->ptr, s->length);
}


/*
 * returns size of token (EOS=0) and the token itself in buf.
 */           
int
MmapTokenizer_nextToken(Pointer p, Pointer charTable, Pointer buf) {
  struct MmapTokenizer *s = (struct MmapTokenizer*) p; 
  char c;
  char *end_ptr;
  char *start_ptr;
  char *cur_ptr;

  assert (GC_arrayNumElements(p) >= sizeof(struct MmapTokenizer));
  assert (GC_arrayNumElements(charTable) == 256);
  assert (GC_arrayNumElements(buf) >= MmapTokenizer_maxWordLen);

  /* load values from struct into local variables */
  cur_ptr = s->cur_ptr;
  end_ptr = s->end_ptr;


  /* skip non-word characters (non-word characters are those for which 
   * in the characterTable a \0 is stored.)
   */
  while (cur_ptr != end_ptr && charTable[(unsigned)*cur_ptr] == 0) {
    cur_ptr++; 
  } 

  /* cosume word characters until a non-word character occures */
  start_ptr = cur_ptr;
  end_ptr = (char*) MIN(cur_ptr + MmapTokenizer_maxWordLen, end_ptr);  
  while (cur_ptr != end_ptr && (c=charTable[(unsigned)*cur_ptr]) != 0) {
    *buf++ = c;  /* store character in SML buffer */
    cur_ptr++;
  }
  
  /* store value back to struct */
  s->cur_ptr = cur_ptr;

  return cur_ptr - start_ptr; 
}
