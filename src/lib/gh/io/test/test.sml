open Posix.FileSys
open Posix.IO

val tWord = 0wx12345678;

fun testWrite (filename: string) = 
   let
      val fd = creat (filename, S.irwxu)
   in
      IO.writeWord fd tWord;
      close fd
   end

fun testRead (filename: string) = 
  let
     val fd = openf (filename, O_RDONLY, 0w0)
  in
    case IO.readWord fd
     of tWord => print "OK\n"
      | _     => print "FAILED\n"
  end

val file = "hallo.txt";
val _ = testWrite file;
val _ = testRead file;
