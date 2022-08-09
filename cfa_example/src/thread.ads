with System.Address_To_Access_Conversions;

with CfA.Extensions.Thread_Check; use CfA.Extensions.Thread_Check;

package Thread is

   package Convert_Address_Thread_Check is
     new System.Address_To_Access_Conversions (CLAP_Host_Thread_Check);

end Thread;
