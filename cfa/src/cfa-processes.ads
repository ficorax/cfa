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

package CfA.Processes is

   type CLAP_Process_Status is
     (
      --  Processing failed. The output buffer must be discarded.
      CLAP_Process_Error,

      --  Processing succeeded, keep processing.
      CLAP_Process_Continue,

      --  Processing succeeded, keep processing if the output is not quiet.
      CLAP_Process_Continue_If_Not_Quiet,

      --  Rely upon the plugin's tail to determine if the plugin should continue to process.
      --  see CLAP_Plugin_Tail
      CLAP_Process_Tail,

      --  Processing succeeded, but no more processing is required,
      --  until the next event or variation in audio input.
      CLAP_Process_Sleep
     ) with Convention => C, Size => 32;

   type CLAP_Process is
      record
         --  A steady sample time counter.
         --  This field can be used to calculate the sleep duration between two process calls.
         --  This value may be specific to this plugin instance and have no relation to what
         --  other plugin instances may receive.
         --
         --  Set to -1 if not available, otherwise the value must be greater or equal to 0,
         --  and must be increased by at least `frames_count` for the next call to process.
         Steady_Time  : Int64_t := 0;

         --  Number of frames to process
         Frames_Count : UInt32_t := 0;

         --  time info at sample 0
         --  If null, then this is a free running host, no transport events will be provided
         Transport    : CfA.Events.CLAP_Event_Transport_Access := null;

         --  Audio buffers, they must have the same count as specified
         --  by CLAP_Plugin_Audio_Ports.Get_Count.
         --  The index maps to CLAP_Plugin_Audio_Ports.Get_Info.
         Audio_Inputs  : Void_Ptr := System.Null_Address;
         Audio_Outputs : Void_Ptr := System.Null_Address;

         Audio_Inputs_Count  : UInt32_t := 0;
         Audio_Outputs_Count : UInt32_t := 0;

         --  Input and output events.
         --
         --  Events must be sorted by time.
         --  The input event list can't be modified.
         In_Events  : Events.CLAP_Input_Events_Access := null;
         Out_Events : Events.CLAP_Output_Events_Access := null;
      end record
     with Convention => C;

   type CLAP_Process_Access is access all CLAP_Process with Convention => C;

   function Get_Audio_Input_32 (Process : CLAP_Process_Access;
                                Index   : UInt32_t)
                                return Void_Ptr;

   function Get_Audio_Output_32 (Process : CLAP_Process_Access;
                                 Index   : UInt32_t)
                                 return Void_Ptr;

   function Get_Audio_Input_64 (Process : CLAP_Process_Access;
                                Index   : UInt32_t)
                                return Void_Ptr;

   function Get_Audio_Output_64 (Process : CLAP_Process_Access;
                                 Index   : UInt32_t)
                                 return Void_Ptr;

end CfA.Processes;
