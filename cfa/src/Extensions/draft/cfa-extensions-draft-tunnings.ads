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

with CfA.Events;
with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Tunnings is

   use type Interfaces.C.size_t;

   Clap_Ext_Tuning : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.tuning.draft/2");

   --  Use CLAP_Host_Event_Registry.Query (Host, CLAP_Ext_Tuning, Space_ID) to
   --  know the event space.
   --
   --  This event defines the tuning to be used on the given port/channel.

   type CLAP_Event_Tuning is
      record
         Header : CfA.Events.CLAP_Event_Header;

         Port_Index : UInt16_t := 0;    --  -1 global
         Channel    : UInt16_t := 0;    --  0..15, -1 global
         Tunning_ID : CLAP_ID;
      end record
     with Convention => C;

   type CLAP_Event_Tuning_Access is access CLAP_Event_Tuning
     with Convention => C;

   type CLAP_Tuning_Info is
      record
         Tuning_ID  : CLAP_ID;
         Name       : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Is_Dynamic : Bool := False;
         --  true if the values may vary with time
      end record
     with Convention => C;

   type CLAP_Tuning_Info_Access is access CLAP_Tuning_Info
     with Convention => C;

   type Changed_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access)
     with Convention => C;
   --  Called when a tuning is added or removed from the pool.
   --  [main-thread]

   type CLAP_Plugin_Tuning is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Tuning_Access is access CLAP_Plugin_Tuning
     with Convention => C;

   --  This extension provides a dynamic tuning table to the plugin.

   type Get_Relative_Function is access
     function (Host          : Hosts.CLAP_Host_Access;
               Tuning_ID     : CLAP_ID;
               Channel       : Int32_t;
               Key           : Int32_t;
               Sample_Offset : UInt32_t)
               return Interfaces.C.double
     with Convention => C;
      --  Gets the relative tuning in semitones against equal temperament with
      --  A4 = 440Hz.
      --  The plugin may query the tuning at a rate that makes sense for *low*
      --  frequency modulations.
      --
      --  If the tuning_id is not found or equals to CLAP_Invalid_ID,
      --  then the function shall gracefuly return a sensible value.
      --
      --  Sample_Offset is the sample offset from the begining of the current
      --  process block.
      --
      --  Should_Play (...) should be checked before calling this function.
      --
      --  [audio-thread & in-process]

   type Should_Play_Function is access
     function (Host          : Hosts.CLAP_Host_Access;
               Tuning_ID     : CLAP_ID;
               Channel       : Int32_t;
               Key           : Int32_t)
               return Bool
     with Convention => C;
   --  Returns true if the note should be played.
   --  [audio-thread & in-process]

   type Get_Tuning_Count_Function is access
     function (Host : Hosts.CLAP_Host_Access) return UInt32_t
     with Convention => C;
   --  Returns the number of tunings in the pool.
   --  [main-thread]

   type Get_Info_Function is access
     function (Host         : Hosts.CLAP_Host_Access;
               Tuning_Index : UInt32_t;
               Info         : CLAP_Tuning_Info_Access)
               return Bool
     with Convention => C;
   --  Gets info about a tuning
   --  [main-thread]

   type CLAP_Host_Tuning is
      record
         Get_Relative     : Get_Relative_Function := null;
         Should_Play      : Should_Play_Function := null;
         Get_Tuning_Count : Get_Tuning_Count_Function := null;
         Get_Info         : Get_Info_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Tuning_Access is access CLAP_Host_Tuning
     with Convention => C;

end CfA.Extensions.Draft.Tunnings;
