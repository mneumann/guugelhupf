(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *)

(* generic definitions for all Tokenizer/TokenStreams *)

structure TokenStream0 = 
struct
   fun map nextToken f t =
      case nextToken t 
       of NONE => [] 
       | SOME(tok) => f tok :: map nextToken f t

   fun toList nextToken = map nextToken (fn x => x) 

   fun app nextToken f t = 
      case nextToken t
       of NONE => ()
        | SOME(tok) => (f tok; app nextToken f t)
end

