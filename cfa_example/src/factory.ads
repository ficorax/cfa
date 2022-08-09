with CfA.Hosts; use CfA.Hosts;
with CfA.Plugin_Factory; use CfA.Plugin_Factory;
with CfA.Plugins; use CfA.Plugins;

with Descriptor; use Descriptor;
with Plugin; use Plugin;

package Factory is

   use CfA;

   type Create_Function is access
     function (Host : CLAP_Host_Access) return CLAP_Plugin_Access
     with Convention => C;

   type CLAP_Export_Plugins is
      record
         Descriptor : CLAP_Plugin_Descriptor_Access;
         Create     : Create_Function;
      end record
     with Convention => C;

   type CLAP_Export_Plugins_Array is
     array (UInt32_t range <>) of CLAP_Export_Plugins;

   Export_Plugins : constant CLAP_Export_Plugins_Array
     := (0 => (Example_Descriptor'Access,
               Example_Create'Access));

   function Factory_Get_Plugin_Count
     (Factory : CLAP_Plugin_Factory_Access)
      return UInt32_t
     with Export => True, Convention => C;

   function Factory_Get_Plugin_Descriptor
     (Factory : CLAP_Plugin_Factory_Access;
      Index   : UInt32_t)
      return CLAP_Plugin_Descriptor_Access
     with Export => True, Convention => C;

   function Factory_Create_Plugin
     (Factory   : CLAP_Plugin_Factory_Access;
      Host      : CLAP_Host_Access;
      Plugin_ID : Char_Ptr)
      return CLAP_Plugin_Access
     with Export => True, Convention => C;

   Example_Factory : aliased CLAP_Plugin_Factory :=
                       (Factory_Get_Plugin_Count'Access,
                        Factory_Get_Plugin_Descriptor'Access,
                        Factory_Create_Plugin'Access);

end Factory;
