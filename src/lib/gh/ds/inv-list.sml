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

   local
      open Posix.FileSys
      open Posix.IO
      open IO

      val emptyBucket = 0wxFFFFFFFF  (* representation of an empty bucket in the file *)
      val headerSize = 28
      val HASH = 0wxb1               (* flag *)
      val kennung = "FREQ_INV_LIST   " 
      val version = 0wx00010000      (* major = upper word (2-byte), minor = lower *) 

      fun getPos fd = lseek (fd, 0, SEEK_CUR)
      fun setPos fd (pos: word) = lseek (fd, pos, SEEK_SET) 

      fun readWordAtPos fd pos = (setPos fd pos; readWord fd)
   in

   (* Important: Use the same hash here as used for creating the index *) 
   fun lookupTermsInFile ({file, hash, terms})  = 
     let
        val fd = openf (file, O_RDONLY, 0w0)
        val rKennung = readString fd (String.length kennung)
        val rVersion = readWord fd 
        val flags = readWord fd
        val indexSize = readWord fd

        val mask = indexSize - 1 

        val indexOffs = Word.fromInt headerSize
        val dataOffs = Word.fromInt headerSize + (indexSize * 0w4)
        
        val bWriteHash = Word.andb (flags, HASH) <> 0 

        fun lookupTerm (term: string) : (doc_id * word) list =
           let
              val hv = hash term
              val ix = Word.andb (hv, mask)
              val bucket = readWordAtPos fd (indexOffs + ix * 0w4) 

             (*
              * (optional) hash: word32   (* write if bWriteHash = true *) 
              * numDocs: word32 
              * termSize: word8
              * termText: termSize bytes
              * 
              * numDocs times {
              *    docId: word32
              *    frequency: word32
              * }
              *) 
              fun readToken () = 
                 let
                    val h = if bWriteHash then readWord fd else 0w0 
                    val numDocs = readWord fd
                    val termSize = readWord8 fd
                 in
                    if bWriteHash then
                      if h = hv then
                     
  
                       else skip 
                         
                     
                 end     
 
              fun readBucket () = 
                 let 
                    val numTokens = readWordAtPos (dataOffs + bucket) 
                 in
                 end 

           in
              if bucket = emptyBucket 
                 then []
              else 
                 readBucket () 
           end 

     in
        (* check header *)   
        assert (rKennung = kennung);
        assert (rVersion = version);
        assert (getPos(fd) = headerSize) 
     end


   

   fun writeToFile (T{hashTable}) (filename: string) = 
      let

         val buckets = HashTable.getBuckets hashTable
         val numBuckets = HashTable.numBuckets hashTable
         val dataOffs = headerSize + (numBuckets*4)

         val bWriteHash = false (* TODO: make an option *)

         val fdi = creat (filename, S.irwxu) (* write the header and the index (hash) *)
         val fdc = openf (filename, O_WRONLY, 0w0)  (* write the content of the inverted list *)
         val _ = setPos fdc (Word.fromInt dataOffs) (* position file pointer after index *)

         fun writeHeader () = 
            let
               val flags = if bWriteHash then HASH else 0w0 
               val indexSize = Word.fromInt numBuckets 
            in
               writeString fdi kennung; (* 16 bytes *)
               writeWord fdi version;   (* 4 bytes *)
               writeWord fdi flags;     (* 4 bytes *)
               writeWord fdi indexSize; (* 4 bytes *)
               
               assert (getPos(fdi) = headerSize) 
            end
 
         (*
          * (optional) hash: word32   (* write if bWriteHash = true *) 
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
                    writeWord fdc frequency
                 end
            in
               if bWriteHash then writeWord fdc hash else ();
               writeWord fdc numDocs;
               writeWord8 fdc termSize;
               writeString fdc termText;
               List.app writeDoc (DocIdMap.listItemsi (!docs))
            end

         (*
          * numTokens: word32    (if numTokens > 0)
          *
          * numTokens times {
          *   see writeToken
          * }
          *) 
         fun writeBucket (lst : (word * string * posting DocIdMap.map ref) list) = 
            let
               val numTokens = Word.fromInt (List.length lst)
               val offs = Word.fromInt (getPos fdc - dataOffs)
            in
               if numTokens = 0w0 then 
                  writeWord fdi emptyBucket
               else ( 
                  writeWord fdi offs;
                  writeWord fdc numTokens;
                  List.app writeToken lst
               )
            end

      in
         writeHeader ();
         Array.app writeBucket buckets 
      end
        
      end (* local *) 


(*
   structure Query =
   struct
     datatype t = T of {fd: Posix.FileSys.file_desc, index: word array, hash: string -> word}
    
     fun new {hash, file} = 
        let
           open Posix.FileSys
           (*open Posix.IO*)
 
           val fd = openf (file, O_RDONLY, 0w0)

        in
        end   

   end
 *)  
end
