(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *)

functor StopwordFilterFn (structure TS: TOKEN_STREAM) :> 
sig
   include TOKEN_STREAM

   type table = (string, unit) HashTable.t

   val new : {tokenStream: TS.t, table: table} -> t 
   val mkTable : string list -> table 
   val mkTableFromStream : TextIO.instream -> table 
   val mkTableFromFile : string -> table 

   val inOutStats : t -> (word * word)
     (* 
      * Return number of tokens that have gone through the filter, 
      * and how many left it. The difference of both values is the 
      * number of filtered tokens.
      *)

end = struct

   open DS

   structure TS = TS

   type table = (string, unit) HashTable.t
   datatype t = T of {tokenStream: TS.t, 
                      hashTable: table, 
                      tokenIn: word ref,
                      tokenOut: word ref} 


   exception NotFound

   fun nextToken (t as T{tokenStream, hashTable, tokenIn, tokenOut}) = 
      let
      in
        case TS.nextToken tokenStream
         of NONE => NONE              (* end of stream *)
          | (tk as SOME(Token(tok))) => ( Word.inc tokenIn;
             if HashTable.hasKey hashTable (#term tok) 
                then nextToken t 
             else 
                (Word.inc tokenOut; tk)
             ) 
      end  

   val hash = Hashing.sdbmHash

   fun new {tokenStream, table} = 
      T {tokenStream = tokenStream, hashTable = table, tokenIn = ref 0w0, tokenOut = ref 0w0}

   fun inOutStats (T{tokenIn, tokenOut, ...}) = (!tokenIn, !tokenOut) 

   fun mkTable (wordList: string list) = 
      let
         val ht = HashTable.new {equals = (op =), hash = hash, size = List.length wordList, notFound = NotFound}
         fun ins w = HashTable.insertIfNew ht (w, ()) 
      in
         List.app ins wordList;
         ht
      end 

   fun mkTableFromStream (strm) = 
      let 
         val lines = TextIO.readLines strm
      in 
         mkTable (List.map (fn line => String.chop line) lines)
      end

   fun mkTableFromFile (filename: string) = mkTableFromStream (TextIO.openIn filename)

   val map = TokenStream0.map nextToken
   val app = TokenStream0.app nextToken
   val toList = TokenStream0.toList nextToken
end
