(* read a char table from file *)
fun mkCharTableFromFile file = 
   let
      val strm = TextIO.openIn file
   in
      TextIO.inputN (strm, 256)
   end
