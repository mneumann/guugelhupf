val sdbm_hash = _ffi "sdbm": string * int -> word; 

structure StringHashKey : HASH_KEY =
struct
  type hash_key = string

  fun hashVal h = (*HashString.hashString h*) sdbm_hash (h, String.size h)

  fun sameKey (a, b) = (a = b)
end; 

structure HashTbl = HashTableFn (StringHashKey);
exception NotFound;


val ht : int HashTbl.hash_table = HashTbl.mkTable (500000, NotFound); 
(*val ht : (string, int) MyHT.t = MyHT.new (op =) *)

val is = TextIO.openIn "wordlist.a";

val line_nr = ref 1;

fun loop() =
  if TextIO.endOfStream is then ()
  else (
    let
     val str = TextIO.inputLine is
    in
      HashTbl.insert ht (str, !line_nr);
      line_nr := !line_nr + 1;
      loop()
    end
  )

val _ = loop();
val _ = print (Int.toString (MLton.size ht)); print "\n";

