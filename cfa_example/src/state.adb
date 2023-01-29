with System.Address_To_Access_Conversions;

with Types; use Types;

package body State is

   package Convert is new System.Address_To_Access_Conversions (Example_Plugin);

   function Example_State_Save
     (Plugin : CLAP_Plugin_Access;
      Stream : CLAP_Output_Stream_Access)
      return Bool
   is
      P : Convert.Object_Pointer := Convert.To_Pointer (Plugin.Plugin_Data);
   begin
      return True;
   end Example_State_Save;

   function Example_State_Load
     (Plugin   : CLAP_Plugin_Access;
      Stream : CLAP_Input_Stream_Access)
      return Bool
   is
      P : Convert.Object_Pointer := Convert.To_Pointer (Plugin.Plugin_Data);
   begin
      return True;
   end Example_State_Load;

end State;
