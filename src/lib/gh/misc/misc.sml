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
