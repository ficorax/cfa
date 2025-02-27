with Interfaces.C.Strings; use Interfaces.C.Strings;

with CfA.Extensions.Audio_Ports; use CfA.Extensions.Audio_Ports;
with CfA.Extensions.Latency; use CfA.Extensions.Latency;
with CfA.Extensions.Note_Ports; use CfA.Extensions.Note_Ports;
with CfA.Extensions.State; use CfA.Extensions.State;

with Audio_Ports; use Audio_Ports;
with Latency; use Latency;
with Note_Ports; use Note_Ports;
with State; use State;

package body Extensions is

   -------------------------------
   --  My_Plugin_Get_Extension  --
   -------------------------------

   function My_Plugin_Get_Extension (Plugin   : CLAP_Plugin_Access;
                                       ID     : CfA.CLAP_Chars_Ptr)
                                       return System.Address
   is
      pragma Unreferenced (Plugin);
   begin
      if Value (ID) = Value (CLAP_Ext_Latency) then
         return My_Plug_Latency'Address;
      end if;

      if Value (ID) = Value (CLAP_Ext_Audio_Ports) then
         return My_Plug_Audio_Ports'Address;
      end if;

      if Value (ID) = Value (CLAP_Ext_Note_Ports) then
         return My_Plug_Note_Ports'Address;
      end if;

      if Value (ID) = Value (CLAP_Ext_State) then
         return My_Plug_State'Address;
      end if;

      --  TODO: add support to CLAP_EXT_PARAMS

      return System.Null_Address;
   end My_Plugin_Get_Extension;

end Extensions;
