with System.Address_To_Access_Conversions;

with CfA.Plugins; use CfA.Plugins;
with CfA.Streams; use CfA.Streams;

with CfA.Extensions.State; use CfA.Extensions.State;

package State is

   use CfA;

   function Example_State_Save
     (Plugin : CLAP_Plugin_Access;
      Stream : CLAP_Output_Stream_Access)
      return Bool
   with Export => True, Convention => C;

   function Example_State_Load
     (Plugin : CLAP_Plugin_Access;
      Stream : CLAP_Input_Stream_Access)
      return Bool
   with Export => True, Convention => C;

   My_Plug_State : CLAP_Plugin_State :=
                           (Example_State_Save'Access,
                            Example_State_Load'Access);

   package Convert_Address_State is
     new System.Address_To_Access_Conversions (CLAP_Host_State);

end State;
