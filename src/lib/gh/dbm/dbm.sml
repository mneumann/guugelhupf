(*
 * Copyright (c) 2002 Michael Neumann <neumann@s-direktnet.de>
 *)

structure DBM :> sig

   type dbm

   val new : string -> dbm
   val new2 : (string * word * word) -> dbm
   val close : dbm -> unit
   val insertIfNew : dbm -> (string * string) -> unit
   val insertOrReplace : dbm -> (string * string) -> unit
   val delete : dbm -> string -> unit
   val deleteIfExist : dbm -> string -> unit
   val find : dbm -> string -> string option
   val lookup : dbm -> string -> string

end = struct

   structure Prim = struct
      type dbm = word

      val errno = _ffi "errno" : word;
      val dbm_open = _ffi "DBM_open" : (string * word * word) -> dbm;
      val dbm_close = _ffi "DBM_close" : dbm -> unit;
      val dbm_store = _ffi "DBM_store" : (dbm * string * string * word) -> int;
      val dbm_delete = _ffi "DBM_delete" : (dbm * string) -> int; 
      val dbm_fetch = _ffi "DBM_fetch" : (dbm * string * Misc.CStruct.t) -> int; 
      val dbm_fetch_buf = _ffi "DBM_fetch_buf" : (Misc.CStruct.t * CharArray.array) -> unit; 
      val dbm_error = _ffi "DBM_error" : dbm -> word;
      val dbm_clearerr = _ffi "DBM_clearerr" : dbm -> int;
      val dbm_dirfno = _ffi "DBM_dirfno" : dbm -> int;

      val O_RDONLY = _ffi "DBM_O_RDONLY" : word;
      val O_RDWR = _ffi "DBM_O_RDWR" : word;
      val O_CREAT = _ffi "DBM_O_CREAT" : word;
      val O_EXCL = _ffi "DBM_O_EXCL" : word;
      val O_FSYNC = _ffi "DBM_O_FSYNC" : word;
      val O_NOFOLLOW = _ffi "DBM_O_NOFOLLOW" : word;
      val DBM_INSERT = _ffi "DBM_INSERT_C" : word;
      val DBM_REPLACE = _ffi "DBM_REPLACE_C" : word;
   end;

   exception Error of (OS.syserror * string)

   type dbm = Prim.dbm

   fun failure errno = 
      let 
         val syserr = Posix.Error.fromWord errno
         val errmsg = Posix.Error.errorMsg syserr
      in 
         raise Error (syserr, errmsg)
      end

   fun new2 (base: string, flags: word, mode: word) = 
      let 
         val db = Prim.dbm_open (base ^ "\000", flags, mode)
      in
        if db = 0w0 then failure (Prim.errno)
        else db 
      end 

   fun new (base: string) = new2 (base, Word.orb (Prim.O_RDWR, Prim.O_CREAT), 0w420 (* 0644 *)) 

   val close = Prim.dbm_close

   fun genInsert (db, key, data, mode) = 
      let
         val res = Prim.dbm_store (db, key, data, mode)
      in
         case res 
          of ~1 => failure (Prim.dbm_error db)
           | 1  => raise Error (0, "dbm: Could not insert entry")
           | _  => ()
      end

   fun insertIfNew (db: dbm) (key: string, data: string) = 
      genInsert (db, key, data, Prim.DBM_INSERT)

   fun insertOrReplace (db: dbm) (key: string, data: string) = 
      genInsert (db, key, data, Prim.DBM_REPLACE)

   fun delete (db: dbm) (key: string) =  
      let
         val res = Prim.dbm_delete (db, key)
      in
         case res 
          of ~1 => failure (Prim.dbm_error db)
           | 1  => raise Error (0, "dbm: Could not delete entry")
           | _  => ()
      end

   fun deleteIfExist (db: dbm) (key: string) =  
      let
         val res = Prim.dbm_delete (db, key)
      in
         case res 
          of ~1 => failure (Prim.dbm_error db)
           | _  => ()
      end

   fun find (db: dbm) (key: string) = 
      let
         val c = Misc.CStruct.new 4 (* buffer for one word *)
         val res = Prim.dbm_fetch (db, key, c)
      in
         if res = ~1 then NONE
         else 
           let
              val buf = CharArray.array (res, #"\000")
           in
              Prim.dbm_fetch_buf (c, buf);
              SOME (CharArray.extract (buf, 0, NONE))
           end
      end


   fun lookup (db: dbm) (key: string) = 
      case find db key 
       of NONE => raise Error (0, "dbm: Could not fetch entry")
        | SOME (d) => d

end
