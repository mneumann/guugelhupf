(* required, because MLton do not support TextIO.openString *)

structure StringTokenizer :>
sig
   include TOKEN_STREAM
   val new : (string * string) -> t  
   val free : t -> unit
end = 
struct
   val maxWordLen = 255

   exception Error of string

   datatype t = T of {str: string,
                      strPos: int ref,
                      charTable: string,
                      buf: CharArray.array, 
                      wordPos: word ref}
                      
   fun new (str, ct) = 
      let
         val _ = if (String.size ct) <> 256 then raise Error("charTable is of wrong size (should be 256)")
                 else ()
      in
         T {str = str,
            strPos = ref 0,
            charTable = ct,
            buf = CharArray.array (maxWordLen, #"\000"),
            wordPos = ref 0w0} 
      end

   fun free t = () 

   fun nextToken (T{str, strPos, charTable, buf, wordPos}) = 
      let
         val buflen = ref 0
 
         fun lookup c = String.sub (charTable, Char.ord c)

         fun readC () = 
            if !strPos < String.size str then SOME (String.sub (str, !strPos))
            else NONE

         fun skipws () = 
            let
               val c = readC () 
            in
               if isSome(c) andalso lookup (valOf c) = #"\000"
                  then (strPos := !strPos + 1; skipws())
               else ()
            end
               
         fun consume () =
            let
               val c = readC ()
            in
               if isSome(c) then (let
                                     val l = lookup (valOf c)
                                  in
                                     CharArray.update (buf, !buflen, l);
                                     strPos := !strPos + 1;
                                     if l = #"\000" then false (* whitespace *)
                                     else ( 
                                        if Int.inc buflen >= maxWordLen then false
                                        else true )
                                  end)
               else false
            end

      in
         skipws ();
         while consume() do ();
         if !buflen = 0 then 
            NONE
         else
            SOME (Token {term = CharArray.extract (buf, 0, SOME (!buflen)),
                         position = Word.inc wordPos,
                         kind = NONE})
      end


   val map = TokenStream0.map nextToken
   val app = TokenStream0.app nextToken
   val toList = TokenStream0.toList nextToken
end

