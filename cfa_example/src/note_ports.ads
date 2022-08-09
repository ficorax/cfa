with CfA.Plugins; use CfA.Plugins;

with CfA.Extensions.Note_Ports; use CfA.Extensions.Note_Ports;

package Note_Ports is

   use CfA;

   function Example_Note_Ports_Count
     (Plugin : CLAP_Plugin_Access;
      Is_Input : Bool)
      return UInt32_t
     with Export => True, Convention => C;

   function Example_Note_Ports_Get
     (Plugin   : CLAP_Plugin_Access;
      Index    : UInt32_t;
      Is_Input : Bool;
      Info     : CLAP_Note_Port_Info_Access)
      return Bool
     with Export => True, Convention => C;

end Note_Ports;
