/* 
 * - load header and index into main memory
 * - mmap the data
 */

#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include "libmlton.h"


/********************************************************/
/* Helper Functions                                     */
/********************************************************/

/*
 * Call this function before reading/writing any data,
 * quite after opening the file.
 */
int
getFileLength(int handle)
{
  int length;

  length = lseek(handle, 0, SEEK_END);
  lseek(handle, 0, SEEK_SET);
  return length;
}

unsigned long
sdbm_hash(char* str, int length) {
  unsigned long hash = 0;
  
  while (length--) 
    hash = (*((unsigned char*)str)++) + (hash << 6) + (hash << 16) - hash;

  return hash;
}


/********************************************************/

const Word headerSize = 28;
const Word emptyBucket = 0xFFFFFFFF;

const Word HASH_mask = 1;

struct FreqInvList_Header {
   char kennung[16];
   Word version;
   Word flags;
   Word indexSize;
}; 

struct FreqInvList_Struct {
  struct FreqInvList_Header header;
  int fd;
  Word* index;
  void* data;
  int dataSize;
};

/*
 * read the header and index, and mmap the data.
 */
void 
FreqInvList_open(struct FreqInvList_Struct* s, char *filename) {
  ssize_t cnt;
  int fileLength;
  int offs;

  /* TODO: can remove? */
  if (sizeof(struct FreqInvList_Header) != headerSize) {
    perror("FreqInvList_open: Wrong header struct!");
    exit(-1);
  } 

  /* open file */
  s->fd = open(filename, O_RDONLY); 
  if (-1 == s->fd) {
    perror("FreqInvList_open: Failed to open index!");
    exit(-1);
  }

  fileLength = getFileLength(s->fd);

  /* read header */
  if (read(s->fd, (void*) &s->header, headerSize) != headerSize) {
    perror("FreqInvList_open: Couldn't read header struct!");
    exit(-1);
  }

  /* TODO: check header, version etc.  */

  /* alloc memory for index */
  s->index = calloc(s->header.indexSize, sizeof(Word));
  if (NULL == s->index) {
    perror("FreqInvList_open: Failed to alloc memory for index!");
    exit(-1);
  }

  /* read index */
  cnt = read(s->fd, (void*) s->index, s->header.indexSize * sizeof(Word)); 
  if (cnt != s->header.indexSize * sizeof(Word)) {
    perror("FreqInvList_open: Couldn't read index!");
    exit(-1);
  }

  /* mmap data */
  offs = headerSize + (s->header.indexSize * 4); 
  s->dataSize = fileLength - offs;
  if ((s->data = mmap(NULL, s->dataSize, PROT_READ, 0, s->fd, offs)) == MAP_FAILED) {
    perror("FreqInvList_open: Failed to memory map data!");
    exit(-1);
  }
}


/* 
 * release the memory occupied by the index, unmap the data and close the file 
 */
void 
FreqInvList_free(struct FreqInvList_Struct* s) {
  free(s->index);
  munmap(s->data, s->dataSize); 
  close(s->fd);
}

/*
 * TODO: parameterize with hash-function
 */
void
FreqInvList_query(struct FreqInvList_Struct* s, char *key) {
  Word ix;
  Word offs;
  Word numTokens;
  Word mask;
  void *ptr;

  Word termSize;
  Word numDocs;
  Word hash;

  mask = s->header.indexSize - 1;
  ix = sdbm_hash(key, strlen(key)); 

  offs = s->index[ix & mask];

  if (emptyBucket == offs) return;

  ptr = (s->data + offs);
  numTokens = *((Word*)ptr)++;

  while (numTokens-- > 0) {

    if (s->header.flags & HASH_mask) hash = *((Word*)ptr)++;
    numDocs = *((Word*)ptr)++;
    termSize = *((unsigned char*)ptr)++;

    if ((s->header.flags & HASH_mask) && hash != ix) {
      ptr += termSize + (numDocs*8);
      continue;
    }

    if (strncmp(ptr, key, termSize) == 0) { 
      /* key found */
      ptr += termSize;
      while (numDocs-- > 0) {
        printf("DocId: %u\t\tFrequency: %u\n", ((Word*)ptr)[0], ((Word*)ptr)[1]);
        ptr += 8;
      }
    } else {
      ptr += termSize + (numDocs*8);
    }

  } /* end while */

} 

int
main(int argc, char** argv) {
  struct FreqInvList_Struct s;

  FreqInvList_open(&s, "/tmp/index");

  FreqInvList_query(&s, argv[1]);

  FreqInvList_free(&s);

  return 0;
}

