(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

datatype lexresult = EOF | TERM of string | RANKING of int | RANKING_POS | RANKING_NEG

fun eof () = EOF

%%

%structure RankingLex
%reject
%s TRM;

sign = [-+];
digit = [0-9];

ws = [\ \t\n];
nws = [^\ \t\n];

%%

{ws}+ => (lex());

<TRM> {nws}+ => (YYBEGIN(INITIAL); TERM(yytext)); 

<INITIAL> "(" {sign}? {digit}{1,3} ")" => (
                               let
                                  val rank = String.substring (yytext, 1, String.size yytext - 2)
                               in
                                 YYBEGIN(TRM);
                                 RANKING (valOf (Int.fromString rank))
                               end);

<INITIAL> [^-+\ \t\n] {nws}* => (TERM(yytext));
<INITIAL> "+" => (YYBEGIN(TRM); RANKING_POS); 
<INITIAL> "-" => (YYBEGIN(TRM); RANKING_NEG); 
