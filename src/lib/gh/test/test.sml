(* file -i -b filename *)
open Hashing
open DS
open Tokenizer.CharTableTransform

structure TS = StopwordFilterFn(structure TS = MmapTokenizer);

val iv = FrequencyInvertedList.new {hash = Hashing.sdbmHash, size = 30000};
val docid = ref 0w0; 
val stopWordTable = TS.mkTableFromFile "../filter/stopWords.en"

fun scanDocument iv file = 
   let 
      val _ = print (file ^ "\n")
      val ms = MmapTokenizer.new2 (file, German)
      val ts = TS.new {tokenStream = ms, table = stopWordTable}
      val id = Word.inc docid
      fun loop() = 
         case TS.nextToken ts 
          of NONE => ()
           | SOME(tok) => (FrequencyInvertedList.addToken iv (id, tok); loop ()) 
   in
      loop ();
      MmapTokenizer.free ms 
   end


fun doIt () = 
   let
      val strm = TextIO.stdIn
   in
      TextIO.appLines (fn line => scanDocument iv (String.chop line)) strm
   end

val _ = doIt ();  
(*val _ = FrequencyInvertedList.output iv;*)
(*val _ = print "\n--- write index file\n"; *)
val _ = FrequencyInvertedList.writeToFile iv "/tmp/index"; 
