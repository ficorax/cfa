with System.Address_To_Access_Conversions;

with CfA; use CfA;

with CfA.Hosts; use CfA.Hosts;
with CfA.Plugins; use CfA.Plugins;

with CfA.Extensions.Latency; use CfA.Extensions.Latency;
with CfA.Extensions.Log; use CfA.Extensions.Log;
with CfA.Extensions.Thread_Check; use CfA.Extensions.Thread_Check;

package Types is

   type Example_Plugin is
      record
         Plugin            : CLAP_Plugin_Access := null;
         Host              : CLAP_Host_Access := null;
         Host_Latency      : CLAP_Host_Latency_Access := null;
         Host_Log          : CLAP_Host_Log_Access := null;
         Host_Thread_Check : CLAP_Host_Thread_Check_Access := null;
         Latency           : UInt32_t := 0;
      end record;

   type Example_Plugin_Access is access all Example_Plugin;

   package Convert_Address_My_Plugin is
     new System.Address_To_Access_Conversions (Example_Plugin);

end Types;
