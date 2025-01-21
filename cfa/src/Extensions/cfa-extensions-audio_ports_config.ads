--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2025 Marek Kuziel
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in all
--  copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.

----------------------------------------------------------------------------------------------------
--  Audio Ports Config
--
--  This extension provides a way for the plugin to describe possible port
--  configurations, for example mono, stereo, surround, ... and a way for
--  the host to select a configuration.
--
--  After the plugin initialization, the host may scan the list of
--  configurations and eventually select one that fits the plugin context.
--  The host can only select a configuration if the plugin is deactivated.
--
--  A configuration is a very simple description of the audio ports:
--  - it describes the main input and output ports
--  - it has a name that can be displayed to the user
--
--  The idea behind the configurations, is to let the user choose one via
--  a menu.
--
--  Plugins with very complex configuration possibilities should let the user
--  configure the ports from the plugin GUI, and call
--  CLAP_Host_Audio_Ports.Rescan (CLAP_Audio_Ports_Rescan_All).
--
--  To inquire the exact bus layout, the plugin implements the CLAP_Plugin_Audio_Ports_Config_Info
--  extension where all busses can be retrieved in the same way as in the audio-port extension.

with CfA.Hosts;
with CfA.Plugins;

with CfA.Extensions.Audio_Ports;

package CfA.Extensions.Audio_Ports_Config is

   use Interfaces.C;
   use Interfaces.C.Strings;

   CLAP_Ext_Audio_Ports_Config : constant CLAP_Chars_Ptr :=
                                   New_String ("clap.audio-ports-config");

   CLAP_Ext_Audio_Ports_Config_Info : constant CLAP_Chars_Ptr :=
                                   New_String ("clap.audio-ports-config_info/1");

   CLAP_Ext_Audio_Ports_Config_Info_Compat : constant CLAP_Chars_Ptr :=
                                   New_String ("clap.audio-ports-config_info/draft-0");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   --  Minimalistic description of ports configuration
   type CLAP_Audio_Ports_Config is
      record
         ID                        : CLAP_ID;
         Name                      : char_array (0 .. CLAP_Name_Size - 1);

         Input_Port_Count          : UInt32_t := 0;
         Output_Port_Count         : UInt32_t := 0;

         --  main input info
         Has_Main_Input            : Bool     := False;
         Main_Input_Channel_Count  : UInt32_t := 0;
         Main_Input_Port_Type      : CLAP_Chars_Ptr := CLAP_Null_Ptr;

         --  main output info
         Has_Main_Output           : Bool     := False;
         Main_Output_Channel_Count : UInt32_t := 0;
         Main_Output_Port_Type     : CLAP_Chars_Ptr := CLAP_Null_Ptr;
      end record
     with Convention => C;

   type CLAP_Audio_Ports_Config_Access is access CLAP_Audio_Ports_Config
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   --  The audio ports config scan has to be done while the plugin is
   --  deactivated.

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  gets the number of available configurations
   --  [main-thread]

   type Get_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Index  : UInt32_t;
               Config : CLAP_Audio_Ports_Config_Access)
               return Bool
     with Convention => C;
   --  gets information about a configuration
   --  [main-thread]

   type Select_Config_Function is access
     function (Plugin    : Plugins.CLAP_Plugin_Access;
               Config_ID : CLAP_ID)
               return Bool
     with Convention => C;
   --  selects the configuration designated by id
   --  returns true if the configuration could be applied.
   --  Once applied the host should scan again the audio ports.
   --  [main-thread,plugin-deactivated]

   type CLAP_Plugin_Audio_Ports_Config is
      record
         Count         : Count_Function         := null;
         Get           : Get_Function           := null;
         Select_Config : Select_Config_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Audio_Ports_Config_Access is
     access CLAP_Plugin_Audio_Ports_Config
       with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Current_Config_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return CLAP_ID
     with Convention => C;
   --  Gets the id of the currently selected config, or CLAP_Invalid_ID if the current port
   --  layout isn't part of the config list.
   --
   --  [main-thread]

   type Get_Info_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Config_ID  : CLAP_ID;
               Port_Index : UInt32_t;
               Is_Input   : Bool;
               Info       : out Extensions.Audio_Ports.CLAP_Audio_Port_Info)
               return Bool
     with Convention => C;
   --  Get info about about an audio port, for a given config_id.
   --  This is analogous to CLAP_Plugin_Audio_Ports.Get.
   --  [main-thread]

   type CLAP_Plugin_Audio_Ports_Config_Info is
      record
         Current_Config : Current_Config_Function;
         Get            : Get_Info_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Rescan_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Rescan the full list of configs.
   --  [main-thread]

   type CLAP_Host_Audio_Ports_Config is
      record
         Rescan : Rescan_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Audio_Ports_Config_Access is access all CLAP_Host_Audio_Ports_Config
       with Convention => C;

end CfA.Extensions.Audio_Ports_Config;
