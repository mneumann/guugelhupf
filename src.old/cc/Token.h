#ifndef __HEADER__TOKEN__
#define __HEADER__TOKEN__

#include "basic.h"

struct Token {
  Token() {
    position = -1;
    start_ptr = (char*) NULL;
    end_ptr = (char*) NULL;
    type = (char*) NULL;
  }

  // This may be either byte-position, word-position or something else.
  int position;

  // Pointer to data word.
  char *start_ptr;
  char *end_ptr;

  // Type of token. May be unused.
  char *type;
};

#endif
