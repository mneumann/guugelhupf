
(* tokenizes and filters stopwords *)
structure SimpleAnalyser = 
struct
   open DS
   open Tokenizer.CharTableTransform
   
   structure Tokenizer = StringTokenizer
   structure TS = StopwordFilterFn(structure TS = Tokenizer) 

   fun tokenize (str: string, charTable) : string list = 
      let
         val ts = Tokenizer.new (str, charTable)
         fun tokenTerm (Token tok) = #term tok
      in
         Tokenizer.map tokenTerm ts
      end

  (* return two lists, the first which contains the passed tokens, the second
     the filtered ones *)
   fun filter (l: 'a list, itemFn: 'a -> string, stopwordTable: TS.table) : ('a list * 'a list) =
      case l
       of [] => ([], [])
        | (x :: xs) => (let 
                           val (a, b) = filter (xs, itemFn, stopwordTable) 
                        in
                           if HashTable.hasKey stopwordTable (itemFn x)
                           then (a, x :: b) 
                           else (x :: a, b) 
                        end)
                          
end
 
structure RankedQuery = 
struct

open DS
open RankingParser

(* maps doc_id's to ranks *)
structure DocIdMap = SplayMapFn (struct 
                                 type ord_key = doc_id
                                 val compare = Word.compare 
                                 end)


fun analyseQuery {strm, charTable, stopwordTable, outputFn} =
   let
      val p = outputFn 

      val q = RankingParser.parse strm
      val _ = (print "! parsed: "; RankingParser.output q p)

      fun fld (RankedTerm (term, rank), lst) = 
         let 
            val terms = SimpleAnalyser.tokenize (term, charTable)
         in
            lst @ List.map (fn t => RankedTerm(t, rank)) terms 
         end

      val q = List.foldl fld [] q 
      val _ = (print "! tokenized: "; RankingParser.output q p)

      val (q, stopwords) = SimpleAnalyser.filter (q, 
                                                  (fn (RankedTerm (i,_)) => i),
                                                  stopwordTable)
      val _ = (print "! filtered: "; RankingParser.output q p)
      val _ = (print "! stopwords: "; 
               List.app (fn (RankedTerm (i,_)) => print (i ^ " ")) stopwords;
               print "\n")
                                                                       
   in
      q 
   end
 
   
fun doQuery (rankedTerms, file, hash) = 
   let
      val res = FrequencyInvertedList.lookupTermsInFile {
                   file = file,
                   hash = hash,
                   terms = List.map (fn (RankedTerm(s,_)) => s) rankedTerms }

      fun comb (RankedTerm (term, rank), (t, queryResult)) = 
         let
            val _ = assert (term = t)       
         in
            (term, rank, queryResult) (* queryResult: (doc_id * word) list *)
         end
   in
      ListPair.map comb (rankedTerms, res)
   end

(* each document is ranked as follows: "frequency * rank" *)
fun rankQuery l scoreFn =
   let
      val map : (int ref) DocIdMap.map = DocIdMap.empty 

      fun sort c [] = []
        | sort c (s::xs) = sort c (List.filter (fn x => c(x, s) = LESS) xs) @
                           (s :: sort c (List.filter (fn x => c(x, s) = EQUAL) xs)) @
                           sort c (List.filter (fn x => c(x, s) = GREATER) xs) 

      fun rank ((_, rank, queryResult), map) = 
         let
            fun rank2 ((docid, freq), map) =
               let
                  val score = scoreFn {freq = Word.toInt freq, rank = rank}
               in 
                  case DocIdMap.find (map, docid)
                   of NONE => DocIdMap.insert (map, docid, ref score)
                    | SOME(rank) => (rank := (!rank) + score; map)  
               end 
         in
            List.foldl rank2 map queryResult
         end

     val rankedMap = List.foldl rank map l
     val rankedList = List.map (fn (docid, rank) => (docid, !rank)) (DocIdMap.listItemsi rankedMap) (* docid, rank *)
   in
      sort (fn ((_, rank), (_, rank2)) => Int.compare (rank2, rank)) rankedList
   end

fun outputQuery l outputFn =
   let
      val wordToString = Int.toString o Word.toInt
      val intToString = Int.toString

      (* docid rank/score *)
      fun output (docid, rank) = outputFn (wordToString docid ^ " " ^ intToString rank ^ "\n")
   in
      List.app output l
   end

fun query {strm, charTable, stopwordTable, outputFn, file, hash, scoreFn} = 
   let
      val l = analyseQuery {strm = strm, 
                            charTable = charTable,
                            stopwordTable = stopwordTable,
                            outputFn = outputFn}

      val l = doQuery (l, file, hash)
      val l = rankQuery l scoreFn
   in
      l
   end
 
end

(* TEST *)
(*
val q = RankedQuery.query {strm = TextIO.stdIn, 
                           charTable = Tokenizer.CharTableTransform.German,
                           stopwordTable = SimpleAnalyser.TS.mkTableFromFile "../filter/stopWords.en", 
                           outputFn = (fn s => TextIO.output (TextIO.stdErr, s)),
                           file = "test.index",
                           hash = Hashing.sdbmHash,
                           scoreFn = (fn {freq, rank} => freq * rank) }

val _ = RankedQuery.outputQuery q print 
*)
