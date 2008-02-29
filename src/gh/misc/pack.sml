(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

structure Pack =
struct
   structure Prim = struct
      val pack_word = _ffi "Pack_word" : (word * string) -> unit;  
      val unpack_word = _ffi "Unpack_word" : string -> word;
   end

  fun packWord (w: word) = 
     let 
        val str = "\000\000\000\000"
        val _ = Prim.pack_word (w, str)
     in
        str
     end

  val unpackWord = Prim.unpack_word 
end
