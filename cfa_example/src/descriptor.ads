with Interfaces.C.Strings; use Interfaces.C.Strings;

with CfA.Plugins; use CfA.Plugins;
with CfA.Plugin_Features; use CfA.Plugin_Features;
with CfA.Version; use CfA.Version;

package Descriptor is

   Example_Descriptor : aliased CLAP_Plugin_Descriptor :=
                            (CLAP_Version_Init,
                             New_String ("com.virtusada.cfa_example"),
                             New_String ("CfA Example"),
                             New_String ("VirtusAda"),
                             New_String ("https://virtusada.com"),
                             New_String ("https://virtusada.com"),
                             New_String ("https://virtusada.com"),
                             New_String ("0.0.1"),
                             New_String ("CLAP for Ada Example (based on plugin-template.c)"),
                             new Interfaces.C.Strings.chars_ptr_array'(
                               New_String (CLAP_Plugin_Feature_Instrument),
                               New_String (CLAP_Plugin_Feature_Stereo),
                               Interfaces.C.Strings.Null_Ptr));

end Descriptor;
