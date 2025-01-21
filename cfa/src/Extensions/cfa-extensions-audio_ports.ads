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
--  Audio Ports
--
--  This extension provides a way for the plugin to describe its current audio
--  ports.
--
--  If the plugin does not implement this extension, it won't have audio ports.
--
--  32 bits support is required for both host and plugins. 64 bits audio is
--  optional.
--
--  The plugin is only allowed to change its ports configuration while it is
--  deactivated.

limited with CfA.Hosts;
limited with CfA.Plugins;

package CfA.Extensions.Audio_Ports is

   use Interfaces.C;
   use Interfaces.C.Strings;

   CLAP_Ext_Audio_Ports : constant CLAP_Chars_Ptr := New_String ("clap.audio-ports");
   CLAP_Port_Mono       : constant CLAP_Chars_Ptr := New_String ("mono");
   CLAP_Port_Stereo     : constant CLAP_Chars_Ptr := New_String ("stereo");

   type Audio_Port_Type_Index is
     (

      CLAP_Audio_Port_Is_Main,
      --  This port is the main audio input or output.
      --  There can be only one main input and main output.
      --  Main port must be at index 0.

      CLAP_Audio_Port_Supports_64bits,
      --  This port can be used with 64 bits audio

      Prefers_64bits,
      --  64 bits audio is preferred with this port

      CLAP_Audio_Port_Requires_Common_Sample_Size
      --  This port must be used with the same sample size as all the other
      --  ports which have this flag. In other words if all ports have this flag
      --  then the plugin may either be used entirely with 64 bits audio or
      --  32 bits audio, but it can't be mixed.
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Audio_Port_Type is array (Audio_Port_Type_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type CLAP_Audio_Port_Info is
      record
         ID            : CLAP_ID;
         --  id identifies a port and must be stable.
         --  id may overlap between input and output ports.

         Name          : char_array (0 .. CLAP_Name_Size - 1); --  displayable name

         Flags         : CLAP_Audio_Port_Type := (others => False);

         Channel_Count : UInt32_t             := 0;

         Port_Type     : CLAP_Chars_Ptr             := CLAP_Null_Ptr;
         --  If null or empty then it is unspecified (arbitrary audio).
         --  This filed can be compared against:
         --  - CLAP_Port_Mono
         --  - CLAP_Port_Stereo
         --  - CLAP_Port_Surround (defined in the surround extension)
         --  - CLAP_Port_Ambisonic (defined in the ambisonic extension)
         --
         --  An extension can provide its own port type and way to inspect
         --  the channels.

         In_Place_Pair : CLAP_ID;
         --  in-place processing: allow the host to use the same buffer for
         --  input and output if supported set the pair port id.
         --  if not supported set to CLAP_INVALID_ID
      end record
   with Convention => C;

   type CLAP_Audio_Port_Info_Access is access CLAP_Audio_Port_Info
     with Convention => C;

   type Count_Function is access
     function (Plugin   : Plugins.CLAP_Plugin_Access;
               Is_Input : Bool)
               return UInt32_t
     with Convention => C;
   --  Number of ports, for either input or output
   --  [main-thread]

   type Get_Function is access
     function (Plugin   : Plugins.CLAP_Plugin_Access;
               Index    : UInt32_t;
               Is_Input : Bool;
               Info     : CLAP_Audio_Port_Info_Access)
               return Bool
     with Convention => C;
   --  Get info about an audio port.
   --  Returns true on success and stores the result into info.
   --  [main-thread]

   --  The audio ports scan has to be done while the plugin is deactivated.
   type CLAP_Plugin_Audio_Ports is
      record
         Count : Count_Function := null;
         Get   : Get_Function   := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Audio_Ports_Access is access CLAP_Plugin_Audio_Ports
     with Convention => C;

   type Audio_Port_Rescan_Index is
     (
      CLAP_Audio_Ports_Rescan_Names,
      --  The ports name did change, the host can scan them right away.

      CLAP_Audio_Ports_Rescan_Flags,
      --  [!active] The flags did change

      CLAP_Audio_Ports_Rescan_Channel_Count,
      --  [!active] The channel_count did change

      CLAP_Audio_Ports_Rescan_Port_Type,
      --  [!active] The port type did change

      CLAP_Audio_Ports_Rescan_In_Place_Pair,
      --  [!active] The in-place pair did change, this requires.

      CLAP_Audio_Ports_Rescan_List
      --  [!active] The list of ports have changed: entries have been
      --  removed/added.
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Audio_Port_Rescan_Flags is array (Audio_Port_Rescan_Index) of Bool
     with Pack, Size => 32;
   pragma Warnings (On);

   CLAP_Audio_Ports_Rescan_All : constant CLAP_Audio_Port_Rescan_Flags :=
                                   (others => True);

   type Is_Rescan_Flag_Supported_Funcion is access
     function (Host : Hosts.CLAP_Host_Access;
               Flag : CLAP_Audio_Port_Rescan_Flags)
               return Bool
     with Convention => C;
   --  Checks if the host allows a plugin to change a given aspect of the audio
   --  ports definition.
   --  [main-thread]

   type Rescan_Function is access
     procedure (Host : Hosts.CLAP_Host_Access;
                Flag : CLAP_Audio_Port_Rescan_Flags)
     with Convention => C;
   --  Rescan the full list of audio ports according to the flags.
   --  It is illegal to ask the host to rescan with a flag that is not
   --  supported.
   --  Certain flags require the plugin to be de-activated.
   --  [main-thread]

   type CLAP_Host_Audio_Ports is
      record
         Is_Rescan_Flag_Supported : Is_Rescan_Flag_Supported_Funcion := null;
         Rescan                   : Rescan_Function                  := null;
      end record
     with Convention => C;

   type CLAP_Host_Audio_Ports_Access is access all CLAP_Host_Audio_Ports
     with Convention => C;

end CfA.Extensions.Audio_Ports;
