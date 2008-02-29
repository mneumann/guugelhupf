(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

structure MmapTokenizer :>
  sig 
    include TOKEN_STREAM 
    val new : (string * string) -> t
    val new2 : (Posix.IO.file_desc * int * string) -> t
    val free : t -> unit
  end = 
  struct 

    exception Error of string

    structure Prim = 
      struct
        type t = Misc.CStruct.t
        val structSize = _ffi "MmapTokenizer_structSize" : int;
        val maxWordLen = _ffi "MmapTokenizer_maxWordLen" : int;
        val init = _ffi "MmapTokenizer_init" : (t * word * int) -> bool;
        val free = _ffi "MmapTokenizer_free" : t -> unit;
        val nextToken = _ffi "MmapTokenizer_nextToken" : 
               (t * string (* ct *) * CharArray.array (* buf *)) -> int;
      end (* Prim *)

    datatype t = T of {prim: Prim.t, fd : Posix.IO.file_desc,
                       charTable: string, buf: CharArray.array,
                       wordPos: word ref}

    fun new2 (fd : Posix.IO.file_desc, len : int, ct : string) : t = let
      val s = Misc.CStruct.new Prim.structSize
      val b = CharArray.array (Prim.maxWordLen, #"\000")
    in
      if (String.size ct) <> 256 
      then raise Error("charTable is of wrong size (should be 256)")
      else (); 

      if Prim.init (s, Posix.FileSys.fdToWord fd, len) then
        T {prim = s, fd = fd, charTable = ct, buf = b, wordPos = ref 0w0}
      else
        raise Error("Failed to memory map file")
    end

    fun new (fileName : string, ct : string) : t = let
      open Posix.FileSys
      val fd = openf (fileName, O_RDONLY, 0w0)
      val sz = ST.size (stat fileName)
    in
      new2 (fd, sz, ct)
    end

    fun free (T {prim = s, fd, ...}) = (Prim.free s; Posix.IO.close fd)

    fun nextToken (T {prim = s, charTable = ct, buf = b, wordPos, ...}) = let
      val sz = Prim.nextToken (s, ct, b) 
    in 
      if sz = 0 then
        NONE
      else
        SOME (Token {term = CharArray.extract (b, 0, SOME (sz)),
                     position = Word.inc wordPos,
                     kind = NONE }) 
    end
   
    val map = TokenStream0.map nextToken
    val app = TokenStream0.app nextToken
    val toList = TokenStream0.toList nextToken
  end

