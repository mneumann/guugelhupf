structure DefaultIndex = 
struct
   open DS
   open Tokenizer.CharTableTransform

   structure Tokenizer = MmapTokenizer
   structure TS = StopwordFilterFn(structure TS = Tokenizer) (* token stream *)
   structure InvList = FrequencyInvertedList

   val hash = Hashing.sdbmHash

   datatype t = T of {charTable: string, invList: InvList.inv_list, 
                      stopwordTable: TS.table }


   fun new {size, stopwordFile, charTable} = 
      T {invList = InvList.new {hash = hash, size = size},
         stopwordTable = TS.mkTableFromFile stopwordFile,
         charTable = charTable } 

   fun indexDocument (T{charTable, stopwordTable, invList}) 
                     (file: string, docid: doc_id) = 
      let 
	 val _ = print ("= processing file " ^ file ^ "\n")
	 val timer = Timer.startCPUTimer () (* start timer *)

	 val ms = Tokenizer.new (file, charTable)
	 val ts = TS.new {tokenStream = ms, table = stopwordTable}

	 fun loop() = 
	    case TS.nextToken ts 
	     of NONE => ()
	      | SOME(tok) => (InvList.addToken invList (docid, tok); loop ()) 

	 fun reportStats () = 
	    let
	       val {usr, sys, gc} = Timer.checkCPUTimer timer (* stop timer *)
	       val total = Time.+ (Time.+ (usr, sys), gc)

	       val (tokenIn, tokenOut) = TS.inOutStats ts 
	       val tokenFiltered = tokenIn - tokenOut

	       val wordToDecString = Int.toString o Word.toInt
	       val timeToString = LargeInt.toString o Time.toMicroseconds 
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
	 Tokenizer.free ms 
      end

   fun writeIndex (T{invList, ...}) (file: string) = 
      let
      in
         InvList.writeToFile invList file
      end

end;

(* TEST *)

let 
open Tokenizer.CharTableTransform

val docid = ref 0w0
val inx = DefaultIndex.new {size = 30000,
                                stopwordFile = "../filter/stopWords.en",
                                charTable = mkCharTableFromFile "../tokenizer/char-table-transform/german.ct"}

fun scanDocument line =
   let
      val file = String.chop line
   in
      DefaultIndex.indexDocument inx (file, Word.inc docid) 
   end
 
fun main () = 
   let
      val strm = TextIO.stdIn
      val target = "/tmp/index"
   in
      TextIO.appLines scanDocument strm;
      DefaultIndex.writeIndex inx target
   end

in
   main () 
end;

