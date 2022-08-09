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
--  This extension indicates the number of voices the synthesizer has.
--  It is useful for the host when performing polyphonic modulations,
--  because the host needs its own voice management and should try to follow
--  what the plugin is doing:
--  - make the host's voice pool coherent with what the plugin has
--  - turn the host's voice management to mono when the plugin is mono

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Voice_Infos is

   CLAP_Ext_Voice_Info : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.voice-info.draft/0");

   type CLAP_Voice_Info_Flags_Index is
     (
      Supports_Overlapping_Notes
      --  Allows the host to send overlapping NOTE_ON events.
      --  The plugin will then rely upon the note_id to distinguish between
      --  them.
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Voice_Info_Flags is
     array (CLAP_Voice_Info_Flags_Index) of Bool
     with Pack, Size => 64;
   pragma Warnings (On);

   type CLAP_Voice_Info is
      record
      --  Voice_Count is the current number of voices that the patch can use
      --  Voice_Capacity is the number of voices allocated voices
      --  Voice_Count should not be confused with the number of active voices.
      --
      --  1 <= Voice_Count <= Voice_Capacity
      --
      --  For example, a synth can have a capacity of 8 voices, but be
      --  configured to only use 4 voices: {count: 4, capacity: 8}.
      --
      --  If the Voice_Count is 1, then the synth is working in mono and
      --  the host can decide to only use global modulation mapping.
         Voice_Count    : UInt32_t := 0;
         Voice_Capacity : UInt32_t := 0;
         Flags          : CLAP_Voice_Info_Flags := (others => False);
      end record
     with Convention => C;

   type CLAP_Voice_Info_Access is access CLAP_Voice_Info
     with Convention => C;

   type Get_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Infor  : CLAP_Voice_Info_Access)
               return Bool
     with Convention => C;
   --  gets the voice info, returns true on success
   --  [main-thread && active]

   type CLAP_Plugin_Voice_Info is
      record
         Get : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Voice_Info_Access is access CLAP_Plugin_Voice_Info
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  informs the host that the voice info has changed
   --  [main-thread]

   type CLAP_Host_Voice_Info is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Voice_Info_Access is access all CLAP_Host_Voice_Info
     with Convention => C;

end CfA.Extensions.Draft.Voice_Infos;
