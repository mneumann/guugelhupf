(*fun tf (n:int) = let
in 
  if (n >= Char.ord #"a" andalso n <= Char.ord #"z") then Char.chr n
  else if (n >= Char.ord #"A" andalso n <= Char.ord #"Z") then Char.chr (n - (Char.ord #"A") + (Char.ord #"a"))
  else Char.chr 0
end;

val ct = CharArray.extract (CharArray.tabulate (256, tf), 0, NONE); 
*)

open GH
open GH.Tokenizer.CharTableTransform;

val args = CommandLine.arguments ();
val file = hd args;
val s = MmapTokenizer.new (file, German);

fun loop() = 
  case MmapTokenizer.nextToken s
   of NONE => ()
    | SOME (Token {term, ...}) => (print term; print "\n"; loop())
  ;

val _ = loop();
