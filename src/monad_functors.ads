generic
   type Element is private;
   type Monad_Element is private;
   Zero : Element;
   with function Write_Element (E : Element) return Monad_Element;
   with function Read_Monad (M : Monad_Element) return Element;
   -- with package My_Variable_Strings is new Variable_Strings(Element);
   with function Monad_Valid_Element (E1 : String; E2 : String) return Boolean;
   -- with function "+" (Left: Element; Right : Monad_Element) return Element;
   -- with function "+" (Left: Monad_Element; Right: Element) return Element;
   -- with function "+" (Left: Element; Right : Monad_Element) return Monad_Element;
   -- with function "+" (Left: Monad_Element; Right: Element) return Monad_Element;
   -- with function "-" (Left: Element; Right : Monad_Element) return Element;
   -- with function "-" (Left: Monad_Element; Right: Element) return Element;
   -- with function "-" (Left: Element; Right : Monad_Element) return Monad_Element;
   -- with function "*" (Left: Monad_Element; Right: Element) return Monad_Element;
   -- with function "*" (Left: Element; Right : Monad_Element) return Element;
   -- with function "*" (Left: Monad_Element; Right: Element) return Element;
   -- with function "*" (Left: Element; Right : Monad_Element) return Monad_Element;
   -- with function "*" (Left: Monad_Element; Right: Element) return Monad_Element;
   -- with function "/" (Left: Element; Right : Monad_Element) return Element;
   -- with function "/" (Left: Monad_Element; Right: Element) return Element;
   -- with function "/" (Left: Element; Right : Monad_Element) return Monad_Element;
   -- with function "/" (Left: Monad_Element; Right: Element) return Monad_Element;
   with function "/" (Left: Monad_Element; Right: Monad_Element) return Monad_Element;

package Monad_Functors is
   -- Ref https://en.wikipedia.org/wiki/Monad_(functional_programming)
   type Monad_Func is protected interface;

   type Writer_Function is not null access function
     (E : in Element) return Monad_Element;
   type Reader_Function is not null access function
     (M : Monad_Element) return Element;

   -- type Combine_Op1 is not null access function
   --  (Left: Element, Right : Monad_Element) return Element;
   -- type Combine_Op2 is not null access function
   --  (Left: Monad_Element; Right: Element) return Element;
   -- type Combine_Op3 is not null access function
   --  (Left: Element, Right : Monad_Element) return Monad_Element;
   -- type Combine_Op4 is not null access function
   --  (Left: Monad_Element; Right: Element) return Monad_Element;


   function Write (E : Element) return Monad_Element;

   function Read (M : Monad_Element) return Element;

   function Read return Element;

   type Sets is
     (R, C, Z, Q, pos_R, pos_C, pos_Z, pos_Q, nonzero_R, nonzero_C, nonzero_Z);

   type Monad_Morphism is
     (isomorphic, homomorphic, automorphic, isomorphic_extenable);

   type Monad_Condition is (Valid, Nothing);

   type Monad_Record (morphic : Monad_Morphism := isomorphic_extenable)
   is record -- type constructor
      E    : Element; -- the entry set
      EMin : Element;
      EMax : Element;
      E_Zero: Element := Zero;
      M    : Monad_Element;  -- the extension that may be the result of F(E).
      -- M_Zero : Monad_Element
      MMin : Monad_Element;
      MMax : Monad_Element;
      F    : Writer_Function := Write'Access;
      R    : Reader_Function := Read'Access;
      C    : Monad_Condition := Valid;
   end record;

   type Monad_Record_Ptr is access Monad_Record;

   task type Element_Wrapper (MRP : not null Monad_Record_Ptr) is
      entry Init (EW_MRP : Monad_Record_Ptr := MRP);
      -- 220917 Need to control the start of the monad,
      -- due to the use of access to task type with Element_Wrapper_Ptr
      entry Unit (A : Element);
      entry Bind
        (B_MRP        :    Monad_Record_Ptr := MRP;
         WriteElement : in Writer_Function  := Write'Access;
         ReadMonad    : in Reader_Function  := Read'Access);
      -- entry Writer (B_MRP : Monad_Record_Ptr := MRP);
      entry Maybe (B_MRP : Monad_Record_Ptr := MRP);
      -- // The <T> represents a generic type "T"
      -- enum Maybe<T> {
      --   Just(T),
      --   Nothing,
      --   }
      -- entry List (B_MRP : Monad_Record_Ptr := MRP);
      -- entry IO (B_MRP : Monad_Record_Ptr := MRP);
      -- entry State (B_MRP : Monad_Record_Ptr := MRP);
      -- emtry Map (B_MRP : Monad_Record_Ptr := MRP); -- map ( a -> b) -> (ma -> mb)
      -- entry Future (B_MRP : Monad_Record_Ptr := MRP); -- collect operations to the future and next operation
   end Element_Wrapper;

   type Element_Wrapper_Ptr is access Element_Wrapper;

   -- function Create_Monad_Record_Ptr return Monad_Record_Ptr;
   function Create_Element_Wrapper_Ptr return Element_Wrapper_Ptr;
   function Copy_Monad_Record_Ptr return Monad_Record_Ptr;
   -- function Copy_Element_Wrapper_Ptr return Element_Wrapper_Ptr;
   -- function "*" (Left : Monad_Record; Right : Integer) return Monad_Record;
   function M_Unit (A : Element) return Monad_Element;
   function M_Unit return Monad_Element;
   procedure M_Bind
     (WriteElement : in Writer_Function := Write'Access;
      ReadMonad    : in Reader_Function := Read'Access);
   function M_Maybe return Monad_Element;
    -- function "+" (Left: Element; Right: Monad_Element) return Element;
    function M_Div( N : Element; D : Element) return Monad_Element;

end Monad_Functors;
