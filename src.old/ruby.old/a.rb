#
# Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions 
# are met:
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in the 
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
# THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require "util"

module GH

# a TokenFilter is not just a decider whether or not a Token will 
# be taken, but it may also modify the token!

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


#######################################################################################

# Todo:: concurrent access?
class TokenStream
  include Enumerable

  def nextToken
    raise AbstractMethodException
  end

  def hasToken?
    raise AbstractMethodException
  end

  def each #:yiels: token
    while hasToken?
      yield nextToken 
    end
  end
end


# should a filter be possible to add tokens to the stream?
# I think yes!
#
# inputStream :filter: outputStream
#
class TokenFilter

  # _token_ gets rejected if this method returns nil,
  # otherwise the returned token (possibly modified) stays
  # in the stream.
  # If an Array is returned, than all elements are inserted back
  # into the stream. 

  def filter(token) 
    raise AbstractMethodException
  end

  def filterStream(inputStream, outputStream)
  end
end


class FilteredTokenStream < TokenStream
  def initialize(stream, filter)
    @stream, @filter = stream, filter
    @buffer = []
  end

  def hasToken?
    @stream.hasToken? || !@buffer.empty?
  end

  # Todo: may not be access concurrently!
  def nextToken
    loop {
      if @buffer.empty?
        tok = @stream.nextToken
        res = @filter.filter(tok)
        if res.nil?
          next    
        elsif res.is_a? Array
          @buffer.push(*res)
          next
        else
          return res
        end
      else
        return @buffer.shift
      end
    }
  end
end

################################

class MyTokenFilter < TokenFilter
  def filter(token)
    puts "------ in filter"
    puts "token: #{token}"
    return nil if token < 2  # reject  
    if token < 4  
      token + 10
    else
      [token] * 5
    end
  end
end

class MyTokenStream < TokenStream
  def initialize
    @tokens = [1,2,3,4]
  end
  def hasToken?
    not @tokens.empty?
  end
  def nextToken
    @tokens.shift
  end
end

a = FilteredTokenStream.new(MyTokenStream.new, MyTokenFilter.new)
p a.entries


# TokenStream: method `next' 
# TokenFilter: is_a TokenStream.
# Tokenizer: a TokenStream 

# (filter in) => out
# |(filter in)
# (in | filter1) | filter2 

=begin

class ['a] filter = object
  end;;

let f = new filter;;
let filtered_stream = f#create_filtered_stream stream_x;;   

method create_filtered_stream stream = 
  filtered_stream stream filter
;;

class ['a] stream = object
  end;; 

=end
