(* read a char table from file *)
fun mkCharTableFromFile file = 
   let
      val strm = TextIO.openIn file
      val (vec, _) = TextIO.inputN (strm, 256)
   in
      vec
   end
