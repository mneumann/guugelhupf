#
# Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
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
# Abstract superclass of all kinds of streams.
#
class Stream
  #EosException = Exception.new("Reached end of stream!")

  ##
  # returns:: nil on Eos
  #
  def next
    raise AbstractMethodException
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
  def initialize(in_stream)
    @in_stream = in_stream
  end
end


class Tokenizer
end

#
# Concrete Implementations
#

#
# Filters tokens through an external program.
#
class ExternalTokenFilter < TokenFilter
  def initialize(in_stream, command)
    super(in_stream)
    @command = command
    in, out = popen(@command)
  end

  # Todo: have to specify output/input format
  def next
    # check if some output is available
    out << @in_stream.next.external_format
    # ...  
  end
end

#
# Reads tokens from an external program
#
class ExternalTokenStream < TokenStream
end
 
end # module GH
