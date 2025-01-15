with System;

with CfA.Plugins; use CfA.Plugins;

package Extensions is

   use CfA;

   function My_Plugin_Get_Extension (Plugin   : CLAP_Plugin_Access;
                                       ID     : CfA.Chars_Ptr)
                                       return System.Address
     with Export => True, Convention => C;

end Extensions;
