#ifndef __HEADER__MY_MMAP_TOKEN_STREAM__
#define __HEADER__MY_MMAP_TOKEN_STREAM__

#include "basic.h"
#include "Token.h"
#include "MmapStream.h"

class MyMmapTokenStream : public MmapStream<Token> {
public:

  MyMmapTokenStream(int fd, int length);
  Token* next();

private:
  Token currentToken;
  char *last_ptr;

  static char buchstabe[256];
};

#endif
