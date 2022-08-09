with CfA; use CfA;

with CfA.Hosts; use CfA.Hosts;
with CfA.Plugins; use CfA.Plugins;

package Plugin is

   function Example_Create (Host : CLAP_Host_Access) return CLAP_Plugin_Access
     with Export => True, Convention => C;

   function Example_Init (Plugin : CLAP_Plugin_Access)
                            return Bool
     with Export => True, Convention => C;

   procedure Example_Destroy (Plugin : CLAP_Plugin_Access)
     with Export => True, Convention => C;

   function Example_Activate
     (Plugin           : CLAP_Plugin_Access;
      Sample_Rate      : CLAP_Double;
      Min_Frames_Count : UInt32_t;
      Max_Frames_Count : UInt32_t)
      return Bool
     with Export => True, Convention => C;

   procedure Example_Deactivate (Plugin : CLAP_Plugin_Access)
     with Export => True, Convention => C;

   procedure Example_Reset (Plugin : CLAP_Plugin_Access)
     with Export => True, Convention => C;

   procedure Example_On_Main_Thread (Plugin : CLAP_Plugin_Access)
     with Export => True, Convention => C;

end Plugin;
