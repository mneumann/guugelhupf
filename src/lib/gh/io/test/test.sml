fun test (fileName: string) = 
   let
      open Posix.FileSys
      val fd = creat (fileName, S.irwxu)
   in
      (*IO.writeString fd "hallo leute\n";*)
      IO.writeWord fd 0wx12345678;
      Posix.IO.close fd
   end

val _ = test "hallo.txt";
