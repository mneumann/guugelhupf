(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *)

structure DefaultIndex = 
struct
   open DS
   open Tokenizer.CharTableTransform

   structure Tokenizer = MmapTokenizer
   structure TS = StopwordFilterFn(structure TS = Tokenizer) (* token stream *)
   structure InvList = FrequencyInvertedList

   val hash = Hashing.sdbmHash

   datatype t = T of {charTable: string, 
                      invList: InvList.inv_list, 
                      stopwordTable: TS.table, 
                      outputFn: string -> unit }


   fun new {size, stopwordFile, charTable, outputFn} = 
      T {invList = InvList.new {hash = hash, size = size},
         stopwordTable = TS.mkTableFromFile stopwordFile,
         charTable = charTable,
         outputFn = outputFn } 

   fun indexDocument (T{charTable, stopwordTable, invList, outputFn}) 
                     (file: string, docid: doc_id) = 
      let 
	 val _ = outputFn ("= processing file " ^ file ^ "\n")
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
	       outputFn ("! token in/out/filtered: " ^ 
		      wordToDecString tokenIn ^ "/" ^
		      wordToDecString tokenOut ^ "/" ^
		      wordToDecString tokenFiltered  ^ "\n");
	       outputFn ("! time (in us) usr/sys/gc/total: " ^
		      timeToString usr ^ "/" ^ 
		      timeToString sys ^ "/" ^ 
		      timeToString gc ^ "/" ^ 
		      timeToString total ^ "\n");
	       outputFn "\n"
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

end
