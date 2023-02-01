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

----------------------------------------------------------------------------------------------------
--  Parameters
--
--  Main idea:
--
--  The host sees the plugin as an atomic entity; and acts as a controller on
--  top of its parameters. The plugin is responsible for keeping its audio
--  processor and its GUI in sync.
--
--  The host can at any time read parameters' value on the [main-thread] using
--  CLAP_Plugin_Params.Value.
--
--  There are two options to communicate parameter value changes, and they are
--  not concurrent.
--  - send automation points during CLAP_Plugin.Process
--  - send automation points during CLAP_Plugin_Params.Flush, for parameter
--    changes without processing audio
--
--  When the plugin changes a parameter value, it must inform the host.
--  It will send CLAP_Event_Param_Value event during Process or Flush.
--  If the user is adjusting the value, don't forget to mark the begining and
--  end of the gesture by sending Param_Gesture_Begin and Param_Gesture_End
--  events.
--
--  @note MIDI CCs are tricky because you may not know when the parameter
--  adjustment ends. Also if the host records incoming MIDI CC and parameter
--  change automation at the same time, there will be a conflict at playback:
--  MIDI CC vs Automation.
--  The parameter automation will always target the same parameter because
--  the Param_ID is stable. The MIDI CC may have a different mapping in
--  the future and may result in a different playback.
--
--  When a MIDI CC changes a parameter's value, set the flag Dont_Record in
--  CLAP_Event_Param.Header.Flags. That way the host may record the MIDI CC
--  automation, but not the parameter change and there won't be conflict at
--  playback.
--
--  Scenarios:
--
--  I. Loading a preset
--  - load the preset in a temporary state
--  - call @ref CLAP_Host_Params.Changed if anything changed
--  - call @ref CLAP_Host_Latency.Changed if latency changed
--  - invalidate any other info that may be cached by the host
--  - if the plugin is activated and the preset will introduce breaking changes
--    (latency, audio ports, new parameters, ...) be sure to wait for the host
--    to deactivate the plugin to apply those changes.
--    If there are no breaking changes, the plugin can apply them them right
--    away.
--    The plugin is responsible for updating both its audio processor and its
--    gui.
--
--  II. Turning a knob on the DAW interface
--  - the host will send an automation event to the plugin via a Process or
--    Flush
--
--  III. Turning a knob on the Plugin interface
--  - the plugin is responsible for sending the parameter value to its audio
--    processor
--  - call CLAP_Host_Params.Request_Flush or CLAP_Host.Request_Process.
--  - when the host calls either CLAP_Plugin.Process or
--    CLAP_Plugin_Params.Flush, send an automation event and don't forget to set
--    begin_adjust, end_adjust and should_record flags
--
--  IV. Turning a knob via automation
--  - host sends an automation point during CLAP_Plugin.Process or
--    CLAP_Plugin_Params.Flush.
--  - the plugin is responsible for updating its GUI
--
--  V. Turning a knob via plugin's internal MIDI mapping
--  - the plugin sends a Param_Value output event, set should_record to false
--  - the plugin is responsible for updating its GUI
--
--  VI. Adding or removing parameters
--  - if the plugin is activated call CLAP_Host.Restart
--  - once the plugin isn't active:
--    - apply the new state
--    - if a parameter is gone or is created with an id that may have been used
--      before, call CLAP_Host_Params.Clear (Host, Param_ID, Clear_All)
--    - call CLAP_Host_Params.Rescan (Rescan_All)
--
--  CLAP allows the plugin to change the parameter range, yet the plugin developper
--  should be aware that doing so isn't without risk, especially if you made the
--  promise to never change the sound. If you want to be 100% certain that the
--  sound will not change with all host, then simply never change the range.
--
--  There are two approaches to automations, either you automate the plain value,
--  or you automate the knob position. The first option will be robust to a range
--  increase, while the second won't be.
--
--  If the host goes with the second approach (automating the knob position), it means
--  that the plugin is hosted in a relaxed environment regarding sound changes (they are
--  accepted, and not a concern as long as they are reasonable). Though, stepped parameters
--  should be stored as plain value in the document.
--
--  If the host goes with the first approach, there will still be situation where the
--  sound may innevitably change. For example, if the plugin increase the range, there
--  is an automation playing at the max value and on top of that an LFO is applied.
--  See the following curve:
--                                    .
--                                   . .
--           .....                  .   .
--  before: .     .     and after: .     .
--
--  Advice for the host:
--  - store plain values in the document (automation)
--  - store modulation amount in plain value delta, not in percentage
--  - when you apply a CC mapping, remember the min/max plain values so you can adjust
--
--  Advice for the plugin:
--  - think carefully about your parameter range when designing your DSP
--  - avoid shrinking parameter ranges, they are very likely to change the sound
--  - consider changing the parameter range as a tradeoff: what you improve vs what you break
--  - if you plan to use adapters for other plugin formats, then you need to pay extra
--    attention to the adapter requirements

