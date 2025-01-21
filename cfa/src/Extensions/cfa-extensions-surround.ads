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
--  This extension can be used to specify the channel mapping used by the plugin.
--
--  To have consistent surround features across all the plugin instances,
--  here is the proposed workflow:
--  1. the plugin queries the host preferred channel mapping and
--     adjusts its configuration to match it.
--  2. the host checks how the plugin is effectively configured and honors it.
--
--  If the host decides to change the project's surround setup:
--  1. deactivate the plugin
--  2. host calls Clap_Plugin_Surround.Changed
--  3. plugin calls Clap_Host_Surround.Get_Preferred_Channel_Map
--  4. plugin eventually calls Clap_Host_Surround.Changed
--  5. host calls Clap_Plugin_Surround.Get_Channel_Map if changed
--  6. host activates the plugin and can start processing audio
--
--  If the plugin wants to change its surround setup:
--  1. call Host.Request_Restart if the plugin is active
--  2. once deactivated plugin calls Clap_Host_Surround.Changed
--  3. host calls Clap_Plugin_Surround.Get_Channel_Map
--  4. host activates the plugin and can start processing audio

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Surround is

   CLAP_Ext_Surround : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.surround.draft/2");

   CLAP_Port_Surround : constant CLAP_Chars_Ptr :=
                          Interfaces.C.Strings.New_String ("surround");

   type CLAP_Surround_ID is
     (
      CLAP_Surround_FL,   --  Front Left
      CLAP_Surround_FR,   --  Front Right
      CLAP_Surround_FC,   --  Front Center
      CLAP_Surround_LFE,  --  Low Frequency
      CLAP_Surround_BL,   --  Back Left
      CLAP_Surround_BR,   --  Back Right
      CLAP_Surround_FLC,  --  Front Left of Center
      CLAP_Surround_FRC,  --  Front Right of Center
      CLAP_Surround_BC,   --  Back Center
      CLAP_Surround_SL,   --  Side Left
      CLAP_Surround_SR,   --  Side Right
      CLAP_Surround_TC,   --  Top Center
      CLAP_Surround_TFL,  --  Front Left Height
      CLAP_Surround_TFC,  --  Front Center Height
      CLAP_Surround_TFR,  --  Front Right Height
      CLAP_Surround_TBL,  --  Rear Left Height
      CLAP_Surround_TBC,  --  Rear Center Height
      CLAP_Surround_TBR   --  Rear Right Height
     ) with Size => 8;

   type CLAP_Channel_Map is
     array (Interfaces.C.size_t range <>) of CLAP_Surround_ID
     with Convention => C;

   pragma Warnings (Off);
   type CLAP_Channel_Mask is
     array (CLAP_Surround_ID) of Boolean
     with Convention => C, Pack => True, Size => 64;
   pragma Warnings (On);

   -------------------------------------------------------------------------------------------------

   type Is_Channel_Mask_Supported_Function is access
     function (Plugin       : Plugins.CLAP_Plugin_Access;
               Channel_Mask : CLAP_Channel_Mask) return Bool
     with Convention => C;
   --  Checks if a given channel mask is supported.
   --  The channel mask is a bitmask, for example:
   --    (1 << Clap_Surround_FL) | (1 << Clap_Surround_FR) | ...
   --  [main-thread]

   type Get_Channel_Map_Function is access
     function (Plugin               : Plugins.CLAP_Plugin_Access;
               Is_Input             : Bool;
               Port_Index           : UInt32_t;
               Channel_Map          : out CLAP_Channel_Map;
               Channel_Map_Capacity : UInt32_t)
               return UInt32_t
     with Convention => C;
   --  Stores into the Channel_Map array, the surround identifer of each
   --  channels.
   --  Returns the number of elements stored in Channel_Map
   --
   --  Config_ID: the configuration id, see CLAP_Plugin_Audio_Ports_Config.
   --  If Config_ID is CLAP_Invalid_ID, then this function queries the current port info.
   --
   --  [main-thread]

   type CLAP_Plugin_Surround is
      record
         Is_Channel_Mask_Supported : Is_Channel_Mask_Supported_Function := null;
         Get_Channel_Map           : Get_Channel_Map_Function           := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Surround_Access is access CLAP_Plugin_Surround
     with Convention => C;

   type Changed_Function_Host is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the channel map has changed.
   --  The channel map can only change when the plugin is de-activated.
   --  [main-thread]

   type CLAP_Host_Surround is
      record
         Changed                   : Changed_Function_Host := null;
      end record
     with Convention => C;

   type CLAP_Host_Surround_Access is access CLAP_Host_Surround
     with Convention => C;

end CfA.Extensions.Surround;
