(* 
 * A structure that stores the content of a C-record in a SML
 * array. Used to iterface with functions written in C.
 *)
structure CStruct :> 
  sig 
    type t
    val new : int -> t
  end = 
  struct
    type t = Word8Array.array 
    fun new (size:int) = Word8Array.array (size, 0w0) 
  end;
