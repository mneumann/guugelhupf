fun insertIds db w =
   let
      val _ = DBM.insertIfNew db (Misc.Pack.packWord w, "haha") 
   in 
      if w = 0w0 then ()
      else insertIds db (w - 0w1)
   end

val db = DBM.new "test";
val _ = DBM.insertIfNew db ("hallo", "leute");
val _ = DBM.insertOrReplace db ("wie", "super"); 
val _ = print ((DBM.lookup db "wie") ^ "\n");
val _ = insertIds db 0w1000;
val _ = DBM.close db;

