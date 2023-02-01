--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2023 Marek Kuziel
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

with CfA.Fixed_Point;

package CfA.Events is

   CLAP_Core_Event_Space_ID : constant UInt16_t := 0;
   --  The clap core event space

   type CLAP_Event_Flags_Index is
     (
      Is_Live,
      --  Indicate a live user event, for example a user turning a physical knob
      --  or playing a physical key.

      Dont_Record
      --  Indicate that the event should not be recorded.
      --  For example this is useful when a parameter changes because of a MIDI CC,
      --  because if the host records both the MIDI CC automation and the parameter
      --  automation there will be a conflict.
     );

   pragma Warnings (Off);
   type CLAP_Event_Flags is array (CLAP_Event_Flags_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   --  Some of the following events overlap, a note on can be expressed with:
   --  - Note_On
   --  - MIDI
   --  - MIDI2
   --
   --  The preferred way of sending a note event is to use Note_*.
   --
   --  The same event must not be sent twice: it is forbidden to send a the same note on
   --  encoded with both Note_On and MIDI.
   --
   --  The plugins are encouraged to be able to handle note events encoded as raw midi or midi2,
   --  or implement CLAP_Plugin_Event_Filter and reject raw midi and midi2 events.

   type CLAP_Events is new UInt16_t;

   --  Note_On and Note_Off represent a key pressed and key released event, respectively.
   --  A Note_On with a velocity of 0 is valid and should not be interpreted as a Note_Off.
   --
   --  Note_Choke is meant to choke the voice(s), like in a drum machine when a closed hihat
   --  chokes an open hihat. This event can be sent by the host to the plugin. Here are two use
   --   cases:
   --  - a plugin is inside a drum pad in Bitwig Studio's drum machine, and this pad is choked by
   --    another one
   --  - the user double clicks the DAW's stop button in the transport which then stops the sound
   --    on every tracks
   --
   --  Note_End is sent by the plugin to the host. The port, channel, key and note_id are those
   --  given by the host in the Note_On event. In other words, this event is matched against the
   --  plugin's note input port.
   --  Note_End is useful to help the host to match the plugin's voice life time.
   --
   --  When using polyphonic modulations, the host has to allocate and release voices for its
   --  polyphonic modulator. Yet only the plugin effectively knows when the host should terminate
   --  a voice. Note_End solves that issue in a non-intrusive and cooperative way.
   --
   --  CLAP assumes that the host will allocate a unique voice on Note_On event for a given port,
   --  channel and key. This voice will run until the plugin will instruct the host to terminate
   --  it by sending a Note_End event.
   --
   --  Consider the following sequence:
   --  - Process
   --     Host->Plugin NoteOn(port:0, channel:0, key:16, time:t0)
   --     Host->Plugin NoteOn(port:0, channel:0, key:64, time:t0)
   --     Host->Plugin NoteOff(port:0, channel:0, key:16, t1)
   --     Host->Plugin NoteOff(port:0, channel:0, key:64, t1)
   --     # on t2, both notes did terminate
   --     Host->Plugin NoteOn(port:0, channel:0, key:64, t3)
   --     # Here the plugin finished processing all the frames and will tell the host
   --     # to terminate the voice on key 16 but not 64, because a note has been started at t3
   --     Plugin->Host NoteEnd(port:0, channel:0, key:16, time:ignored)
   --
   --  These four events use clap_event_note.

   CLAP_Events_Note_On    : constant CLAP_Events := 0;
   CLAP_Events_Note_Off   : constant CLAP_Events := 1;
   CLAP_Events_Note_Choke : constant CLAP_Events := 2;
   CLAP_Events_Note_End   : constant CLAP_Events := 3;

   --  Represents a note expression.
   --  Uses CLAP_Event_Note_Expression.
   CLAP_Events_Note_Expression : constant CLAP_Events := 4;

   --  Param_Value sets the parameter's value; uses CLAP_Event_Param_Value.
   --  Param_Mod sets the parameter's modulation amount; uses CLAP_Event_Param_Mod.
   --
   --  The value heard is: param_value + param_mod.
   --
   --  In case of a concurrent global value/modulation versus a polyphonic one,
   --  the voice should only use the polyphonic one and the polyphonic modulation
   --  amount will already include the monophonic signal.
   CLAP_Events_Param_Value : constant CLAP_Events := 5;
   CLAP_Events_Param_Mod   : constant CLAP_Events := 6;

   --  Indicates that the user started or finished adjusting a knob.
   --  This is not mandatory to wrap parameter changes with gesture events, but this improves
   --  the user experience a lot when recording automation or overriding automation playback.
   --  Uses CLAP_Event_Param_Gesture.
   CLAP_Events_Param_Gesture_Begin : constant CLAP_Events := 7;
   CLAP_Events_Param_Gesture_End   : constant CLAP_Events := 8;

   CLAP_Events_Transport : constant CLAP_Events := 9;
   --  update the transport info; CLAP_Event_Transport

   CLAP_Events_MIDI      : constant CLAP_Events := 10;
   --  raw midi event; CLAP_Event_MIDI

   CLAP_Events_MIDI_SysEX : constant CLAP_Events := 11;
   --  raw midi sysex event; CLAP_Event_MIDI_SysEX

   CLAP_Events_MIDI2     : constant CLAP_Events := 12;
   --  raw midi 2 event; CLAP_Event_MIDI2

   --  event header
   --  must be the first attribute of the event
   type CLAP_Event_Header is
      record
         Size       : UInt32_t := 0;
         --  event size including this header, eg: CLAP_Event_Note'Size / 8

         Time       : UInt32_t := 0;
         --  sample offset within the buffer for this event

         Space_ID   : UInt16_t := 0;
         --  event space, see CLAP_Host_Event_Registry

         Event_Type : CLAP_Events;
         --  event type

         Flags      : CLAP_Event_Flags := (others => False);
         --  see CLAP_Event_Flags
      end record
   with Convention => C;

   type CLAP_Event_Header_Access is access CLAP_Event_Header
     with Convention => C;

   --  Note on, off, end and choke events.
   --  In the case of note choke or end events:
   --  - the velocity is ignored.
   --  - key and channel are used to match active notes, a value of -1 matches all.
   type CLAP_Event_Note is
      record
         Header : CLAP_Event_Header := (others => <>);

         Note_ID    : Int32_t := 0;       --  -1 if unspecified, otherwise >=0
         Port_Index : Int16_t := 0;
         Channel    : Int16_t := 0;       --  0..15
         Key        : Int16_t := 0;       --  0..127
         Velocity   : CLAP_Double := 0.0; --  0..1
      end record
   with Convention => C;

   type CLAP_Event_Note_Access is access CLAP_Event_Note
     with Convention => C;

   type CLAP_Note_Expression_Index is
     (
      --  with 0 < x <= 4, plain = 20 * log(x)
      CLAP_Note_Expression_Volume,

      --  pan, 0 left, 0.5 center, 1 right
      CLAP_Note_Expression_Pan,

      --  relative tuning in semitone, from -120 to +120
      CLAP_Note_Expression_Tuning,

      --  0..1
      CLAP_Note_Expression_Vibrato,
      CLAP_Note_Expression_Expression,
      CLAP_Note_Expression_Brightness,
      CLAP_Note_Expression_Pressure
     ) with Convention => C;

   for CLAP_Note_Expression_Index use
     (
      CLAP_Note_Expression_Volume     => 0,
      CLAP_Note_Expression_Pan        => 1,
      CLAP_Note_Expression_Tuning     => 2,
      CLAP_Note_Expression_Vibrato    => 3,
      CLAP_Note_Expression_Expression => 4,
      CLAP_Note_Expression_Brightness => 5,
      CLAP_Note_Expression_Pressure   => 6
     );

   pragma Warnings (Off);
   type CLAP_Note_Expression is array (CLAP_Note_Expression_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type CLAP_Event_Note_Expression is
      record
         Header     : CLAP_Event_Header := (others => <>);

         Expression : CLAP_Note_Expression := (others => False);

         --  target a specific note_id, port, key and channel, -1 for global
         Note_ID    : Int32_t := 0;
         Port_Index : Int16_t := 0;
         Channel    : Int16_t := 0;
         Key        : Int16_t := 0;

         Value      : CLAP_Double := 0.0; -- see expression for the range
      end record
   with Convention => C;

   type CLAP_Event_Note_Expression_Access is access CLAP_Event_Note_Expression
     with Convention => C;

   type CLAP_Event_Param_Value is
      record
         Header : CLAP_Event_Header := (others => <>);

         --  target parameter
         Param_ID : CLAP_ID;  -- Clap_Param_Info.ID
         Cookie   : Void_Ptr := System.Null_Address;
         --  Clap_Param_Info.Cookie

         --  target a specific note_id, port, key and channel, -1 for global
         Note_ID    : Int32_t := 0;
         Port_Index : Int16_t := 0;
         Channel    : Int16_t := 0;
         Key        : Int16_t := 0;

         Value      : CLAP_Double := 0.0; -- see expression for the range
      end record
   with Convention => C;

   type CLAP_Event_Param_Value_Access is access CLAP_Event_Param_Value
     with Convention => C;

   type CLAP_Event_Param_Mod is
      record
         Header : CLAP_Event_Header := (others => <>);

         --  target parameter
         Param_ID : CLAP_ID;  -- Clap_Param_Info.ID
         Cookie   : Void_Ptr := System.Null_Address;
         --  Clap_Param_Info.Cookie

         --  target a specific note_id, port, key and channel, -1 for global
         Note_ID    : Int32_t := 0;
         Port_Index : Int16_t := 0;
         Channel    : Int16_t := 0;
         Key        : Int16_t := 0;

         Amount     : CLAP_Double := 0.0; -- see expression for the range
      end record
   with Convention => C;

   type CLAP_Event_Param_Mod_Access is access CLAP_Event_Param_Mod
     with Convention => C;

   type CLAP_Event_Gesture is
      record
         Header : CLAP_Event_Header := (others => <>);

         --  target parameter
         Param_ID : CLAP_ID;  -- Clap_Param_Info.ID
      end record
   with Convention => C;

   type CLAP_Event_Gesture_Access is access CLAP_Event_Gesture
     with Convention => C;

   type CLAP_Transport_Flags_Index is
     (
      Tempo,
      Beats_Timeline,
      Has_Seconds_Timeline,
      Has_Time_Signature,
      Is_Playing,
      Is_Recording,
      Is_Loop_Active,
      Is_Within_Pre_Roll
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Transport_Flags is array (CLAP_Transport_Flags_Index) of Bool
     with Pack, Size => 32;
   pragma Warnings (On);

   type CLAP_Event_Transport is
      record
         Header             : CLAP_Event_Header := (others => <>);

         Flags              : CLAP_Transport_Flags := (others => False);
         --  see CLAP_Transport_Flags_Index

         Song_Pos_Beats     : Fixed_Point.CLAP_Beattime := 0;    -- position in beats
         Song_Pos_Seconds   : Fixed_Point.CLAP_Sectime  := 0;    -- position in seconds

         Tempo              : CLAP_Double := 0.0;
         --  in bpm
         Tempo_Inc          : CLAP_Double := 0.0;
         --  tempo increment for each samples and until the next time info event

         Loop_Start_Beats   : Fixed_Point.CLAP_Beattime := 0;
         Loop_End_Beats     : Fixed_Point.CLAP_Beattime := 0;
         Loop_Start_Seconds : Fixed_Point.CLAP_Sectime := 0;
         Loop_End_Seconds   : Fixed_Point.CLAP_Sectime := 0;

         Bar_Start          : Fixed_Point.CLAP_Beattime := 0;
         --  start pos of the current bar
         Bar_Number         : Int32_t := 0;
         --  bar at song pos 0 has the number 0

         Tsig_Num           : UInt16_t := 0;
         --  Time Signature Numerator
         Tsig_Denom         : UInt16_t := 0;
         --  Time Signature Denominator
      end record
     with Convention => C;

   type CLAP_Event_Transport_Access is access CLAP_Event_Transport
     with Convention => C;

   type CLAP_Event_MIDI is
      record
         Header : CLAP_Event_Header := (others => <>);

         Port_Index : UInt16_t := 0;
         Data       : UInt8_Array (0 .. 2) := (others => 0);
      end record
   with Convention => C;

   type CLAP_Event_MIDI_Access is access CLAP_Event_MIDI
     with Convention => C;

   type CLAP_Event_MIDI_SysEX is
      record
         Header : CLAP_Event_Header := (others => <>);

         Port_Index : UInt16_t := 0;
         Buffer     : Void_Ptr := System.Null_Address;
         --  MIDI buffer
         Size       : UInt32_t := 0;
      end record
     with Convention => C;

   type CLAP_Event_MIDI_SysEX_Access is access CLAP_Event_MIDI_SysEX
     with Convention => C;

   --  While it is possible to use a series of midi2 event to send a sysex,
   --  prefer clap_event_midi_sysex if possible for efficiency.
   type CLAP_Event_MIDI2 is
      record
         Header : CLAP_Event_Header := (others => <>);

         Port_Index : UInt16_t := 0;
         Data       : UInt32_Array (0 .. 3) := (others => 0);
      end record
     with Convention => C;

   type CLAP_Event_MIDI2_Access is access CLAP_Event_MIDI2
     with Convention => C;

   -------------------------------------------------------------------------------------------------
   --  Input event list, events must be sorted by time.

   type CLAP_Input_Events;
   type CLAP_Input_Events_Access is access CLAP_Input_Events
     with Convention => C;

   type Size_Function is access
     function (List : CLAP_Input_Events_Access) return UInt32_t
     with Convention => C;

   type Get_Function is access
     function (List  : CLAP_Input_Events_Access;
               Index : UInt32_t)
               return CLAP_Event_Header_Access
     with Convention => C;

   type CLAP_Input_Events is
      record
         Ctx : Void_Ptr;
         --  reserved pointer for the list

         Size : Size_Function;

         --  Don't free the returned event, it belongs to the list
         Get : Get_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------
   --  Output event list, events must be sorted by time.

   type CLAP_Output_Events;
   type CLAP_Output_Events_Access is access CLAP_Output_Events
     with Convention => C;

   type Try_Push_Function is access
     function (List  : CLAP_Output_Events_Access;
               Event : CLAP_Event_Header_Access)
               return Bool
     with Convention => C;
   --  Pushes a copy of the event
   --  returns False if the event could not be pushed to the queue (out of memory?)

   type CLAP_Output_Events is
      record
         Ctx : Void_Ptr := System.Null_Address;
         --  reserved pointer for the list

         Try_Push : Try_Push_Function := null;
      end record
     with Convention => C;

end CfA.Events;
