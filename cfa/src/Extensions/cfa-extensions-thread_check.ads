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
--  Thread-check
--
--  CLAP defines two symbolic threads:
--
--  main-thread:
--     This is the thread in which most of the interaction between the plugin and host happens.
--     This will be the same OS thread throughout the lifetime of the plug-in.
--     On macOS and Windows, this must be the thread on which gui and timer events are received
--     (i.e., the main thread of the program).
--     It isn't a realtime thread, yet this thread needs to respond fast enough to allow responsive
--     user interaction, so it is strongly recommended plugins run long,and expensive or blocking
--     tasks such as preset indexing or asset loading in dedicated background threads started by the
--     plugin.
--
--  audio-thread:
--     This thread can be used for realtime audio processing. Its execution should be as
--     deterministic as possible to meet the audio interface's deadline (can be <1ms). There are a
--     known set of operations that should be avoided: malloc() and free(), contended locks and
--     mutexes, I/O, waiting, and so forth.
--
--     The audio-thread is symbolic, there isn't one OS thread that remains the
--     audio-thread for the plugin lifetime. A host is may opt to have a
--     thread pool and the plugin.process() call may be scheduled on different OS threads over time.
--     However, the host must guarantee that single plugin instance will not be two audio-threads
--     at the same time.
--
--     Functions marked with [audio-thread] **ARE NOT CONCURRENT**. The host may mark any OS thread,
--     including the main-thread as the audio-thread, as long as it can guarantee that only one OS
--     thread is the audio-thread at a time in a plugin instance. The audio-thread can be seen as a
--     concurrency guard for all functions marked with [audio-thread].
--
--     The real-time constraint on the [audio-thread] interacts closely with the render extension.
--     If a plugin doesn't implement render, then that plugin must have all [audio-thread] functions
--     meet the real time standard. If the plugin does implement render, and returns true when
--     render mode is set to real-time or if the plugin advertises a hard realtime requirement, it
--     must implement realtime constraints. Hosts also provide functions marked [audio-thread].
--     These can be safely called by a plugin in the audio thread. Therefore hosts must either (1)
--     implement those functions meeting the real-time constraints or (2) not process plugins which
--     advertise a hard realtime constraint or don't implement the render extension. Hosts which
--     provide [audio-thread] functions outside these conditions may experience inconsistent or
--     inaccurate rendering.
--
--   Clap also tags some functions as [thread-safe]. Functions tagged as [thread-safe] can be called
--   from any thread unless explicitly counter-indicated (for instance [thread-safe, !audio-thread])
--   and may be called concurrently. Since a [thread-safe] function may be called from the
--   [audio-thread] unless explicitly counter-indicated, it must also meet the realtime constraints
--   as describes above.
with CfA.Hosts;

package CfA.Extensions.Thread_Check is

   CLAP_Ext_Thread_Check : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.thread-check");

   --  This interface is useful to do runtime checks and make
   --  sure that the functions are called on the correct threads.
   --  It is highly recommended to implement this extension

   type Is_Main_Thread_Function is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Returns true if "this" thread is the main thread.
   --  [thread-safe]

   type Is_Audio_Thread_Funcion is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Returns true if "this" thread is one of the audio threads.
   --  [thread-safe]

   type CLAP_Host_Thread_Check is
      record
         Is_Main_Thread  : Is_Main_Thread_Function := null;
         Is_Audio_Thread : Is_Audio_Thread_Funcion := null;
      end record
     with Convention => C;

   type CLAP_Host_Thread_Check_Access is access all CLAP_Host_Thread_Check
     with Convention => C;

end CfA.Extensions.Thread_Check;
