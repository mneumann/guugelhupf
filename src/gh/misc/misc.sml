(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

structure Array = 
struct
   open Array
   val new = array 
end
structure Int =
struct
   open Int
   fun dec (n:int ref) = (n := !n - 1; !n)
   fun inc (n:int ref) = (n := !n + 1; !n)
end

structure Word =
struct
   open Word
   fun roundUpToPowerOfTwo (n:word) = 
      let 
         fun f i = if (i >= n) then i else f(Word.* (i, 0w2))
      in
         f 0w1 
      end

   fun dec (n:word ref) = (n := !n - 0w1; !n)
   fun inc (n:word ref) = (n := !n + 0w1; !n)
end

structure Error = 
struct
   fun unimplemented msg = raise Fail("unimplemented: " ^ msg)
   fun bug msg = raise (Fail msg)
end

fun assert (cond: bool) = 
   if cond = false then raise (Fail "assertion failed") else () 

structure Char = 
struct
   open Char
   (* copied from MLton basic/char0.sml *)
   fun digitToInt (c: char): int option =
      if isDigit c
         then SOME (ord c - ord #"0")
      else NONE
end

structure String = 
struct
   open String
   fun chop str = substring (str, 0, size str - 1)
   val downcase = String.map Char.toLower
   val upcase = String.map Char.toUpper

   val length = size

   (* from MLton basic/string0.sml *)
   fun dropPrefix (s, n) = 
      substring (s, n, (size s) - n)

end

structure TextIO =
struct
   open TextIO

   fun appLines (f: string -> unit) (strm: instream) : unit = 
      case TextIO.inputLine strm
       of "" => ()
        | line => (f line; appLines f strm)

   fun readLines (strm: instream) : string list = 
      let 
         fun loop lst = 
            case TextIO.inputLine strm
             of "" => lst 
              | line => loop (lst @ [line])
      in
         loop []
      end

end

