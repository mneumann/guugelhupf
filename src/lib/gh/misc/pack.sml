structure Pack =
struct
   structure Prim = struct
      val pack_word = _ffi "Pack_word" : (word * string) -> unit;  
   end

  fun packWord (w: word) = 
     let 
        val str = "\000\000\000\000"
        val _ = Prim.pack_word (w, str)
     in
        str
     end

end
