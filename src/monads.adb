pragma Ada_2022;
with Ada.Text_IO;
with GNAT.Source_Info;
with Monad_Functors;
pragma Elaborate_All (Monad_Functors);
procedure Monads is
   -- pragma Suppress_All;
   -- Reference https://en.wikipedia.org/wiki/Monad_(functional_programming)
   use Ada.Text_IO;
   use GNAT.Source_Info;
   -- Package Integer_Variable_Strings is new Variable_Strings(Integer);
   -- use Integer_Variable_strings;
   -- Package Float_Varable_Strings is new Variable_Strings(Float);
   -- use Float_Varable_Strings;
   -- type constructor
   function WE (E : Integer) return Float is
   begin
      return Float (E);
   end WE;

   function RM (F : Float) return Integer is
   -- error : exception;
   begin
      return Integer (F);
   end RM;

   function Valid_Element (A : String; B : String) return Boolean is
      R : Boolean;
   begin
      R := Float'Value (B) = Float'Value (A);
      return R;
   end Valid_Element;

   package my_monad_functors is new Monad_Functors
     (Integer, Float, 0, WE, RM, Valid_Element, "/");
   use my_monad_functors;

   -- 220918 Objects to be manipulated by the
   --   monad_functor task type Element_Wrapper needs to be a protected type!!!!
   protected type Obj is
      --  Operations go here (only subprograms)
      procedure Set (L : in Element_Wrapper_Ptr);
      entry Get (L : in out Element_Wrapper_Ptr);
      -- function Get return Element_Wrapper_Ptr;
   private
      --  Data goes here
      Local  : Element_Wrapper_Ptr;
      Is_Set : Boolean := False;
   end Obj;

   protected body Obj is
      --  procedures can modify the data
      procedure Set (L : in Element_Wrapper_Ptr) is
      begin
         Local  := L;
         Is_Set := True;
      end Set;

      --  functions cannot modify the data
      entry Get (L : in out Element_Wrapper_Ptr) when Is_Set is
      begin
         L := Local;
      end Get;
   end Obj;

   function Init_Element_Wrapper return Element_Wrapper_Ptr is
      EW_Object : Obj;
      L         : Element_Wrapper_Ptr;
   begin
      EW_Object.Set (Create_Element_Wrapper_Ptr);
      EW_Object.Get (L);
      return L;
   end Init_Element_Wrapper;

   -- MR : Monad_Record_Ptr;
   -- EW_Object : Obj;
   EW : Element_Wrapper_Ptr := Init_Element_Wrapper;
   -- 220916 Use a Init entry in Element_Wrapper and a activated boolean function as entry barriers, to avoid program_errors
   -- 220916: like: raised PROGRAM_ERROR : monad_functors.adb:6 access before elaboration
   -- 220918 The task Type Element:Wrapper_Ptr object must be wrapped into a protected object, due to concurrent use of task type Element_Wrapper.
   EW2 : Element_Wrapper_Ptr := Init_Element_Wrapper;

   function Monad_Unit
     (A : in Integer; EWP : not null Element_Wrapper_Ptr := EW)
      return Float
   is
   -- EW : Element_Wrapper(new Monad_Record);
   begin
      EWP.Unit (A);
      return Copy_Monad_Record_Ptr.F(Copy_Monad_Record_Ptr.E);
   end Monad_Unit;

   function Monad_Bind
     (EWP : not null Element_Wrapper_Ptr := EW) return Element_Wrapper_Ptr
   is
   begin
      EWP.Bind;
      return EWP;
   end Monad_Bind;

   function Monad_Get
     (EWP : not null Element_Wrapper_Ptr := EW) return Monad_Record_Ptr
   is
   begin
      return Copy_Monad_Record_Ptr;
   end Monad_Get;

   function Monad_Get_E return Integer is
   begin
      return my_monad_functors.Read;
   end Monad_Get_E;

   subtype Check_Integer is Integer range Integer'First .. Integer'Last;
   subtype Check_Float is Float range Float'First .. Float'Last;

