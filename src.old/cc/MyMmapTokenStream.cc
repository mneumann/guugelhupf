#include "MyMmapTokenStream.h"

MyMmapTokenStream::MyMmapTokenStream(int fd, int length) : MmapStream<Token>::MmapStream<Token>(fd, length) {
  this->last_ptr = (char*) this->ptr + this->length; 

  currentToken.position = -1;  // position is word-wise (start with 0)
  currentToken.end_ptr = currentToken.start_ptr = (char*) this->ptr;
  currentToken.type = (char*)NULL;
} 

char MyMmapTokenStream::buchstabe[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

Token* MyMmapTokenStream::next() {
  currentToken.position += 1;
  currentToken.start_ptr = currentToken.end_ptr;  // go on where we left off last time

  // skip non characters
  while (currentToken.start_ptr < this->last_ptr && !MyMmapTokenStream::buchstabe[*currentToken.start_ptr]) {
    ++currentToken.start_ptr;
  } 

  currentToken.end_ptr = currentToken.start_ptr;
  // consume characters
  while (currentToken.end_ptr < this->last_ptr && MyMmapTokenStream::buchstabe[*currentToken.end_ptr]) {
    ++currentToken.end_ptr;
  } 

  if (currentToken.end_ptr >= this->last_ptr) {
    return (Token*) NULL;
  }

  return &currentToken;
} 
