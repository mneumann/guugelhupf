(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

(* Global definitions for GH  *)


(* Document ID *)
type doc_id = word

(* Type that represents a token in a document. *)
datatype token = Token of {
   term     : string,       (* Text of the token. *)
   position : word,         (* Position of token in the document. *)
   kind     : string option (* Kind of token (e.g. "title" or "emph"). *)
} 

signature TOKEN_STREAM = 
  sig
     type t
     val nextToken : t -> token option 

     val toList : t -> token list
     val app : (token -> unit) -> t -> unit
     val map : (token -> 'a) -> t -> 'a list  
  end
