(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in the 
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *)

(* $Id$ *)

open Token_stream

  
class my_tokenizer : token_stream (in_stream : char Stream.t) = 
object
  val in_stream = in_stream
  method next = 
    let buf = Buffer.create 16 in
    try 
      match Stream.next in_stream with
        'A'..'Z' as c -> Buffer.add_char buf c 
      | 'a'..'z' as c -> Buffer.add_char buf c
      | _ -> if Buffer.length buf = 0 then 


class my_token_stream : token_stream =
object
  val mutable buffer = [ new token "hallo" 1; new token "bello" 2 ]
  method next = match buffer with
      [] -> raise Eos_exception
    | x::xs -> buffer <- xs; x
end
;;

(* main program *)
let ts = new my_token_stream in
  try 
    while true do
      let token = ts#next in
	print_string token#get_str ;
	print_string " ";
	print_int token#get_pos;
	print_newline ()
    done
  with 
      Eos_exception -> print_string "at the end"; print_newline () 
