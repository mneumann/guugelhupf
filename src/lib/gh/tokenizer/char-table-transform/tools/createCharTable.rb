LOWERCASE = ('a'..'z').to_a.join
UPPERCASE = ('A'..'Z').to_a.join
DIGITS    = ('0'..'9').to_a.join

class CharTable
  def initialize
    @charTable = Array.new(256).fill(0)
  end

  def addChar(c, c_transformed=nil)
    c_transformed ||= c

    if c.is_a? String
      c = c[0]
      c_transformed = c_transformed[0]
    end

    @charTable[c] = c_transformed 
  end

  def addString(str, str_transformed=nil)
    str_transformed ||= str
    if str.size != str_transformed.size
      raise "Strings must be of same length!"
    end

    for i in 0...(str.size) do
      addChar(str[i], str_transformed[i])
    end
  end

  def add(s, st=nil)
    case s
    when String
      addString(s, st)
    when Fixnum
      addChar(s, st)
    else
      raise "Wrong operand type"
    end
  end

  def [](ix)
    @charTable[ix]
  end

  def asString_SML(indent=nil, identifier=nil, inc_indent=nil)
    indent ||= 0
    inc_indent ||= 2
    res = ""
    if identifier
      res << (" "*indent) + "val #{ identifier } = \n"
      indent += inc_indent 
    end

    for i in 0..15
      res << (" " * indent)
      res << (i == 0 ? '"' : '\\') 
      res << escapeArray(@charTable[16*i, 16])
      res << (i != 15 ? "\\\n" : '"')
    end

    res << (identifier ? ";\n" : "\n")

    res
  end

  def fromScript_SML(script)
    @identifier = nil
    @indent, @inc_indent = nil, nil
    instance_eval script
    asString_SML(@indent, @identifier, @inc_indent)
  end

  private

  # escapes a char-array to \xxx format
  def escapeArray(arr)
    res = ""
    arr.each do |b|
      res << "\\"
      res << threeDigit(b)
    end
    res
  end

  def threeDigit(num)
    raise "Number too large!" if num < 0 or num > 255
    hundreds = num / 100 
    tenth = (num-(hundreds*100)) / 10 
    ones = (num-(hundreds*100)-(tenth*10)) 
    return "#{ hundreds }#{ tenth }#{ ones }"
  end

  # evtl. called from script
  def identifier(id)
    @identifier = id
  end

  # evtl. called from script
  def indent(indent, inc_indent=nil)
    @indent, @inc_indent = indent, inc_indent
  end
end

if __FILE__ == $0
  # takes script on stdin and writes output to stdout
  
  #
  # example of script:
  #
  #   identifier "hallo"
  #   indent 3, 4
  #   add LOWERCASE
  #   add UPPERCASE, LOWERCASE
  #   ...
  #

  ct = CharTable.new
  STDOUT << ct.fromScript_SML(STDIN.read)

  #ct = CharTable.new
  #ct.addString(LOWERCASE)
  #ct.addString(UPPERCASE, LOWERCASE) # transform upper -> lower
  #ct.addString(DIGITS)
  #ct.addString("ÄÖÜ", "äöü")  # transform lowercase
  #ct.addString("äöüß")
  #print ct.asString_SML(0, "charTab1")
end