begin -- Monads
   -- Obj.Init;
   Put_Line
     ("-- Running : " & GNAT.Source_Info.File & " : at Line : " &
      GNAT.Source_Info.Line'Image & " : Compiled at : " &
      GNAT.Source_Info.Compilation_Date);
   Put_Line ("-- Line : " & GNAT.Source_Info.Line'Image &
             " Monads main beginning");
   -- MR := Create_Monad_Record_Ptr;
   -- EW := Create_Element_Wrapper_Ptr;
   EW.Init;
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
      " Monad_Unit(2) = " & Monad_Unit (2)'Image);
   EW.Bind;
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " Monad_Get_E = " & Monad_Get_E'Image);
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
      " Monad_Get.M = " & Monad_Get.M'Image);
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " Monad_Get.R(M) = " & Monad_Get.R(Copy_Monad_Record_Ptr.M)'Image);
   Monad_Bind.Unit(50);
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " M_Unit = " & M_Unit'Image);

   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " M_Div(50/5) = " & M_Div(50,5)'Image);


   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " M_Div(Monad_Get_E,5) = " & M_Div(Monad_get_E,5)'Image);


   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
        " Monad_Get_E * Monad_Get_E = " & Monad_Unit(Monad_Get_E * Monad_Get_E)'Image);


   -- Copy_Monad_Record_Ptr.EMin := Integer (Check_Integer'First);
   -- Copy_Monad_Record_Ptr.EMax := Integer (Check_Integer'Last);
   -- Copy_Monad_Record_Ptr.MMin := Float (Check_Float'First);
   -- Copy_Monad_Record_Ptr.MMax := Float (Check_Float'Last);

end Monads;

-- C:\Users\soren\OneDrive\ada2012\monads\obj\monads.exe
-- Running : monads.adb : at Line :  119 : Compiled at : Nov 08 2022
-- Line :  121 Monads main beginning
-- monad_functors.adb 58 Unit A =  2
-- monads.adb 127 Monad_Unit(2) =  2.00000E+00
-- monad_functors.adb 69 TID = (access ea6e20) Bind E =  2
-- monad_functors.adb 74 TID = (access ea6e20) Write'Image = (access subprogram 6dfb99)
-- monad_functors.adb 81 TID = (access ea6e20) Read'Image = (access subprogram 6dfb89)
-- monad_functors.adb 89 TID = (access ea6e20) M =  2.00000E+00
-- monad_functors.adb 116 Bind E to M =  2.00000E+00
-- monads.adb 131 Monad_Get_E =  2
-- monads.adb 134 Monad_Get.M =  2.00000E+00
-- monads.adb 137 Monad_Get.R(M) =  2
-- monad_functors.adb 69 TID = (access ea6e20) Bind E =  2
-- monad_functors.adb 74 TID = (access ea6e20) Write'Image = (access subprogram 6dfb99)
-- monad_functors.adb 81 TID = (access ea6e20) Read'Image = (access subprogram 6dfb89)
-- monad_functors.adb 89 TID = (access ea6e20) M =  2.00000E+00
-- monad_functors.adb 116 Bind E to M =  2.00000E+00
-- monad_functors.adb 58 Unit A =  50
-- monads.adb 141 M_Unit =  5.00000E+01
-- monads.adb 145 M_Div(50/5) =  1.00000E+01
-- [2022-11-08 22:00:44] process terminated successfully, elapsed time: 00.58s


-- C:\Users\soren\OneDrive\ada2012\monads\obj\monads.exe
-- Running : monads.adb : at Line :  119 : Compiled at : Nov 03 2022
-- Line :  121 Monads main beginning
-- monad_functors.adb 58 Unit A =  2
-- monads.adb 127 Monad_Unit(2) =  2.00000E+00
-- monad_functors.adb 69 TID = (access 1b7260) Bind E =  2
-- monad_functors.adb 74 TID = (access 1b7260) Write'Image = (access subprogram 6dfb99)
-- monad_functors.adb 81 TID = (access 1b7260) Read'Image = (access subprogram 6dfb89)
-- monad_functors.adb 89 TID = (access 1b7260) M =  2.00000E+00
-- monad_functors.adb 116 Bind E to M =  2.00000E+00
-- monads.adb 131 Monad_Get_E =  2
-- monads.adb 134 Monad_Get.M =  2.00000E+00
-- monads.adb 137 Monad_Get.R(M) =  2
-- monad_functors.adb 69 TID = (access 1b7260) Bind E =  2
-- monad_functors.adb 74 TID = (access 1b7260) Write'Image = (access subprogram 6dfb99)
-- monad_functors.adb 81 TID = (access 1b7260) Read'Image = (access subprogram 6dfb89)
-- monad_functors.adb 89 TID = (access 1b7260) M =  2.00000E+00
-- monad_functors.adb 116 Bind E to M =  2.00000E+00
-- monad_functors.adb 58 Unit A =  50
-- monads.adb 141 M_Unit =  5.00000E+01
-- monads.adb 145 M_Div(50/5) =  1.00000E+01
-- [2022-11-03 23:44:02] process terminated successfully, elapsed time: 00.75s

-- Build and run results in:
-- C:\Users\soren\OneDrive\ada2012\monads\obj\monads.exe
-- Running : monads.adb : at Line :  118 : Compiled at : Oct 04 2022
--  120 Monads beginning
-- monad_functors.adb 56 Unit A =  1
-- monads.adb 125 Monad_Unit(1) = (access 1071420)
-- monad_functors.adb 65 Bind E =  1
-- monad_functors.adb 69 Write'Image = (access subprogram 6cfc21)
-- monad_functors.adb 76 Read'Image = (access subprogram 6cfc11)
-- monad_functors.adb 84 M =  1.00000E+00
-- monad_functors.adb 109 Bind with M and E =  1.00000E+00
-- monads.adb 129 Monad_Get_E =  1
-- [2022-10-04 15:27:23] process terminated successfully, elapsed time: 00.15s