with CfA.Events;
with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Params is

   use Interfaces.C;

   CLAP_Ext_Params : constant Char_Ptr :=
                       Interfaces.C.Strings.New_String ("clap.params");

   type Param_Info_Flags_Index is
     (
      Is_Stepped,
      --  Is this param stepped? (integer values only)
      --  if so the double value is converted to integer using a cast (equivalent
      --  to trunc).

      Is_Periodic,
      --  Useful for for periodic parameters like a phase

      Is_Hidden,
      --  The parameter should not be shown to the user, because it is currently
      --  not used.
      --  It is not necessary to process automation for this parameter.

      Is_Readonly,
      --  The parameter can't be changed by the host.

      Is_Bypass,
      --  This parameter is used to merge the plugin and host bypass button.
      --  It implies that the parameter is stepped.
      --  min: 0 -> bypass off
      --  max: 1 -> bypass on

      Is_Automatable,
      --  When set:
      --  - automation can be recorded
      --  - automation can be played back
      --
      --  The host can send live user changes for this parameter regardless of
      --  this flag.
      --
      --  If this parameter affects the internal processing structure of
      --  the plugin, ie: max delay, fft size, ... and the plugins needs to
      --  re-allocate its working buffers, then it should call
      --  Host.Request_Restart, and perform the change once the plugin is
      --  re-activated.

      Is_Automatable_Per_Note_ID,
      --  Does this parameter support per note automations?

      Is_Automatable_Per_Key,
      --  Does this parameter support per key automations?

      Is_Automatable_Per_Channel,
      --  Does this parameter support per channel automations?

      Is_Automatable_Per_Port,
      --  Does this parameter support per port automations?

      Is_Modulatable,
      --  Does this parameter support the modulation signal?

      Is_Modulatable_Per_Note_ID,
      --  Does this parameter support per note automations?

      Is_Modulatable_Per_Key,
      --  Does this parameter support per key automations?

      Is_Modulatable_Per_Channel,
      --  Does this parameter support per channel automations?

      Is_Modulatable_Per_Port,
      --  Does this parameter support per port automations?

      Requires_Process
      --  Any change to this parameter will affect the plugin output and
      --  requires to be done via Process if the plugin is active.
      --
      --  A simple example would be a DC Offset, changing it will change
      --  the output signal and must be processed.
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Param_Info_Flags is array (Param_Info_Flags_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   -------------------------------------------------------------------------------------------------
   --  This describes a parameter

   type CLAP_Param_Info is
      record

         ID : CLAP_ID;
         --  stable parameter identifier, it must never change.

         Flags : CLAP_Param_Info_Flags := (others => False);

         Cookie : Void_Ptr := System.Null_Address;
         --  This value is optional and set by the plugin.
         --  Its purpose is to provide a fast access to the
         --  plugin parameter object by caching its pointer.
         --  For instance:
         --
         --  in CLAP_Plugin_Params.Get_Info:
         --     P : Parameter_Access := Find_Parameter (Param_ID);
         --     Param_Info.Cookie := P;
         --
         --  later, in Clap_Plugin.Process:
         --
         --     P : Parameter_Access := Event.Cookie;
         --
         --     if P = null then [[unlikely]]
         --        P := Find_Parameter (Event.Param_ID);
         --     end if;
         --
         --  where Find_Parameter is a function the plugin implements
         --  to map parameter ids to internal objects.
         --
         --  Important:
         --   - The cookie is invalidated by a call to
         --     CLAP_Host_Params.Rescan (CLAP_Param_Rescan_All) or when the plugin is
         --     destroyed.
         --   - The host will either provide the cookie as issued or null
         --     in events addressing parameters.
         --   - The plugin must gracefully handle the case of a cookie
         --     which is null.
         --   - Many plugins will process the parameter events more quickly if the host
         --     can provide the cookie in a faster time than a hashmap lookup per param
         --     per event.

         Name   : char_array (0 .. CLAP_Name_Size - 1);
         --  the display name

         Module : char_array (0 .. CLAP_Path_Size - 1);
         --  the module path containing the param, eg:"oscillators/wt1"
         --  '/' will be used as a separator to show a tree like structure.

         Min_Value : CLAP_Double := 0.0;     --  minimum plain value
         Max_Value : CLAP_Double := 0.0;     --  maximum plain value
         Default_Value : CLAP_Double := 0.0; --  default plain value
      end record
     with Convention => C;

   type CLAP_Param_Info_Access is access CLAP_Param_Info
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  Returns the number of parameters.
   --  [main-thread]

   type Get_Info_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               Param_Index : UInt32_t;
               Param_Info  : CLAP_Param_Info_Access)
               return Bool
     with Convention => C;
   --  Copies the parameter's info to param_info. Returns True on success.
   --  [main-thread]

   type Get_Value_Function is access
     function (Plugin    :     Plugins.CLAP_Plugin_Access;
               Param_ID  :     CLAP_ID;
               Out_Value : out CLAP_Double)
               return Bool
     with Convention => C;
   --  Writes the parameter's current value to out_value. Returns True on success.
   --  [main-thread]

   type Value_To_Text_Function is access
     function (Plugin              : Plugins.CLAP_Plugin_Access;
               Param_ID            : CLAP_ID;
               Value               : CLAP_Double;
               Out_Buffer          : Char_Ptr;
               Out_Buffer_Capacity : UInt32_t)
               return Bool
     with Convention => C;
   --  Fills out_buffer with a null-terminated UTF-8 string that represents the parameter at the
   --  given 'Value' argument. eg: "2.3 kHz". Returns True on success. The host should always use
   --  this to format parameter values before displaying it to the user. [main-thread]

   type Text_To_Value_Function is access
     function (Plugin           :     Plugins.CLAP_Plugin_Access;
               Param_ID         :     CLAP_ID;
               Param_Value_Text :     Char_Ptr;
               Out_Value        : out CLAP_Double)
               return Bool
     with Convention => C;
   --  Converts the null-terminated UTF-8 param_value_text into a double and writes it to out_value.
   --  Returns true on success. The host can use this to convert user input into a parameter value.
   --  [main-thread]

   type Flush_Function is access
     procedure (Plugin     : Plugins.CLAP_Plugin_Access;
                In_Events  : Events.CLAP_Input_Events_Access;
                Out_Events : Events.CLAP_Output_Events_Access)
     with Convention => C;
   --  Flushes a set of parameter changes.
   --  This method must not be called concurrently to CLAP_Plugin.Process.
   --
   --  Note: if the plugin is processing, then the Process call will already achieve the
   --  parameter update (bi-directional), so a call to flush isn't required, also be aware
   --  that the plugin may use the sample offset in Process, while this information would be
   --  lost within Flush.
   --
   --  [active ? audio-thread : main-thread]

   type CLAP_Plugin_Params is
      record
         Count         : Count_Function := null;
         Get_Info      : Get_Info_Function := null;
         Get_Value     : Get_Value_Function := null;
         Value_To_Text : Value_To_Text_Function := null;
         Text_To_Value : Text_To_Value_Function := null;
         Flush         : Flush_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Params_Access is access CLAP_Plugin_Params
     with Convention => C;

   type Param_Rescan_Flags_Index is
     (
      Values,
      --  The parameter values did change, eg. after loading a preset.
      --  The host will scan all the parameters value.
      --  The host will not record those changes as automation points.
      --  New values takes effect immediately.

      Text,
      --  The value to text conversion changed, and the text needs to be
      --  rendered again.

      Info,
      --  The parameter info did change, use this flag for:
      --  - name change
      --  - module change
      --  - Is_Periodic (Flag)
      --  - Is_Hidden (Flag)
      --  New info takes effect immediately.

      Rescan_All
      --  Invalidates everything the host knows about parameters.
      --  It can only be used while the plugin is deactivated.
      --  If the plugin is activated use CLAP_Host.Restart and delay any change
      --  until the host calls
      --  CLAP_Plugin.Deactivate.
      --
      --  You must use this flag if:
      --  - some parameters were added or removed.
      --  - some parameters had critical changes:
      --    - Is_Per_Note (Flag)
      --    - Is_Per_Key (Flag)
      --    - Is_Per_Channel (Flag)
      --    - Is_Per_Port (Flag)
      --    - Is_Readonly (Flag)
      --    - Is_Bypass (Flag)
      --    - Is_Stepped (Flag)
      --    - Is_Modulatable (Flag)
      --    - Min_Value
      --    - Max_Value
      --    - Cookie
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Param_Rescan_Flags is array (Param_Rescan_Flags_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type Param_Clear_Flags_Index is
     (
      Clear_All,
      --  Clears all possible references to a parameter

      Automations,
      --  Clears all automations to a parameter

      Modulations
      --  Clears all modulations to a parameter
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Param_Clear_Flags is array (Param_Clear_Flags_Index) of Bool
     with Convention => C, Pack, Size => 32;
   pragma Warnings (On);

   type Rescan_Function is access
     procedure (Host : Hosts.CLAP_Host_Access; Flags : CLAP_Param_Rescan_Flags)
     with Convention => C;
   --  Rescan the full list of parameters according to the flags.
   --  [main-thread]

   type Clear_Function is access
     procedure (Host     : Hosts.CLAP_Host_Access;
                Param_ID : CLAP_ID;
                Flags    : CLAP_Param_Clear_Flags)
     with Convention => C;
   --  Clears references to a parameter.
   --  [main-thread]

   type Request_Flush_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Request a parameter flush.
   --
   --  The host will then schedule a call to either:
   --  - CLAP_Plugin.Process
   --  - CLAP_Plugin_Params.Flush
   --
   --  This function is always safe to use and must not be called on
   --  the [audio-thread].
   --  [thread-safe,!audio-thread]

   type CLAP_Host_Params is
      record
         Rescan        : Rescan_Function := null;
         Clear         : Clear_Function := null;
         Request_Flush : Request_Flush_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Params_Access is access all CLAP_Host_Params
     with Convention => C;

end CfA.Extensions.Params;
