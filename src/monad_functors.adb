pragma Warnings (Off);
pragma Ada_2022;
with Ada.Text_IO;
with GNAT.Source_Info;
with Ada.Task_Identification;
package body Monad_Functors is
   use Ada.Task_Identification;
   MRP_I : Monad_Record_Ptr; -- 220917 Internal copy of pointer to external Monad record pointer
   -- EWP : Element_Wrapper_Ptr := Create_Element_Wrapper_Ptr;

   function Write (E : Element) return Monad_Element is
   begin
      MRP_I.E := E;
      return Write_Element (E);
   end Write;

   function Read (M : Monad_Element) return Element is
   begin
      return Read_Monad (MRP_I.M);
   end Read;

   function Read return Element is
   begin
      return Read_Monad (MRP_I.M);
   end Read;

   task body Element_Wrapper is
      Cnt : Integer := 0;
      -- Write     : Writer_Function;
      -- Read      : Reader_Function;
      Initiated : Boolean := False;
      -- E1, E2 : Variable_String;

      function Error_Cond (VE_MRP : Monad_Record_Ptr := MRP) return String is
      begin
         return
           String
             (GNAT.Source_Info.File & GNAT.Source_Info.Line'Image & " : " &
              MRP_I.E'Image & " <> " & MRP_I.F (MRP_I.E)'Image & " : " &
              "MAP Error");
      end Error_Cond;

   begin -- task body Element Wrapper
      loop
         select
            accept Init (EW_MRP : Monad_Record_Ptr := MRP) do
               MRP_I := EW_MRP;
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
            accept Bind
              (B_MRP        :    Monad_Record_Ptr := MRP;
               WriteElement : in Writer_Function  := Write'Access;
               ReadMonad    : in Reader_Function  := Read'Access)
            do
               Cnt := Cnt + 1;
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " TID = " & Current_Task'Image & " Bind E = " &
                  B_MRP.E'Image);
               MRP_I.F := WriteElement;
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " TID = " & Current_Task'Image & " Write'Image = " &
                  MRP_I.F'Image);
               -- 220917 Store conditions when application of
               -- Write generate error!
               MRP_I.R := ReadMonad;
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " TID = " & Current_Task'Image & " Read'Image = " &
                  MRP_I.R'Image);
               -- 220917 Store conditions when application of
               -- Read generate error!
               -- apply F on A and catch if valid element

               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " TID = " & Current_Task'Image & " M = " &
                  MRP_I.F (MRP_I.E)'
                    Image); -- 221002 test to use MRP_I.F instead of Write
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
                  -- map fi : (a -> b) -> (ma -> mb)

               then
                  MRP_I.M := MRP_I.F (MRP_I.E);
               else
                  Ada.Text_IO.Put_Line
                    ("-- " & GNAT.Source_Info.File &
                     GNAT.Source_Info.Line'Image & " : " & Error_Cond (MRP_I));
               end if;

               -- if not valid return error condition in object
               Ada.Text_IO.Put_Line
                 ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
                  " Bind E to M = " & B_MRP.M'Image);
            end Bind;
         or when Initiated =>
            accept Maybe (B_MRP : Monad_Record_Ptr := MRP) do
               -- null;
               if Monad_Valid_Element (MRP_I.F (MRP_I.E)'Image, MRP_I.M'Image)
               then
                  null; --
               else
                  -- null;
                  Ada.Text_IO.Put_Line
                    ("-- " & GNAT.Source_Info.File &
                     GNAT.Source_Info.Line'Image & " nothing : " &
                     B_MRP.M'Image);
               end if;
            end Maybe;
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

   function M_Unit (A : Element) return Monad_Element is
   begin
      Copy_Monad_Record_Ptr.E := A;

      return Copy_Monad_Record_Ptr.F (Copy_Monad_Record_Ptr.E);
   end M_Unit;

   function M_Unit return Monad_Element is
   begin
      return Copy_Monad_Record_Ptr.F (Copy_Monad_Record_Ptr.E);
   end M_Unit;

   procedure M_Bind
     (WriteElement : in Writer_Function := Write'Access;
      ReadMonad    : in Reader_Function := Read'Access)
   is
   begin
      Copy_Monad_Record_Ptr.F := WriteElement;
      Copy_Monad_Record_Ptr.R := ReadMonad;
   end M_Bind;

   function M_Maybe return Monad_Element is
   begin
      if Monad_Valid_Element(Copy_Monad_Record_Ptr.F(Copy_Monad_Record_Ptr.E)'Image,
                             Copy_Monad_Record_Ptr.M'Image) then

         return Copy_Monad_Record_Ptr.M;
      else
         return Copy_Monad_Record_Ptr.M;
      end if;

   end M_Maybe;

   -- function "+" (Left: Element; Right: Monad_Element) return Element is
   -- begin
   --   return Copy_Monad_Record_Ptr.E + Copy_Monad_Record_Ptr.R(Copy_Monad_Record_Ptr.M);
   -- end "+";

   function M_Div( N : Element; D : Element) return Monad_Element is
   begin
      if Monad_Valid_Element(D'Image,"0") then
         MRP_I.C := Nothing;
         MRP_I.E := MRP_I.EMax;
         MRP_I.M := MRP_I.F(MRP_I.E);
         return MRP_I.M;
      else
         return MRP_I.F(N) / MRP_I.F(D);
      end if;

   end M_Div;

   -- function "/" (Left : Element: Right : Element) return Monad_Element is
   -- begin
   --   retun M_Div(Left,Right);
   -- end "/";


end Monad_Functors;
