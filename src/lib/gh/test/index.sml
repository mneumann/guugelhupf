open Tokenizer.CharTableTransform

fun main (name, args) =
let
   val usage = "USAGE: " ^ name ^ ": hashSize charTableFile stopwordFile indexFile"  

   val _ = if List.length args <> 4 then raise Fail(usage) else ()

   val [hashSize, charTableFile, stopwordFile, indexFile] = args

   val inx = DefaultIndex.new {size = (valOf o Int.fromString) hashSize,
                               stopwordFile = stopwordFile, 
                               charTable = mkCharTableFromFile charTableFile,  
                               outputFn = (fn str => TextIO.output (TextIO.stdErr, str))}

   (* format of a line: docid file *)
   fun scanDocument line =
      let
         val docid :: file :: rest = String.tokens Char.isSpace line
         val stringToDecWord = Word.fromInt o valOf o Int.fromString
      in
         DefaultIndex.indexDocument inx (file, stringToDecWord docid) 
      end
   
   val strm = TextIO.stdIn
in
   TextIO.appLines scanDocument strm;
   DefaultIndex.writeIndex inx indexFile
end

val _ = main(CommandLine.name (), CommandLine.arguments ())
