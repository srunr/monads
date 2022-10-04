generic
   type Element is private;
   type Monad_Element is private;
   with function Write_Element (E : Element) return Monad_Element;
   with function Read_Monad (M : Monad_Element) return Element;
   -- with package My_Variable_Strings is new Variable_Strings(Element);
   with function Monad_Valid_Element (E1 : String; E2 : String) return Boolean;
package Monad_Functors is

   -- type Monad_Func is protected interface;

   type Writer_Function is not null access function
     (E : in Element) return Monad_Element;
   type Reader_Function is not null access function
     (M : Monad_Element) return Element;

   function Write(E : Element) return Monad_Element;

   function Read(M : Monad_Element) return Element;

   function Read return Element;

   type Monad_Record is record
      E    : Element;
      EMin : Element;
      EMax : Element;
      M    : Monad_Element;
      MMin : Monad_Element;
      MMax : Monad_Element;
      F    : Writer_Function := Write'Access;
      R    : Reader_Function := Read'Access;
   end record;

   type Monad_Record_Ptr is access Monad_Record;

   task type Element_Wrapper (MRP : not null Monad_Record_Ptr) is
      entry Init
        (EW_MRP : Monad_Record_Ptr :=
           MRP);
      -- 220917 Need to control the start of the monad,
      -- due to the use of access to task type with Element_Wrapper_Ptr
      entry Unit (A : Element);
      entry Bind (B_MRP : Monad_Record_Ptr := MRP;
                  WriteElement : in Writer_Function := Write'Access;
                  ReadMonad : in Reader_Function := Read'Access);
   end Element_Wrapper;

   type Element_Wrapper_Ptr is access Element_Wrapper;

   -- function Create_Monad_Record_Ptr return Monad_Record_Ptr;
   function Create_Element_Wrapper_Ptr return Element_Wrapper_Ptr;
   function Copy_Monad_Record_Ptr return Monad_Record_Ptr;
   -- function Copy_Element_Wrapper_Ptr return Element_Wrapper_Ptr;
   -- function "*" (Left : Monad_Record; Right : Integer) return Monad_Record;

end Monad_Functors;
