(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

open Tokenizer.CharTableTransform

fun main (name, args) =
let
   val usage = "USAGE: " ^ name ^ ": hashSize charTableFile stopwordFile indexFile docDB"  

   val _ = if List.length args <> 5 then raise Fail(usage) else ()

   val [hashSize, charTableFile, stopwordFile, indexFile, docDB] = args

   (* NOTE: no two or more programs are allowed to access the docDB concurrently *)
   val db = DBM.new docDB 
   val _ = DBM.insertIfNew db ("nextId", Misc.Pack.packWord 0w1) (* init if db is new *) 

   val inx = DefaultIndex.new {size = (valOf o Int.fromString) hashSize,
                               stopwordFile = stopwordFile, 
                               charTable = mkCharTableFromFile charTableFile,  
                               outputFn = (fn str => TextIO.output (TextIO.stdErr, str))}

   (* format of a line: file [\t url] *)
   fun scanDocument line =
      let
         fun isTab c = (c = #"\t")
         val file :: url = String.tokens isTab (String.chop line)
         val url = if url = [] then file else List.hd url
         
         val docid = Misc.Pack.unpackWord (DBM.lookup db "nextId")
         val _ = DBM.replace db ("nextId", Misc.Pack.packWord (docid + 0w1)) (* increase nextId *) 
         val _ = DBM.insert db (Misc.Pack.packWord docid, url) (* store filename under docid in db *)
      in
         DefaultIndex.indexDocument inx (file, docid) 
      end
   
   val strm = TextIO.stdIn
in
   TextIO.appLines scanDocument strm;
   DefaultIndex.writeIndex inx indexFile;
   DBM.close db
end

val _ = main(CommandLine.name (), CommandLine.arguments ())
