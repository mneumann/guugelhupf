#ifndef __HEADER__MMAP_STREAM__
#define __HEADER__MMAP_STREAM__

#include <sys/types.h> // mmap
#include <sys/mman.h>  // mmap
#include <stdio.h>     // perror

#include "basic.h"
#include "Stream.h"

struct MmapException { 
  char *message;
  MmapException(char *msg) : message(msg) {}
};

template<class TokenType> 
class MmapStream : public Stream<TokenType> {

public:

  MmapStream(int fd, int length) {
    this->length = length;

    // mmap file into main memory 
    if ((this->ptr = mmap(NULL, this->length, PROT_READ, 0, fd, 0)) == MAP_FAILED) {
      //throw MmapException("Failed to memory map file!"); 
      this->ptr = NULL;
      throw MmapException("Failed to memory map file!");
    }
  
    //if (madvise(this->ptr, this->length, MADV_SEQUENTIAL) == -1) { perror("Failed to advise VM manager!"); }
  }

  ~MmapStream() {
    munmap(this->ptr, this->length);
  }

protected:
  void *ptr;   // pointer to memeory mapped content
  int length;  // length of memory mapped content
};

#endif
