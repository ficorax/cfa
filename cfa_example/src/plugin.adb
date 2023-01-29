with CfA.Extensions.Latency; use CfA.Extensions.Latency;
with CfA.Extensions.Log; use CfA.Extensions.Log;
with CfA.Extensions.State; use CfA.Extensions.State;
with CfA.Extensions.Thread_Check; use CfA.Extensions.Thread_Check;

with Descriptor; use Descriptor;
with Extensions; use Extensions;
with Latency; use Latency;
with Log; use Log;
with Process; use Process;
with State; use State;
with Thread; use Thread;
with Types; use Types;

package body Plugin is

   Example_Instance  : Example_Plugin;

   ------------------------
   --  Example_Activate  --
   ------------------------

   function Example_Activate
     (Plugin           : CLAP_Plugin_Access;
      Sample_Rate      : CLAP_Double;
      Min_Frames_Count : UInt32_t;
      Max_Frames_Count : UInt32_t)
      return Bool
   is
      pragma Unreferenced (Plugin,
                           Sample_Rate,
                           Min_Frames_Count,
                           Max_Frames_Count);
   begin
      return Bool'(True);
   end Example_Activate;

   --------------------------
   --  Example_Deactivate  --
   --------------------------

   procedure Example_Deactivate (Plugin : CLAP_Plugin_Access) is null;

   -----------------------
   --  Example_Destroy  --
   -----------------------

   procedure Example_Destroy (Plugin : CLAP_Plugin_Access)
   is
      pragma Unreferenced (Plugin);
   begin
      null;
   end Example_Destroy;

   --------------------
   --  Example_Init  --
   --------------------

   function Example_Init (Plugin : CLAP_Plugin_Access) return Bool
   is
      Plug : constant Example_Plugin_Access :=
               Example_Plugin_Access (Convert_Address_My_Plugin.To_Pointer (Plugin.Plugin_Data));
   begin
      --  Make sure to check that the interface functions are not null pointers
      Plug.Host_Log := CLAP_Host_Log_Access
        (Convert_Address_Host_Log.To_Pointer
           (Plug.Host.Get_Extension (Plug.Host, CLAP_Ext_Log)));

      Plug.Host_Thread_Check := CLAP_Host_Thread_Check_Access
        (Convert_Address_Thread_Check.To_Pointer
           (Plug.Host.Get_Extension (Plug.Host, CLAP_Ext_Thread_Check)));

      Plug.Host_Latency := CLAP_Host_Latency_Access
        (Convert_Address_Latency.To_Pointer
           (Plug.Host.Get_Extension (Plug.Host, CLAP_Ext_Latency)));

      Plug.Host_State := CLAP_Host_State_Access
        (Convert_Address_State.To_Pointer
           (Plug.Host.Get_Extension (Plug.Host, CLAP_Ext_State)));

      return Bool'(True);
   end Example_Init;

   ------------------------------
   --  Example_On_Main_Thread  --
   ------------------------------

   procedure Example_On_Main_Thread (Plugin : CLAP_Plugin_Access) is null;

   ---------------------
   --  Example_Reset  --
   ---------------------

   procedure Example_Reset (Plugin : CLAP_Plugin_Access) is null;

   ----------------------
   --  Example_Create  --
   ----------------------

   function Example_Create (Host : CLAP_Host_Access) return CLAP_Plugin_Access
   is
      PP : constant CLAP_Plugin_Access := new CLAP_Plugin;
   begin
      Example_Instance.Host := Host;
      Example_Instance.Plugin := PP;

      Example_Instance.Plugin.Descriptor := Example_Descriptor'Access;
      Example_Instance.Plugin.Plugin_Data := Example_Instance'Address;

      Example_Instance.Plugin.Init := Example_Init'Access;
      Example_Instance.Plugin.Destroy := Example_Destroy'Access;
      Example_Instance.Plugin.Activate := Example_Activate'Access;
      Example_Instance.Plugin.Deactivate := Example_Deactivate'Access;
      Example_Instance.Plugin.Start_Processing := Example_Start_Processing'Access;
      Example_Instance.Plugin.Stop_Processing := Example_Stop_Processing'Access;
      Example_Instance.Plugin.Reset := Example_Reset'Access;
      Example_Instance.Plugin.Process := Example_Process'Access;
      Example_Instance.Plugin.Get_Extension := My_Plugin_Get_Extension'Access;
      Example_Instance.Plugin.On_Main_Thread := Example_On_Main_Thread'Access;

      return Example_Instance.Plugin;
   end Example_Create;

end Plugin;
