(*
 * Copyright (c) 2002 Michael Neumann <mneumann@ntecs.de>
 *)

structure RankingParser =
struct

structure Lex = struct
  open RankingLex
  open UserDeclarations
end

val default_pos_ranking = 1               (* + *)
val default_neg_ranking = ~1              (* - *)
val default_ranking = default_pos_ranking (* nothing *)

datatype rt = RankedTerm of (string * int)

fun parse (strm) : rt list = 
   let 
      val lexer = Lex.makeLexer (fn n => TextIO.inputN (strm, n))
      val cur_ranking = ref default_ranking
      fun construct () = 
         case lexer()
          of Lex.RANKING rank => (cur_ranking := rank; construct())
           | Lex.RANKING_POS => (cur_ranking := default_pos_ranking; construct()) 
           | Lex.RANKING_NEG => (cur_ranking := default_neg_ranking; construct())
           | Lex.TERM term => RankedTerm (term, !cur_ranking) :: construct()
           | Lex.EOF => [] 
   in
      construct ()
   end 

fun output (l: rt list) (outputFn) =
   case l
    of [] => print "\n"
     | RankedTerm (term, rank) :: tl => (outputFn ("(" ^ term ^ ", " ^ Int.toString rank ^ ")");
                                         output tl outputFn)
end

(*
val rankedList = RankingParser.parse TextIO.stdIn;
val _ = RankingParser.output rankedList;
*)
