functor StopwordFilterFn (structure TS: TOKEN_STREAM) :> 
sig
   include TOKEN_STREAM

   val new : {tokenStream: TS.t, wordList: string list} -> t
end = struct

   datatype t = T of {tokenStream: TS.t, 
                      hashTable: (string, string) HashTable.t}

   open DS

   exception NotFound

   fun nextToken (t as T{tokenStream, hashTable}) = 
      let
      in
        case TS.nextToken tokenStream
         of NONE => NONE
          | SOME(tok) => if HashTable.hasKey (#term tok) 
                            then nextToken t  
                         else 
                            SOME(tok)
      end  

   val hash = Hashing.sdbmHash

   fun new {tokenStream: TS.t, wordList: string list} = 
      let
         val ht = HashTable.new {equals = (op =), hash = hash, size = List.length wordList, notFound = NotFound}
         fun ins w = HashTable.insertIfNew ins (w, ()) 
      in
         List.app ins wordList; 
         T {tokenStream = tokenStream, hashTable = ht}
      end 
end
