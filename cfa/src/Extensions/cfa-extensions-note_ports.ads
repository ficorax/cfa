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
--  Note Ports
--
--  This extension provides a way for the plugin to describe its current note
--  ports.
--  If the plugin does not implement this extension, it won't have note input or
--  output.
--  The plugin is only allowed to change its note ports configuration while it
--  is deactivated.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Note_Ports is

   use type Interfaces.C.size_t;

   CLAP_Ext_Note_Ports : constant Char_Ptr :=
                           Interfaces.C.Strings.New_String ("clap.note-ports");

   type Note_Dialect_Index is
     (
      --  Uses clap_event_note and clap_event_note_expression.
      CLAP,

      MIDI,
      --  Uses clap_event_midi, no polyphonic expression

      MIDI_MPE,
      --  Uses clap_event_midi, with polyphonic expression (MPE)

      MIDI2
      --  Uses clap_event_midi2
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Note_Dialect is array (Note_Dialect_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type CLAP_Note_Port_Info is
      record
         ID                 : CLAP_ID;
         --  id identifies a port and must be stable.
         --  id may overlap between input and output ports.

         Supported_Dialects : CLAP_Note_Dialect := (others => False);
         --  bitfield, see clap_note_dialect

         Preferred_Dialect  : CLAP_Note_Dialect := (CLAP   => True,
                                                    others => False);
         --  one value of clap_note_dialect

         Name               : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         --  displayable name, i18n?
      end record
     with Convention => C;

   type CLAP_Note_Port_Info_Access is access CLAP_Note_Port_Info
     with Convention => C;

   type Count_Function is access
     function (Plugin   : Plugins.CLAP_Plugin_Access;
               Is_Input : Bool)
               return UInt32_t
     with Convention => C;
   --  number of ports, for either input or output
   --  [main-thread]

   type Get_Function is access
     function (Plugin   : Plugins.CLAP_Plugin_Access;
               Index    : UInt32_t;
               Is_input : Bool;
               Info     : CLAP_Note_Port_Info_Access)
               return Bool
     with Convention => C;
   --  get info about about a note port.
   --  [main-thread]

--  The note ports scan has to be done while the plugin is deactivated.
   type CLAP_Plugin_Note_Ports is
      record
         Count : Count_Function := null;
         Get   : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Note_Ports_Access is access CLAP_Plugin_Note_Ports
     with Convention => C;

   type Note_Ports_Rescan_Index is
     (
      Rescan_All,
      --  The ports have changed, the host shall perform a full scan of
      --  the ports.
      --  This flag can only be used if the plugin is not active.
      --  If the plugin active, call Host.Request_Restart and then call Rescan
      --  when the host calls Deactivate

      Names
      --  The ports name did change, the host can scan them right away.
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Note_Ports_Rescan_Flags is
     array (Note_Ports_Rescan_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type Supported_Dialects_Function is access
     function (Host : Hosts.CLAP_Host_Access) return CLAP_Note_Dialect
     with Convention => C;
   --  Query which dialects the host supports
   --  [main-thread]

   type Rescan_Function is access
     procedure (Host  : Hosts.CLAP_Host_Access;
                Flags : CLAP_Note_Ports_Rescan_Flags)
     with Convention => C;
   --  Rescan the full list of note ports according to the flags.
   --  [main-thread]

   type CLAP_Host_Note_Ports is
      record
         Supported_Dialects : Supported_Dialects_Function := null;
         Rescan             : Rescan_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Note_Ports_Access is access all CLAP_Host_Note_Ports
     with Convention => C;

end CfA.Extensions.Note_Ports;
