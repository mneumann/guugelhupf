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


#
# Representation of a token.
# 
class Token
  attr_accessor :str, :pos
  def initialize(str, pos)
    @str, @pos = str, pos
  end
end
 

#
# Abstract superclass of all kinds of streams.
#
class Stream
  ##
  # returns:: nil on Eos
  #
  def next
    raise AbstractMethodException
  end

  def each(&b)
    while token = self.next
      b.call token  
    end
  end
end

#
# Abstract superclass of all streams returning Token objects.
#
class TokenStream < Stream
end

#
# Abstract superclass of all token filters.
#
class TokenFilter < TokenStream
  def initialize(inStream)
    @inStream = inStream
  end
end


class Tokenizer
  def initialize(stringOrReadable)
    @stringOrReadable = stringOrReadable
  end
end

# ---------------------------------------------------------------------------------------
# Concrete Implementations
# ---------------------------------------------------------------------------------------


class SimpleTokenizer < Tokenizer
  def initialize(stringOrReadable)
    super
    @next_callcc = nil
    @pos = 0
  end

  def next
    if @next_callcc.nil?
      @stringOrReadable.scan(/[A-Za-z]+/) do |token|
        callcc { | @next_callcc | return Token.new(token, @pos += 1) }
      end
      return nil
    else
      @next_callcc.call 
    end 
  end
end


class StopwordTokenFilter < TokenFilter
  def initialize(inStream, hashTable)
    super(inStream)
    @hashTable = hashTable
  end

  def next
    loop {
      if token = @inStream.next
        return token unless @hashTable.member?(token.str)
      else
        return nil
      end
    }
  end
end

class LowercaseTokenFilter < TokenFilter
  def next
    if token = @inStream.next
      token.str.downcase!
      token
    else
      nil
    end
  end
end

#
# Filters tokens through an external program.
#
class ExternalTokenFilter < TokenFilter
  def initialize(inStream, command, write_all_before_read=false) 
    super(inStream)
    @pipe = IO.popen(command, "w+") 
    @write_all_before_read = write_all_before_read

    @pipe.sync = true
    @write_thread = Thread.new {
      loop {
        @inStream.each do |token|
          put_token(token)
        end
      }
      @pipe.close_write
    }

    if not @write_all_before_read
      @write_thread.priority=-100_000 # TODO: stop?
    end
  end

  def next
    if @write_all_before_read
      get_token
    else
      if @write_thread.alive?
        @write_thread.priority=0  # TODO: wakeup?
        token = get_token 
        @write_thread.priority=-100_000 # TODO: stop?
        token
      else
        get_token 
      end
    end
  end

  private

  def put_token(token)
    # TODO: External format
    @pipe.puts "#{token.str} #{token.pos}"
  end

  def get_token
    # TODO: External format
    if token = @pipe.gets
      Token.new(*token.split)
    else
      nil
    end
  end
end

class ExternalTokenStream < TokenStream
  def initialize(io)
    @io = io
    @pos = 0
    @token = Token.new(nil, nil)
  end

  def next
    if line=@io.gets
      line.chomp!
      #a = line.split(/\s+/)

      #
      @token.str = line
      @token.pos = (@pos += 1)
      #Token.new(line, @pos += 1)
      @token
      # TODO: file-representation:     pos1 word1 \n pos2 word2
    else
      nil
    end
  end
end

class HashTable
  attr_reader :table, :size
  def initialize(size=5_000)
    @size = size
    @table = Array.new(@size)
  end

  def [](key)
    value = @table[key.hash % @size]
    if value.nil?
      nil
    else
      # value: [ [k1, v1], [k2, v2] ]
      value = value.assoc(key)
      if value.nil?
        nil
      else
        value[1]
      end
    end
  end

  def []=(key, val)
    value = @table[key.hash % @size]
    if value.nil?
      # no entry yet
      @table[key.hash % @size] = [ [key, val] ]
    else
      # value: [ [k1, v1], [k2, v2] ]
      x = value.assoc(key)
      if x.nil?
        # no entry yet
        value << [key, val]
      else
        # replace value 
        x[1] = val
      end
    end
  end

  def key?(key)
    self[key] != nil
  end

  def each_pair(&b)
    @table.each do |value|
      next if value.nil?
      # value: [ [k1, v1], [k2, v2] ]
      value.each(&b) 
    end
  end
end


# hash[token] = [ [token1, [pos, pos, ...]], [token2, [pos, pos, pos] ]
class Index
  attr_reader :index, :docId
  def initialize(docId)
    @index = HashTable.new
    @docId = docId
  end   

  def add(token)
    if @index.key? token.str 
      # posting already exists
      posting = @index[token.str]
      # assert posting.docId == @docId
      posting.positions << token.pos
    else
      # create new posting
      posting = Posting.new(@docId)
      posting.positions << token.pos
      @index[token.str] = posting
    end
  end
end

class CharStream
  def initialize(stringOrReadable)
    @stringOrReadable = stringOrReadable
    case @stringOrReadable 
    when IO
      @next = proc {|obj| obj.getc}
    when String
      @next = proc {|obj| 
        if obj.empty?
          nil
        else
          res = obj[0]
          if res != nil
            obj[0,1] = ""
          end
          res
        end
      } 
    end
  end

  def next
    @next.call(@stringOrReadable)
  end
