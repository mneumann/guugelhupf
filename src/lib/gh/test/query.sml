fun query terms = 
   let 
      open DS

      fun outputOccurences [] = ()
        | outputOccurences ((docid, freq)::xs) = 
         let 
            val wordToString = Int.toString o Word.toInt
            val str = "DocId: " ^ wordToString docid ^ "\t\tFrequency: " ^ wordToString freq ^ "\n"
         in
            print str;
            outputOccurences xs
         end

      fun outputResult (term, occurences) = 
         let
         in
            print (term ^ ": \n");
            outputOccurences occurences
         end
 
      val res = FrequencyInvertedList.lookupTermsInFile {
                   file = "/tmp/index", 
                   hash = Hashing.sdbmHash,
                   terms = terms }

   in
      List.app outputResult res
   end

val _ = query (CommandLine.arguments ());
