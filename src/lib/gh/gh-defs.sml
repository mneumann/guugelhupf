(* 
 * Global definitions for GH 
 *)


(* Document ID *)
type doc_id = word

(* Type that represents a token in a document. *)
datatype token = Token of {
   term     : string,       (* Text of the token. *)
   position : word,         (* Position of token in the document. *)
   kind     : string option (* Kind of token (e.g. "title" or "emph"). *)
} 