end


# TODO: find better names for class Posting 
class Posting
  attr_accessor :docId, :positions
  def initialize(docId, positions=nil)
    @docId = docId
    @positions = positions || []
  end

=begin
  def dump_to_string
    "#{docId}(" + @positions.join(" ") + ")"
  end
=end
  def dump_to_string
    [docId, @positions.size, *@positions].pack("N*")
  end

=begin
  # file must implement getc
  def self.read_from_stream(stream)
    str = ""
    while (c=stream.next) != ?)
      str << c.chr
    end
    str << c 

    if str =~ /^(\d+)[(](.*?)[)]$/
      Posting.new($1.to_i, $2.split(" ").collect{|i| i.to_i})
    else
      raise "Wrong format"
    end
  end
=end
end

#
# Stores multiple Index objects in one Hash.
# (the JoinedIndex is readonly).
#
class JoinedIndex
  attr_reader :index

  def initialize
    @index = HashTable.new 
  end

  def addIndex(index)
    # index has for each key one posting
    index.index.each_pair {|word, posting|
      if @index.key? word
        postings_list = @index[word]
        postings_list << posting    # TODO: OrderedList after docId
      else
        @index[word] = [posting]
      end
    }
  end


  def dump_to_file(ix, pst)
    ix << [@index.size].pack("N")
    pst_pos = 0
    @index.table.each_with_index do |cell, i|
      if cell.nil?
        # offset -1 means empty cell
        ix << [-1].pack("N")
      else
        ix << [pst_pos].pack("N")
        cell_str = dump_cell_to_string(cell)
        pst_pos += cell_str.size
        pst << cell_str
      end
    end
  end

  private

  def dump_entry_to_string(word, postings)
    # word(size)....size bytes....
    pst_str = postings.collect {|posting| posting.dump_to_string }.join("")
    "#{word}(#{pst_str.size})#{pst_str}" 
  end

  def read_entry_header_from_file(file)
    str = ""
    while (c=file.getc) != ?)
      str << c.chr
    end
    str << c 

    if str =~ /^([^(]*)[(](\d+)[)]$/
      [$1, $2.to_i]   # (word, size)
    else
      raise "ERROR"
    end
  end

  # a cell is a cell of the HashTable
  def dump_cell_to_string(cell)
    # cell: [ (word, postings), (word, postings) ]
    
    # representation as string:
    #   nr_of_words: INT
    #   entry1
    #   entry2
    #   ...
 
    [cell.size].pack("N") +
    cell.collect do |word, postings|
      dump_entry_to_string(word, postings)
    end.join("")
  end

end


class SimpleAnalyser
  def initialize(index)
    @index = index
  end

  def process(stringOrReadable)
    stream = LowercaseTokenFilter.new(
      SimpleTokenizer.new(stringOrReadable))

    stream.each do |token|
      @index.add(token) 
    end
  end
end

class StopwordAnalyser 
  def initialize(index, hash)
    @index = index
    @hash  = hash
  end

  def process(stringOrReadable)
    stream = LowercaseTokenFilter.new(
      SimpleTokenizer.new(stringOrReadable))
    
    stream = StopwordTokenFilter.new(stream, @hash)

    stream.each do |token|
      @index.add(token) 
    end
  end
end

class StopwordAnalyserX 
  def initialize(index, hash)
    @index = index
    @hash  = hash
  end

  def process(stringOrReadable)
    stream = LowercaseTokenFilter.new(
      ExternalTokenStream.new(stringOrReadable))
    
    stream = StopwordTokenFilter.new(stream, @hash)

    stream.each do |token|
      @index.add(token) 
    end
  end
end


def stopWordList_to_HashTable(fileName)
  hash = {}
  IO.foreach(fileName) do |line|
    hash[line.chomp] = true
  end
  hash
end
module_function :stopWordList_to_HashTable

end # module GH




if __FILE__ == $0
  include GH

  jindex = JoinedIndex.new
  stopWords = stopWordList_to_HashTable("stopWords.en")

  docId = 1
  fileSize = 0
  while filename=STDIN.gets
    filename.chomp!

    puts "#{docId.to_s.ljust(6)} #{fileSize.to_s.ljust(8)} #{filename}"

    index = Index.new(docId)
    #file = File.read(filename)
    fileSize += File.size(filename)


    cmd = "/home/mneumann/mmap.gcc #{filename}"
    IO.popen(cmd) do |file| #
      StopwordAnalyserX.new(index, stopWords).process(file)
      jindex.addIndex(index)
    end #

    docId += 1
  end

  p fileSize
  jindex.dump_to_file(File.new("/tmp/words.idx", "w+"), File.new("/tmp/words.cnt", "w+"))

=begin

  #jindex.index.each_pair {|key, postings_list|
    #  puts "#{ key }: #{ postings_list.first.positions.size }"
    #}
  jindex.index["michael"].each do |posting|
    p posting
    f = File.open("/tmp/aaa", "w+")
    f << posting.dump_to_string 
    f.close

    f = File.open("/tmp/aaa")
    read_posting = Posting.read_from_stream(CharStream.new(f))
    p read_posting
  end
=end
end


