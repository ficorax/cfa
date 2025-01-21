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
--  This extensions let the plugin query info about the track it's in.
--  It is useful when the plugin is created, to initialize some parameters (mix, dry, wet)
--  and pick a suitable configuartion regarding audio port type and channel count.

with CfA.Hosts;
with CfA.Plugins;
with CfA.Colors;

package CfA.Extensions.Track_Infos is

   use type Interfaces.C.size_t;

   CLAP_Ext_Track_Info : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.track-info/1");

   CLAP_Ext_Track_Info_Compat : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.track-info.draft/1");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   type CLAP_Track_Info_Flag_Index is
     (
      CLAP_Track_Info_Has_Track_Name,
      CLAP_Track_Info_Has_Track_Color,
      CLAP_Track_Info_Has_Audio_Channel,

      CLAP_Track_Info_Is_For_Return_Track,
      -- This plugin is on a return track, initialize with wet 100%

      CLAP_Track_Info_Is_For_Bus,
      -- This plugin is on a bus track, initialize with appropriate settings for bus processing

      CLAP_Track_Info_Is_For_Master
      -- This plugin is on the master, initialize with appropriate settings for channel processing
     );

   pragma Warnings (Off);
   type CLAP_Track_Info_Flags is array (CLAP_Track_Info_Flag_Index) of Boolean
     with Pack, Size => UInt64_t'Size;
   pragma Warnings (On);

   type CLAP_Track_Info is
      record
         Flags                 : CLAP_Track_Info_Flags;
         --  Flags, see above

         Name                  : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         --  track name, available if flags contain CLAP_Track_Info_Has_Track_Name

         Color                 : CfA.Colors.CLAP_Color;
         --  track color, available if flags contain CLAP_Track_Info_Has_Track_Color

         Audio_Channel_Count   : UInt32_t := 0;
         --  availabe if flags contain CLAP_Track_Info_Has_Audio_Channel
         --  see Extensions.Audio_Ports, type CLAP_Audio_Port_Info to learn how to use channel
         --  count and port type

         Audio_Port_Type       : CLAP_Chars_Ptr := CLAP_Null_Ptr;
      end record
     with Convention => C;

   type CLAP_Track_Info_Access is access all CLAP_Track_Info
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Changed_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access)
     with Convention => C;
   --  Called when the info changes.
   --  [main-thread]

   type CLAP_Plugin_Track_Info is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Track_Info_Access is access CLAP_Plugin_Track_Info
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Get_Function is access
     function (Host : Hosts.CLAP_Host_Access;
               Info : CLAP_Track_Info_Access)
               return Bool
     with Convention => C;
   --  Get info about the track the plugin belongs to.
   --  [main-thread]

   type CLAP_Host_Track_Info is
      record
         Get : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Track_Info_Access is access all CLAP_Host_Track_Info
     with Convention => C;

end CfA.Extensions.Track_Infos;
