structure StreamTokenizer :>
sig
   include TOKEN_STREAM
   val new (string * string) -> t  
   val new2 (TextIO.instream * string) -> t
   val free : t -> unit
end = 
struct
   val maxWordLen = 255

   exception Error of string

   datatype t = T of {stream: TextIO.instream,
                      charTable: string,
                      buf: CharArray.array, 
                      wordPos: word ref}
                      
   fun new2 (strm, ct) = 
      let
         val _ = if (String.size ct) <> 256 then raise Error("charTable is of wrong size (should be 256)")
                 else ()
      in
         T {stream = strm,
            charTable = ct,
            buf = CharArray.array (maxWordLen, #"\000"),
            wordPos = ref 0w0} 
      end

   fun new (filename, ct) = new2 (TextIO.openIn filename, ct)

   fun free t = () 

   fun nextToken (T{stream, charTable, buf, wordPos}) = 
      let
         val buflen = ref 0
 
         fun lookup c = String.sub (charTable, Char.ord c)

         fun skipws () = 
            let
               val c = TextIO.lookahead stream
            in
               if isSome(c) andalso lookup (valOf c) = #"\000"
                  then (TextIO.input1 stream; skipws())
               else ()
            end
               
         fun consume () =
            let
               val c = TextIO.lookahead stream 
            in
               if isSome(c) then (let
                                     val l = lookup (valOf c)
                                  in
                                     CharArray.update (buf, !buflen, l);
                                     TextIO.input1 stream;
                                     if l = #"\000" then false (* whitespace *)
                                     else ( 
                                        if (Word.inc buflen) >= maxWordLen then false
                                        else true )
                                  end)
               else false

      in
         skipws ();
         while consume() do ();
         if !buflen = 0 then 
            NONE
         else
            SOME (Token {term = CharArray.extract (buf, 0, SOME (!buflen)),
                         position = Word.inc wordPos,
                         kine = NONE})
      end
end

