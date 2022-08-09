with CfA.Plugins; use CfA.Plugins;

with CfA.Extensions.Audio_Ports; use CfA.Extensions.Audio_Ports;

package Audio_Ports is

   use CfA;

   function Example_Audio_Ports_Count
     (Plugin : CLAP_Plugin_Access;
      Is_Input : Bool)
      return UInt32_t
   with Export => True, Convention => C;

   function Example_Audio_Ports_Get
     (Plugin   : CLAP_Plugin_Access;
      Index    : UInt32_t;
      Is_Input : Bool;
      Info     : CLAP_Audio_Port_Info_Access)
      return Bool
   with Export => True, Convention => C;

   My_Plug_Audio_Ports : CLAP_Plugin_Audio_Ports :=
                           (Example_Audio_Ports_Count'Access,
                            Example_Audio_Ports_Get'Access
                           );

end Audio_Ports;
