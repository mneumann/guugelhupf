(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *)

open Tokenizer.CharTableTransform

fun main (name, args) = 
let
   val usage = "USAGE: " ^ name ^ ": charTableFile stopwordFile indexFile docDB"  

   val _ = if List.length args <> 4 then raise Fail(usage) else ()

   val [charTableFile, stopwordFile, indexFile, docDB] = args

   val db = DBM.openReadOnly docDB 

   val q = RankedQuery.query {strm = TextIO.stdIn, 
                              charTable = mkCharTableFromFile charTableFile,  
                              stopwordTable = SimpleAnalyser.TS.mkTableFromFile stopwordFile, 
                              outputFn = (fn s => TextIO.output (TextIO.stdErr, s)),
                              file = indexFile,
                              hash = Hashing.sdbmHash,
                              scoreFn = (fn {freq, rank} => freq * rank) }

   fun output (docid, rank) =
      let
         val file = DBM.lookup db (Misc.Pack.packWord docid)
      in
         print (Int.toString rank ^ "\t" ^ file ^ "\n")
      end
in 
   List.app output q
end

val _ = main(CommandLine.name (), CommandLine.arguments ())
