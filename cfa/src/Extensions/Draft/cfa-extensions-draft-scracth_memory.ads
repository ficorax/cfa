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
--  This extension lets the plugin request "scratch" memory from the host.
--
--  The scratch memory is thread-local, and can be accessed during
--  `CLAP_Plugin.Process` and `CLAP_Plugin_Thread_Pool.Exec`;
--  its content is not persistent between callbacks.
--
--  The motivation for this extension is to allow the plugin host
--  to "share" a single scratch buffer across multiple plugin
--  instances.
--
--  For example, imagine the host needs to process N plugins
--  in sequence, and each plugin requires 10K of scratch memory.
--  If each plugin pre-allocates its own scratch memory, then N * 10K
--  of memory is being allocated in total. However, if each plugin
--  requests 10K of scratch memory from the host, then the host can
--  allocate a single 10K scratch buffer, and make it available to all
--  plugins.
--
--  This optimization may allow for reduced memory usage and improved
--  CPU cache usage.

with CfA.Hosts;

package CfA.Extensions.Draft.Scracth_Memory is

   CLAP_Ext_Scratch_Memory : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.scratch-memory/1");

   type Reserve_Function is access
     function (Plugin               : Hosts.CLAP_Host_Access;
               Scratch_Size_Bytes   : UInt32_t;
               Max_Concurrency_Hint : UInt32_t)
               return Bool
   with Convention => C;
   --  Asks the host to reserve scratch memory.
   --
   --  The plugin may call this method multiple times (for
   --  example, gradually decreasing the amount of scratch
   --  being asked for until the host returns True), however,
   --  the plugin should avoid calling this method un-neccesarily
   --  since the host implementation may be relatively expensive.
   --  If the plugin calls `Reserve` multiple times, then the
   --  last call invalidates all previous calls.
   --
   --  De-activating the plugin releases the scratch memory.
   --
   --  `Max_Concurrency_Hint` is an optional hint which indicates
   --  the maximum number of threads concurrently accessing the scratch memory.
   --  Set to 0 if unspecified.
   --
   --  Returns True on success.
   --
   --  [main-thread & being-activated]

   type Access_Scratch_Function is access
     function (Host : Hosts.CLAP_Host_Access)
               return Void_Ptr
     with Convention => C;
   --  Returns a pointer to the "thread-local" scratch memory.
   --
   --  If the scratch memory wasn't successfully reserved, returns null.
   --
   --  If the plugin crosses `Max_Concurrency_Hint`, then the return value
   --  is either null or a valid scratch memory pointer.
   --
   --  This method may only be called by the plugin from the audio thread,
   --  (i.e. during the Process or Thread_Pool.Exec callback), and
   --  the provided memory is only valid until the plugin returns from
   --  that callback. The plugin must not hold any references to data
   --  that lives in the scratch memory after returning from the callback,
   --  as that data will likely be over-written by another plugin using
   --  the same scratch memory.
   --
   --  The provided memory is not initialized, and may have been used
   --  by other plugin instances, so the plugin must correctly initialize
   --  the memory when using it.
   --
   --  The provided memory is owned by the host, so the plugin must not
   --  free the memory.
   --
   --  If the plugin wants to share the same scratch memory pointer with
   --  many threads, it must access the the scratch at the beginning of the
   --  `Process` callback, cache the returned pointer before calling
   --  `CLAP_Host_Thread_Pool.Request_Exec` and clear the cached pointer
   --  before returning from `Process`.
   --
   --  [audio-thread]

   type CLAP_Host_Scratch_Memory is
      record
         Reserve        : Reserve_Function;
         Access_Scratch : Access_Scratch_Function;
      end record
     with Convention => C;

   type CLAP_Host_Scratch_Memory_Access is access all CLAP_Host_Scratch_Memory
     with Convention => C;

end CfA.Extensions.Draft.Scracth_Memory;
