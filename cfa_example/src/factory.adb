with Interfaces.C.Strings; use Interfaces.C.Strings;

with CfA.Version; use CfA.Version;

package body Factory is

   -----------------------------
   --  Factory_Create_Plugin  --
   -----------------------------

   function Factory_Create_Plugin
     (Factory   : CLAP_Plugin_Factory_Access;
      Host      : CLAP_Host_Access;
      Plugin_ID : CfA.CLAP_Chars_Ptr)
      return CLAP_Plugin_Access
   is
      pragma Unreferenced (Factory);
   begin
      if not CLAP_Version_Is_Compatible (Host.Version) then
         return null;
      end if;

      for E of Export_Plugins loop
         if Value (Plugin_ID) = Value (E.Descriptor.ID) then
            return E.Create (Host);
         end if;
      end loop;

      return null;
   end Factory_Create_Plugin;

   --------------------------------
   --  Factory_Get_Plugin_Count  --
   --------------------------------

   function Factory_Get_Plugin_Count
     (Factory : CLAP_Plugin_Factory_Access)
      return UInt32_t
   is
      pragma Unreferenced (Factory);
   begin
      return Export_Plugins'Length;
   end Factory_Get_Plugin_Count;

   -------------------------------------
   --  Factory_Get_Plugin_Descriptor  --
   -------------------------------------

   function Factory_Get_Plugin_Descriptor
     (Factory : CLAP_Plugin_Factory_Access;
      Index   : UInt32_t)
      return CLAP_Plugin_Descriptor_Access
   is
      pragma Unreferenced (Factory);
   begin
      return Export_Plugins (Index).Descriptor;
   end Factory_Get_Plugin_Descriptor;

end Factory;
