(* 
 * Influenced by MLtons and John Reppys (SML/NJ) HashTable structure. 
 *
 * Copyright (c) 2002 by Michael Neumann
 *)
structure HashTable =
struct

datatype ('a, 'b) t = 
   HT of {buckets: (word * 'a * 'b) list array ref, 
          equals: 'a * 'a -> bool,
          hash: 'a -> word,
          mask: word ref,
          notFound : exn,
          numItems: int ref}

fun ('a, 'b) newWithBuckets {equals, hash, notFound, numBuckets}: ('a, 'b) t =
   let
      val mask: word = numBuckets - 0w1
   in
      HT {buckets = ref (Array.new (Word.toInt numBuckets, [])),
          equals = equals,
          hash = hash,
          mask = ref mask,
          notFound = notFound,
          numItems = ref 0}
   end

fun new {equals, hash, notFound, size} =
   newWithBuckets
   {equals = equals,
    hash = hash,
    notFound = notFound,
    numBuckets = Word.max (0w64, Word.roundUpToPowerOfTwo (Word.fromInt size))}

(* Return number of key/value pairs in table *)
fun size (HT {numItems, ...}) = !numItems

fun numBuckets (HT {buckets, ...}) = Array.length (!buckets)

fun getBuckets (HT {buckets, ...}) = (!buckets)

fun index (w: word, mask: word): int =
   Word.toInt (Word.andb (w, mask))
   
(* Remove all keys for which function p returns true *)
fun removeAll (HT {buckets, numItems, ...}, p) = 
   let
      fun f (a, ac) = if p a then (Int.dec numItems; ac) 
                             else a :: ac 
      fun g elts = List.foldr f [] elts
   in
      Array.modify g (!buckets)
   end

(* Remove all elements from the table *)
fun clear (HT {buckets, numItems, ...}) = 
   let
   in
      numItems := 0;
      Array.modify (fn _ => []) (!buckets)
   end

(* Insert an item.  If the key already has an item associated with it,
 * then the old item is discarded.
 *)
fun insert (HT{buckets, equals, hash, mask, numItems, ...}) (key, item) = 
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)

      fun ins [] = (Int.inc numItems; [(hv, key, item)]) (* new key *) 
        | ins ((t as (h, k, i)) :: xs) = 
             if hv = h andalso equals (key, k) (* key exists -> overwrite *)
                then (hv, key, item) :: xs 
             else
                t :: (ins xs)
   in
     Array.update (!buckets, ix, ins bucket)
   end

(* Insert an item if key not in table. *)
fun insertIfNew (HT{buckets, equals, hash, mask, numItems, ...}) (key, item) = 
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)

      fun ins [] = (Int.inc numItems; [(hv, key, item)]) (* new key *) 
        | ins (lst as ((t as (h, k, i)) :: xs)) = 
             if hv = h andalso equals (key, k) (* key exists -> exit *)
                then lst
             else
                t :: (ins xs)
   in
     Array.update (!buckets, ix, ins bucket)
   end

(* check whether key exits *)
fun inDomain (HT{buckets, equals, hash, mask, ...}) key = 
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)

      fun find [] = false (* key does not exist *)
        | find ( (h, k, _) :: xs ) =
             if hv = h andalso equals (key, k) (* key exists *)
                then true 
             else
                find xs
   in
      find bucket
   end

(* synonym for inDomain *)
val hasKey = inDomain


(* If item does not exist, insert it into table. Otherwise just return the value. *)
fun lookupOrInsert (HT{buckets, equals, hash, mask, numItems, ...}) (key, item) =
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)
      fun upd b = Array.update (!buckets, ix, b)

      fun loi [] = (Int.inc numItems; upd [(hv, key, item)]; item) (* key not found -> insert *) 
        | loi ((h, k, i) :: xs) = 
             if hv = h andalso equals (key, k) (* key found -> return value *)
                then i
             else
                loi xs
   in
     loi bucket
   end


(* look for an item, return NONE if the item doesn't exist *)
fun find (HT{buckets, equals, hash, mask, ...}) key = 
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)

      fun find [] = NONE (* key does not exist *)
        | find ( (h, k, i) :: xs ) =
             if hv = h andalso equals (key, k) (* key exists *)
                then SOME(i)
             else
                find xs
   in
      find bucket
   end

(* find an item, the table's exception is raised if the item doesn't exist *)
fun lookup (tab as HT{buckets, equals, hash, mask, notFound, ...}) key = 
   let 
   in
      case find tab key 
       of NONE => raise notFound
        | SOME(item) => item
   end      

(* Remove an item.  The table's exception is raised if
 * the item doesn't exist.
 *)
fun remove (HT{buckets, equals, hash, mask, notFound, ...}) key = 
   let
      val hv = hash key
      val ix = index (hv, !mask)
      val bucket = Array.sub (!buckets, ix)

      fun rmv [] = raise notFound (* key does not exist *) 
        | rmv ((t as (h, k, _)) :: xs) = 
             if hv = h andalso equals (key, k) (* key found -> remove *)
                then xs 
             else
                t :: (rmv xs)
   in
     Array.update (!buckets, ix, rmv bucket)
   end

fun listItems (HT{buckets, ...}) = 
   let
     fun extractItems (x, xs) = (List.map (fn (_,_,v) => v) x) @ xs
   in
      Array.foldr extractItems [] (!buckets)
   end

fun listItemsi (HT{buckets, ...}) = 
   let
     fun extractItems (x, xs) = (List.map (fn (_,k,v) => (k,v)) x) @ xs
   in
      Array.foldr extractItems [] (!buckets)
   end

end

(* 
fun hashString (s:string) = Word.fromInt(String.size s);

(* TEST *)
exception NotFound
val ht = HashTable.new {equals = (op =), hash = hashString, size = 128, notFound = NotFound}; 
val _ = HashTable.insert ht ("hall", "na dann suepr");
val _ = HashTable.insert ht ("hallo", "geil");

val l = HashTable.lookup ht "hall";
val _ = print (l ^ "\n");
val i = HashTable.size ht ;
val s = Int.toString i;
val _ = print (s ^ "\n");
*)
