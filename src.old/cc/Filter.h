#ifndef __HEADER__FILTER__
#define __HEADER__FILTER__

#include "Stream.h"

template<class TokenType> 
class Filter : public Stream<TokenType> {
public:
  Filter(Stream<TokenType> &inStream) : inStream(inStream) { }
protected:
  Stream<Token> &inStream;
};

#endif
