with System.Address_To_Access_Conversions;

with CfA.Plugins; use CfA.Plugins;

with CfA.Extensions.Latency; use CfA.Extensions.Latency;

package Latency is

   use CfA;

   function Example_Latency_Get
     (Plugin : CLAP_Plugin_Access)
      return UInt32_t
     with Export => True, Convention => C;

   My_Plug_Latency     : CLAP_Plugin_Latency :=
                           (Get => Example_Latency_Get'Access);

   package Convert_Address_Latency is
     new System.Address_To_Access_Conversions (CLAP_Host_Latency);

end Latency;
