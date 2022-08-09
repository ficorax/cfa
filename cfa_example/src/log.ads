with System.Address_To_Access_Conversions;

with CfA.Extensions.Log; use CfA.Extensions.Log;

package Log is

   package Convert_Address_Host_Log is
     new System.Address_To_Access_Conversions (CLAP_Host_Log);

end Log;
