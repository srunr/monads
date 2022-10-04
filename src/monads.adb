pragma Ada_2022;
with Ada.Text_IO;
with GNAT.Source_Info;
with Monad_Functors;
pragma Elaborate_All (Monad_Functors);
procedure Monads is
   pragma Suppress_All;
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
     (Integer, Float, WE, RM, Valid_Element);
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

   function Monad_Unit
     (A : in Integer; EWP : not null Element_Wrapper_Ptr := EW)
      return Element_Wrapper_Ptr
   is
   -- EW : Element_Wrapper(new Monad_Record);
   begin
      EWP.Unit (A);
      return EWP;
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

begin
   -- Obj.Init;
   Put_Line
     ("-- Running : " & GNAT.Source_Info.File & " : at Line : " &
      GNAT.Source_Info.Line'Image & " : Compiled at : " &
      GNAT.Source_Info.Compilation_Date);
   Put_Line ("-- " & GNAT.Source_Info.Line'Image & " Monads beginning");
   -- MR := Create_Monad_Record_Ptr;
   -- EW := Create_Element_Wrapper_Ptr;
   EW.Init;
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
      " Monad_Unit(1) = " & Monad_Unit (1)'Image);
   EW.Bind;
   Put_Line
     ("-- " & GNAT.Source_Info.File & GNAT.Source_Info.Line'Image &
      " Monad_Get_E = " & Monad_Get_E'Image);

   -- Copy_Monad_Record_Ptr.EMin := Integer (Check_Integer'First);
   -- Copy_Monad_Record_Ptr.EMax := Integer (Check_Integer'Last);
   -- Copy_Monad_Record_Ptr.MMin := Float (Check_Float'First);
   -- Copy_Monad_Record_Ptr.MMax := Float (Check_Float'Last);

end Monads;
