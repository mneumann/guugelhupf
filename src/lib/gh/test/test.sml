open Hashing
open DS
open Tokenizer.CharTableTransform

val iv = FrequencyInvertedList.new {hash = Hashing.sdbmHash, size = 30000};
val docid = ref 0w0; 

fun scanDocument iv file = 
   let 
      val _ = print (file ^ "\n")
      val ts = MmapTokenizer.new2 (file, German)
      val id = Word.inc docid
      fun loop() = 
         case MmapTokenizer.nextToken ts 
          of NONE => ()
           | SOME(tok) => (FrequencyInvertedList.addToken iv (id, tok); loop ()) 
   in
      loop ()
   end


fun loop () = 
   let 
      val line = TextIO.inputLine TextIO.stdIn
   in
      if line <> ""
         then (scanDocument iv (String.substring (line, 0, String.size line - 1)); loop ())
      else
         () 
   end

val _ = loop ();  
(*val _ = FrequencyInvertedList.output iv;*)
val _ = FrequencyInvertedList.writeToFile iv "/tmp/index";
