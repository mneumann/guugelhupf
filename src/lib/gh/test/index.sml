(* file -i -b filename *)
open Hashing
open DS
open Tokenizer.CharTableTransform

structure T = MmapTokenizer
structure TS = StopwordFilterFn(structure TS = T);

val charTable = mkCharTableFromFile "../tokenizer/char-table-transform/german.ct"
val iv = FrequencyInvertedList.new {hash = Hashing.sdbmHash, size = 30000};
val docid = ref 0w0; 
val stopWordTable = TS.mkTableFromFile "../filter/stopWords.en"

fun scanDocument iv file = 
   let 
      val timer = Timer.startCPUTimer () (* start timer *)

      val _ = print ("= processing file " ^ file ^ "\n")

      val ms = T.new (file, charTable)
      val ts = TS.new {tokenStream = ms, table = stopWordTable}
      val id = Word.inc docid
      fun loop() = 
         case TS.nextToken ts 
          of NONE => ()
           | SOME(tok) => (FrequencyInvertedList.addToken iv (id, tok); loop ()) 

      fun reportStats () = 
         let
            val {usr, sys, gc} = Timer.checkCPUTimer timer (* stop timer *)
            val total = Time.+ (Time.+ (usr, sys), gc)

            val (tokenIn, tokenOut) = TS.inOutStats ts 
            val tokenFiltered = tokenIn - tokenOut

            val wordToDecString = Int.toString o Word.toInt
            val timeToString = LargeInt.toString o Time.toMicroseconds (*Real.toString o Time.toReal  *)
         in
            print ("! token in/out/filtered: " ^ 
                   wordToDecString tokenIn ^ "/" ^
                   wordToDecString tokenOut ^ "/" ^
                   wordToDecString tokenFiltered  ^ "\n");
            print ("! time (in us) usr/sys/gc/total: " ^
                   timeToString usr ^ "/" ^ 
                   timeToString sys ^ "/" ^ 
                   timeToString gc ^ "/" ^ 
                   timeToString total ^ "\n");
            print "\n"
         end
   in
      loop ();
      reportStats ();
      T.free ms 
   end


fun doIt () = 
   let
      val strm = TextIO.stdIn
   in
      TextIO.appLines (fn line => scanDocument iv (String.chop line)) strm
   end

val _ = doIt ();  
(*val _ = FrequencyInvertedList.output iv;*)
val _ = FrequencyInvertedList.writeToFile iv "/tmp/index"; 
