with Interfaces.C.Strings; use Interfaces.C.Strings;

with Factory; use Factory;

package body CfA_Example is

   ------------------
   --  Entry_Init  --
   ------------------

   function Entry_Init (Path : CfA.Chars_Ptr) return Bool
   is
      pragma Unreferenced (Path);
   begin
      --  called only once, and very first
      return Bool'(True);
   end Entry_Init;

   ------------------
   --  Entry_Deinit  --
   ------------------

   procedure Entry_Deinit is
   begin
      --  called before unloading the DSO
      null;
   end Entry_Deinit;

   -------------------------
   --  Entry_Get_Factory  --
   -------------------------

   function Entry_Get_Factory
     (Factory_ID : CfA.Chars_Ptr)
      return CLAP_Plugin_Factory_Access
   is
   begin

      if Value (Factory_ID) = Value (CLAP_Plugin_Factory_ID) then
         return Example_Factory'Access;
      end if;

      return null;
   end Entry_Get_Factory;

end CfA_Example;
