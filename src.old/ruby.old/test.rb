require "util"

module GH

# a TokenFilter is not just a decider whether or not a Token will 
# be token, but it may also modify the token!

module TokenStream
  include Enumerable

  def nextToken
    raise AbstractMethodException
  end

  def nextToken?
  end

  def each
    while nextToken?
      yield nextToken 
    end
  end

  def |(filter)
    filter.each(self) do |token|
      yield token
    end
  end

end

class Analyser
  include TokenStream # ???
end

class Tokenizer
  include TokenStream
  # returns a TokenStream
  # ...
end

# abstract
class TokenFilter
  include TokenStream
  #include Enumerable

  # returns a TokenStream, input is also TokenStream


  # apply self on stream and return a new TokenStream 
  def each(stream)
    stream.each do |token|
      yield token if isToken? token
    end
  end

  alias applyOnStream each

  def isToken?(token)
    raise AbstractMethodException
  end
end

class StopwordFilter < TokenFilter
  # returns a TokenStream, input is also TokenStream
end

class SimpleStopwordFilter < StopwordFilter
end

class StemmingFilter < TokenFilter
  # returns a TokenStream, input is also TokenStream
end

class SimpleAnalyser < Analyser
  def initialize(fileName)
    @tokenizer = Tokenizer.new(fileName)
    @stopWordFilter = SimpleStopwordFilter.new
  end

  def nextPosting
    #@tokenizer is a Tokenstream
    @tokenizer.filter(@stopWordFilter).filter(@stemmingFilter)
    @tokenizer | @stopWordFilter | @stemmingFilter 
    @stopWordFilter.filter(@tokenizer)
  end
 
end

class MyTokenFilter < TokenFilter
  def isToken?(token)
    token > 2
  end
end

class MyTokenizer < Tokenizer
  def initialize
    @tokens = [1,2,3,4]
  end
  def nextToken?
    not @tokens.empty?
  end
  def nextToken
    @tokens.shift
  end
end


class MyAnalyser < Analyser
  def initialize
    @tokenizer = MyTokenizer.new
    @filter = MyTokenFilter.new
  end

  def each
    @filter.applyOnStream(@tokenizer) {|t| yield t}      
    
    #@filter.each
    @tokenizer.each {|t| yield t}
    #@tokenizer | 
  end
end

class ExternalTokenFilter
end

class FilteredTokenStream
  def initialize(stream, filter) 
  end
end
 #FilteredTokenStream.new(Tokenizer.new(file), StopwordFilter.new)
end # module GH




class TokenFilter
  ## token gets rejected if returns nil,
  #   otherwise the returned token is passed back
  def filter(token) 
    raise AbstractMethodException
  end
end


a = GH::MyAnalyser.new

p a.entries
