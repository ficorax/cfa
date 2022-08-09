with CfA; use CfA;

with CfA.Plugin_Entry; use CfA.Plugin_Entry;
with CfA.Plugin_Factory; use CfA.Plugin_Factory;
with CfA.Version; use CfA.Version;

package CfA_Example is

   function Entry_Init (Path : Char_Ptr) return Bool
     with Export => True, Convention => C;

   procedure Entry_Deinit
     with Export => True, Convention => C;

   function Entry_Get_Factory
     (Factory_ID : Char_Ptr)
      return CLAP_Plugin_Factory_Access
     with Export => True, Convention => C;

   Example_Entry : CLAP_Entry :=
                     (CLAP_Version_Init,
                      Entry_Init'Access,
                      Entry_Deinit'Access,
                      Entry_Get_Factory'Access)
     with Export => True, Link_Name => "clap_entry";

end CfA_Example;
