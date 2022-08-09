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

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.MIDI_Mappings is

   CLAP_Ext_MIDI_Mappings : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.midi-mappings.draft/0");

   type CLAP_MIDI_MApping_Index is
     (
      CLAP_MIDI_Mapping_CC7,
      CLAP_MIDI_Mapping_CC14,
      CLAP_MIDI_Mapping_RPN,
      CLAP_MIDI_Mapping_NRPN
     );

   type CLAP_MIDI_Mapping_Type is new CLAP_MIDI_MApping_Index
     with Convention => C, Size => 32;

   type CLAP_MIDI_Mapping is
      record
         Channel  : UInt32_t := 0;
         Number   : CLAP_MIDI_Mapping_Type;
         Param_ID : CLAP_ID;
      end record
     with Convention => C;

   type CLAP_MIDI_Mapping_Access is access CLAP_MIDI_Mapping
     with Convention => C;

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  [main-thread]

   type Get_Function is access
     function (Plugin  : Plugins.CLAP_Plugin_Access;
               Mapping : out CLAP_MIDI_Mapping)
               return Bool
     with Convention => C;
   --  [main-thread]

   type CLAP_Plugin_MIDI_Mappings is
      record
         Count : Count_Function := null;
         Get   : Get_Function   := null;
      end record
     with Convention => C;
   type CLAP_Plugin_MIDI_Mappings_Access is access CLAP_Plugin_MIDI_Mappings
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  [main-thread]

   type CLAP_Host_MIDI_Mappings is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_MIDI_Mappings_Access is access CLAP_Host_MIDI_Mappings
     with Convention => C;

end CfA.Extensions.Draft.MIDI_Mappings;
