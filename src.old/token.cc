// ---------------------------------------------------------------------

class Token {
protected:
  // This may be either byte-position, word-position or something else.
  int position;

  // Pointer to data word.
  char *start_ptr;
  char *end_ptr;

  // Type of token. May be unused.
  char *type;
};

// ---------------------------------------------------------------------

template<class TokenType> 
class Stream {
public:
  virtual TokenType& next() = 0;
};

// ---------------------------------------------------------------------

template<class TokenType> 
class Filter : public Stream<TokenType> {
public:
  Filter(Stream<TokenType> &inStream) : inStream(inStream) { }

protected:
  Stream<Token> &inStream;
};

