#!/usr/bin/env ruby
#
# A simple compilation manager for MLton, which supports Groups, 
# Packages and Objectfiles.
#
# Copyright (c) 2001, 2002 Michael Neumann <neumann@s-direktnet.de>
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
# $Id:$
#


class Source
  attr_reader :path
  def initialize(path)
    @path = path
    raise "File <#@path> do not exists!" unless File.exists? @path
  end

  def kind
    name = File.basename @path
    suffix = name.split(".").last
    case suffix.downcase
    when 'sml', 'sig', 'fun'
      :SML
    when 'cm'
      :CM
    when 'o'
      :OBJ
    else
      raise "unknown file type"
    end
  end

  def content(object_files = [])
    case self.kind
    when :SML
      File.readlines(@path).to_s
    when :CM
      CM.new(@path).content(object_files)
    else
      raise "file type does not support content"
    end
  end
end

class CM
  attr_reader :kind, :package, :sources, :path

  def initialize(path)
    @path = path
    @dir = File.split(@path).first
    @lines = File.readlines(@path).collect{|l| l.strip}.select{|l|
      not (l.empty? or l[0,1] == '#')
    }
    parse
  end

  def content(object_files = [])
    content = ""

    if @kind == :PACKAGE
      content << "structure #{ @package } = struct\n"
    end

    @sources.each {|src| 
      if src.kind == :OBJ then
        object_files << src.path
      else
        content << src.content(object_files) 
      end
    }

    if @kind == :PACKAGE
      content << "end;\n"
    end

    content
  end

  private

  def parse
    header = @lines.first
    case header
    when /^Package\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+is$/i
      @kind, @package = :PACKAGE, $1
    when /^Group is$/
      @kind = :GROUP
    else
      raise "Unsupported CM header format"
    end
    @sources = @lines[1..-1].collect {|l|
      if l[0,1] == "/"
        # absolute path
        Source.new(l)
      else
        Source.new(File.join(@dir, l))
      end
    }
  end
end

if __FILE__ == $0
  def usage
    "USAGE: #$0 cm-file output-file"
  end

  cm_file = ARGV[0] || (raise usage)
  output_file = ARGV[1] || (raise usage)

  object_files = []
  c = Source.new(cm_file).content(object_files)
  File.open(output_file, "w+") {|f| f << c }

  command = "mlton #{output_file} #{object_files.join(' ')}\n"
  print command
  print `#{command}`
end
