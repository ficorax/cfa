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
--  This extension lets the plugin use the host's thread pool.
--
--  The plugin must provide CLAP_Plugin_Thread_Pool, and the host may provide
--  CLAP_Host_Thread_Pool. If it doesn't, the plugin should process its data by
--  its own means. In the worst case, a single threaded for-loop.
--
--  Simple example with N voices to process
--
--  procedure Myplug_Thread_Pool_Exec
--           (Plugin      : CLAP_Plugin;
--            Voice_Index : Uint_32)
--  is
--  begin
--     Compute_Voice (Plugin, Voice_Index);
--  end Myplug_Thread_Pool_Exec
--
--  procedure Myplug_Process
--           (Plugin  : CLAP_Plugin;
--            Process : CLAP_Process)
--  is
--     ...
--     Did_Compute_Voices : Bool := False;
--  begin
--     if Host_Thread_Pool /= null and Host_Thread_Pool.Exec then
--        Did_Compute_Voices := Host_Thread_Pool.Request_Exec (Host, Plugin, N);
--     end if;
--
--     if not Did_Compute_Voices then
--        for I in 0 N - 1 loop
--           Myplug_Thread_Pool_Exec (Plugin, I);
--     ...
--     end loop;
--     ...
--  end Myplug_Process;
--
--  Be aware that using a thread pool may break hard real-time rules due to
--  the thread synchronization involved.
--
--  If the host knows that it is running under hard real-time pressure it may
--  decide to not provide this interface.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Thread_Pool is

   CLAP_Ext_Thread_Pool : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.thread-pool");

   type Exec_Function is access
     procedure (Plugin     : Plugins.CLAP_Plugin_Access;
                Task_Index : UInt32_t)
     with Convention => C;
   --  Called by the thread pool

   type CLAP_Plugin_Thread_Pool is
      record
         Exec : Exec_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Thread_Pool_Access is access CLAP_Plugin_Thread_Pool
     with Convention => C;

   type Request_Exec_Function is access
     function (Host      : Hosts.CLAP_Host_Access;
               Num_Tasks : UInt32_t)
               return Bool
     with Convention => C;
   --  Schedule num_tasks jobs in the host thread pool.
   --  It can't be called concurrently or from the thread pool.
   --  Will block until all the tasks are processed.
   --  This must be used exclusively for realtime processing within the process
   --  call.
   --  Returns True if the host did execute all the tasks, False if it rejected
   --  the request.
   --  The host should check that the plugin is within the process call, and if
   --  not, reject the exec
   --  request.
   --  [audio-thread]

   type CLAP_Host_Thread_Pool is
      record
         Request_Exec : Request_Exec_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Thread_Pool_Access is access all CLAP_Host_Thread_Pool
     with Convention => C;

end CfA.Extensions.Thread_Pool;
