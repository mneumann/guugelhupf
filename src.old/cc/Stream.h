#ifndef __HEADER__STREAM__
#define __HEADER__STREAM__

template<class TokenType> 
class Stream {
public:
  virtual TokenType* next() = 0;
};

#endif
