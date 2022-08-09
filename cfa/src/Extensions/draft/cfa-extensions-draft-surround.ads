--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2022 Marek Kuziel
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
--  This extension can be used to specify the channel mapping used by
--  the plugin.
--
--  To have consistent surround features across all the plugin instances,
--  here is the proposed workflow:
--  1. the plugin queries the host preferred channel mapping and
--     adjusts its configuration to match it.
--  2. the host checks how the plugin is effectively configured and honors it.
--
--  If the host decides to change the project's surround setup:
--  1. deactivate the plugin
--  2. host calls CLAP_Plugin_Surround.Changed
--  3. plugin calls CLAP_Host_Surround.Get_Preferred_Channel_Map
--  4. plugin eventually calls CLAP_Host_Surround.Changed
--  5. host calls CLAP_Plugin_Surround.Get_Channel_Map if changed
--  6. host activates the plugin and can start processing audio
--
--  If the plugin wants to change its surround setup:
--  1. call CLAP_Host.Request_Restart if the plugin is active
--  2. once deactivated plugin calls CLAP_Host_Surround.Changed
--  3. host calls CLAP_Plugin_Surround.Get_Channel_Map
--  4. host activates the plugin and can start processing audio

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Surround is

   CLAP_Ext_Surround : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.surround.draft/1");

   CLAP_Port_Surround : constant Char_Ptr :=
                          Interfaces.C.Strings.New_String ("surround");

   type CLAP_Surround_ID is
     (
      FL,   --  Front Left
      FR,   --  Front Right
      FC,   --  Front Center
      LFE,  --  Low Frequency
      BL,   --  Back Left
      BR,   --  Back Right
      FLC,  --  Front Left of Center
      FRC,  --  Front Right of Center
      BC,   --  Back Center
      SL,   --  Side Left
      SR,   --  Side Right
      TC,   --  Top Center
      TFL,  --  Front Left Height
      TFC,  --  Front Center Height
      TFR,  --  Front Right Height
      TBL,  --  Rear Left Height
      TBC,  --  Rear Center Height
      TBR   --  Rear Right Height
     ) with Size => 8;

   type CLAP_Channel_Map is
     array (Interfaces.C.size_t range <>) of CLAP_Surround_ID
     with Convention => C;

   type Get_Channel_Map_Function is access
     function (Plugin               : Plugins.CLAP_Plugin_Access;
               Is_Input             : Bool;
               Port_Index           : UInt32_t;
               Channel_Map          : out CLAP_Channel_Map;
               Channel_Map_Capacity : UInt32_t)
               return UInt32_t
     with Convention => C;
   --  Stores into the channel_map array, the surround identifer of each
   --  channels.
   --  Returns the number of elements stored in channel_map
   --  [main-thread]

   type Changed_Function_Plugin is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access)
     with Convention => C;
   --  Informs the plugin that the host preferred channel map has changed.
   --  [main-thread]

   type CLAP_Plugin_Surround is
      record
         Get_Channel_Map : Get_Channel_Map_Function := null;
         Changed         : Changed_Function_Plugin := null;
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

   type Get_Preferred_Channel_Map_Function is access
     procedure (Host                 : Hosts.CLAP_Host_Access;
                Channel_Map          : out CLAP_Channel_Map;
                Channel_Map_Capacity : UInt32_t;
                Channel_Count        : out UInt32_t)
     with Convention => C;
   --  Ask the host what is the prefered/project surround channel map.
   --  [main-thread]

   type CLAP_Host_Surround is
      record
         Changed                   : Changed_Function_Host := null;
         Get_Preferred_Channel_Map : Get_Preferred_Channel_Map_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Surround_Access is access CLAP_Host_Surround
     with Convention => C;

end CfA.Extensions.Draft.Surround;
