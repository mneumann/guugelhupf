(** package DE.FantasyCoders.GH.IO; *)

structure IO = 
struct
   structure Prim = struct
      type fd = word 
      val errno = _ffi "errno" : word;
      val write_char = _ffi "IO_write_char" : (fd * char) -> int;
      val write_word8 = _ffi "IO_write_word8" : (fd * Word8.word) -> int;
      val write_word = _ffi "IO_write_word" : (fd * Word.word) -> int; 
      val write_int = _ffi "IO_write_int" : (fd * int) -> int;
      val write_string = _ffi "IO_write_string" : (fd * string) -> int;
      val write_wordArray = _ffi "IO_write_wordArray" : (fd * Word.word array) -> int;
      val write_wordVector = _ffi "IO_write_wordArray" : (fd * Word.word vector) -> int;
   end;

   type fd = Posix.IO.file_desc

   fun failure () =
      let 
         val err = Posix.Error.fromWord Prim.errno
      in
         raise OS.SysErr ("", SOME (err))
      end

   fun check (i:int) : int = if i = ~1 then failure () else i 

   val fdToWord = Posix.FileSys.fdToWord

   fun writeChar (fd: fd) (v: char) = check (Prim.write_char (fdToWord fd, v))
   fun writeWord8 (fd: fd) (v: Word8.word) = check (Prim.write_word8 (fdToWord fd, v))
   fun writeWord (fd: fd) (v: Word.word) = check (Prim.write_word (fdToWord fd, v))
   fun writeInt (fd: fd) (v: int) = check (Prim.write_int (fdToWord fd, v))
   fun writeString (fd: fd) (v: string) = check (Prim.write_string (fdToWord fd, v))
   fun writeWordArray (fd: fd) (v: Word.word array) = check (Prim.write_wordArray (fdToWord fd, v))
   fun writeWordVector (fd: fd) (v: Word.word vector) = check (Prim.write_wordVector (fdToWord fd, v))
end
