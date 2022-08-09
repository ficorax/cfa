with CfA.Plugins; use CfA.Plugins;
with CfA.Processes; use CfA.Processes;

package Process is

   use CfA;

   function Example_Process
     (Plugin  : CLAP_Plugin_Access;
      Process : CLAP_Process_Access)
      return CLAP_Process_Status
     with Export => True, Convention => C;

   function Example_Start_Processing (Plugin : CLAP_Plugin_Access)
                                        return Bool
     with Export => True, Convention => C;

   procedure Example_Stop_Processing (Plugin : CLAP_Plugin_Access)
     with Export => True, Convention => C;

end Process;
