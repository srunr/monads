pragma Warnings (Off);
pragma Ada_2022;
with Ada.Text_IO;
with GNAT.Source_Info;
package body Monad_Functors is

   MRP_I : Monad_Record_Ptr; -- 220917 Internal copy of pointer to external Monad record pointer
                             -- EWP : Element_Wrapper_Ptr := Create_Element_Wrapper_Ptr;

   function Write(E : Element) return Monad_Element is
   begin
      MRP_I.E := E;
      return Write_Element(E);
   end Write;

   function Read(M : Monad_Element) return Element is
   begin
      return Read_Monad(MRP_I.M);
   end Read;

   function Read return Element is
   begin
      return Read_Monad(MRP_I.M);
   end Read;

   task body Element_Wrapper is
      Cnt       : Integer := 0;
      -- Write     : Writer_Function;
      -- Read      : Reader_Function;
      Initiated : Boolean := False;
      -- E1, E2 : Variable_String;

      function Error_Cond (VE_MRP : Monad_Record_Ptr := MRP) return String is
      begin
         return
           String
             ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
              " Element out of range for Monad_Element = " & MRP_I.E'Image);
      end Error_Cond;

   begin
      loop
         select
            accept Init (EW_MRP : Monad_Record_Ptr := MRP) do
               MRP_I     := EW_MRP;
               -- MRP_I.M := Write_Element(MRP_I.E);
               -- MRP_I.R := Read_Monad(MRP_I.M);
               Initiated := True;
            end Init;
         or when Initiated =>
            accept Unit (A : Element) do
               Cnt     := 0;
               MRP_I.E := A;
               MRP_I.M := Write_Element (MRP_I.E);
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Unit A = " & MRP_I.E'Image);
            end Unit;
         or when Initiated =>
               accept Bind (B_MRP : Monad_Record_Ptr := MRP;
                            WriteElement : in Writer_Function := Write'Access;
                            ReadMonad : in Reader_Function := Read'Access) do
               Cnt := Cnt + 1;
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Bind E = " & B_MRP.E'Image);
                  MRP_I.F := WriteElement;
                  Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Write'Image = " &
                  MRP_I.F'Image);
                  -- 220917 Store conditions when application of
                  -- Write generate error!
                  MRP_I.R := ReadMonad;
                 Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Read'Image = " &
                  MRP_I.R'Image);
                  -- 220917 Store conditions when application of
                  -- Read generate error!
                  -- apply F on A and catch if valid element

               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " M = " &
                  MRP_I.F(MRP_I.E)'Image); -- 221002 test to use MRP_I.F instead of Write
                  -- 221001 When pragma Suppress_All
                  -- raised PROGRAM_ERROR : EXCEPTION_ACCESS_VIOLATION
                  -- [2022-10-01 10:07:02] process exited with status 1,
                  --   elapsed time: 00.81s
                  -- 221001 When not pragma Suppress_All then
                  -- raised CONSTRAINT_ERROR : monad_functors.adb:60 access
                  --   check failed
                  -- [2022-10-01 18:22:06] process exited with status 1,
                  --   elapsed time: 00.21s

               if Monad_Valid_Element (MRP_I.E'Image, MRP_I.F (MRP_I.E)'Image)
               then
                  MRP_I.M := MRP_I.F (MRP_I.E);
               else
                  Ada.Text_IO.Put_Line
                    ("-- " & GNAT.Source_Info.File &
                     GNAT.Source_Info.Line'Image & " Error: " &
                     Error_Cond (MRP_I));
               end if;

               -- if not valid return error condition in object
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Bind with M and E = " & B_MRP.M'Image);
            end Bind;
         or
            terminate;
         end select;
      end loop;

   end Element_Wrapper;

   function Create_Monad_Record_Ptr return Monad_Record_Ptr is
   begin
      return new Monad_Record;
   end Create_Monad_Record_Ptr;

   function Create_Element_Wrapper_Ptr return Element_Wrapper_Ptr is
   begin
      return new Element_Wrapper (Create_Monad_Record_Ptr);
   end Create_Element_Wrapper_Ptr;

   function Copy_Monad_Record_Ptr return Monad_Record_Ptr is
   begin
      return MRP_I;
   end Copy_Monad_Record_Ptr;

   -- function Copy_Element_Wrapper_Ptr return Element_Wrapper_Ptr is
   -- begin
   --    return EWP;
   -- end Copy_Element_Wrapper_Ptr;

   -- function "*" (Left : Monad_Record; Right : Integer) return Monad_Record is
   --   M : Monad_Record := Left;
   -- begin
   --    M.M := M.F (M.E) * M.F (Right);
   --    return M;
   -- end "*";

end Monad_Functors;
