with Types; use Types;

package body Latency is

   -----------------------------
   --  Example_Latency_Count  --
   -----------------------------

   function Example_Latency_Get
     (Plugin : CLAP_Plugin_Access)
      return UInt32_t
   is
      Plug : constant Example_Plugin :=
               Convert_Address_My_Plugin.To_Pointer (Plugin.Plugin_Data).all;
   begin
      return Plug.Latency;
   end Example_Latency_Get;

end Latency;
