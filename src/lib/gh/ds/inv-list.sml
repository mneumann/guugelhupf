structure FrequencyInvertedList = 
struct
   structure DocIdMap = SplayMapFn (struct 
                                    type ord_key = doc_id
                                    val compare = Word.compare 
                                    end)

   (* posting = occurences of a token in _one_ document *)
   type posting = {frequency: word ref}

   datatype inv_list = T of {hashTable: (string, posting DocIdMap.map ref) HashTable.t}

   exception NotFound

   fun new {hash, size} = 
      T {hashTable = HashTable.new {equals = (op =), 
                                    hash = hash,
                                    notFound = NotFound,
                                    size = size} }

  fun addToken (T{hashTable}) (docid: doc_id, Token{term, position, ...}) =
     let 
        val map = HashTable.lookupOrInsert hashTable (term, ref DocIdMap.empty)

        val newMap = case DocIdMap.find (!map, docid) 
                      of NONE => DocIdMap.insert (!map, docid, {frequency = ref 0w1})
                       | SOME({frequency}) => (Word.inc frequency; !map) 
     in
        map := newMap
     end

   fun lookupTerm (T{hashTable}) (term: string) =
      let
         val map = HashTable.find hashTable term
      in
        case map
         of NONE => []
          | SOME(m) => DocIdMap.listItemsi (!m)
      end 

   fun outputTerm (t as T{hashTable}) (term: string) = 
      let 
         val a = lookupTerm t term
         fun outp (docid, {frequency}) = 
            let 
               fun w2s w = Int.toString (Word.toInt w);
            in
               print "  ";
               print (w2s docid); 
               print " => ";
               print (w2s (!frequency));
               print "\n"
            end
      in
         List.app outp a
      end
 
   fun output (t as T{hashTable}) =
      let
         val l = HashTable.listItemsi hashTable  
         fun outp (k, v) = 
         let 
         in
            print k; print ": \n";
            outputTerm t k
         end
      in
        List.app outp l
      end



   (* 
    File-format:
   *)
   fun writeToFile (T{hashTable}) (filename: string) = 
      let
         open Posix.FileSys
         open IO

         val buckets = HashTable.getBuckets hashTable

         val emptyBucket = 0wxFFFFFFFF

         val fdi = creat (filename ^ ".inx", S.irwxu) (* index file *)
         val fdc = creat (filename ^ ".cnt", S.irwxu) (* content file *)

         fun getPos fd = 
            let
               open Posix.IO
            in
               lseek (fd, 0, SEEK_CUR)
            end

         (*
          * hash: word32   (* NOTE: can be omited to reduce space consumption *)
          * numDocs: word32 
          * termSize: word8
          * termText: termSize bytes
          * 
          * numDocs times {
          *    docId: word32
          *    frequency: word32
          * }
          *) 
         fun writeToken (hash: word, termText: string, docs: posting DocIdMap.map ref) = 
            let
              val numDocs = Word.fromInt (DocIdMap.numItems (!docs))
              val termSize = Word8.fromInt (String.size termText)
              fun writeDoc (docId: doc_id, pst: posting) =
                 let 
                    val frequency = !(#frequency pst)
                 in
                    writeWord fdc docId;
                    writeWord fdc frequency;
                    ()
                 end
            in
               writeWord fdc hash;
               writeWord fdc numDocs;
               writeWord8 fdc termSize;
               writeString fdc termText;
               List.app writeDoc (DocIdMap.listItemsi (!docs))
            end

         (*
          * if numTokens = 0 then do not write anything to fdc
          *
          * numTokens: word32
          *
          * numTokens times {
          *   see writeToken
          * }
          *) 
         fun writeBucket (lst : (word * string * posting DocIdMap.map ref) list) = 
            let
               val numTokens = Word.fromInt (List.length lst)
               val offs = Word.fromInt (getPos fdc)
            in
               if numTokens = 0w0 then (
                  writeWord fdi emptyBucket;
                  ()
               )
               else ( 
                  writeWord fdi offs;
                  writeWord fdc numTokens;
                  List.app writeToken lst
               )
            end

      in
         Array.app writeBucket buckets 
      end
         
   
end
