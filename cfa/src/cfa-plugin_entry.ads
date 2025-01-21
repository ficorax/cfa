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

--  This interface is the entry point of the dynamic library.
--
--  CLAP plugins standard search path:
--
--  Linux
--    - ~/.clap
--    - /usr/lib/clap
--
--  Windows
--    - %COMMONPROGRAMFILES%\CLAP
--    - %LOCALAPPDATA%\Programs\Common\CLAP
--
--  MacOS
--    - /Library/Audio/Plug-Ins/CLAP
--    - ~/Library/Audio/Plug-Ins/CLAP
--
--  In addition to the OS-specific default locations above, a CLAP host must query
--  the environment for a CLAP_PATH variable, which is a list of directories formatted
--  in the same manner as the host OS binary search path (PATH on Unix, separated by `:`
--  and Path on Windows, separated by ';', as of this writing).
--
--  Each directory should be recursively searched for files and/or bundles as appropriate in your OS
--  ending with the extension `.clap`.
--
--  init and deinit in most cases are called once, in a matched pair, when the dso is
--  loaded / unloaded. In some rare situations it may be called multiple times in a process, so
--  the functions must be defensive, mutex locking and counting calls if undertaking non trivial
--  non idempotent actions.
--
--  Rationale:
--
--     The intent of the Init and Deinit functions is to provide a "normal" initialization patterh
--     which occurs when the shared object is loaded or unloaded. As such, hosts will call each once
--     and in matched pairs. In CLAP specifications prior to 1.2.0, this single-call was documented
--     as a requirement.
--
--     We realized, though, that this is not a requirement hosts can meet. If hosts load a plugin
--     which itself wraps another CLAP for instance, while also loading that same clap in its memory
--     space, both the host and the wrapper will call init() and deinit() and have no means to
--     communicate the state.
--
--     With CLAP 1.2.0 and beyond we are changing the spec to indicate that a host should make an
--     absolute best effort to call Init and Deinit once, and always in matched pairs (for every
--     Init which returns true, one Deinit should be called).
--
--     This takes the de-facto burden on plugin writers to deal with multiple calls into a hard
--     requirement.
--
--     Most Init / Deinit pairs we have seen are the relatively trivial (return True;) and (). But
--     if your Init function does non-trivial one time work, the plugin author must maintain
--     a counter and must manage a mutex lock. The most obvious implementation will maintain
--     a static counter and a global mutex, increment the counter on each init, decrement it on
--     each deinit, and only undertake the init or deinit action when the counter is zero.
with CfA.Plugin_Factory;
with CfA.Version;

package CfA.Plugin_Entry is

   type Init_Function is access
     function (Plugin_Path : CLAP_Chars_Ptr) return Bool
   with Convention => C;
   --  Initializes the DSO.
   --
   --  This function must be called first, before any-other CLAP-related function or symbol from
   --  this DSO.
   --
   --  It also must only be called once, until a later call to Deinit is made, after which Init
   --  can be called once more to re-initialize the DSO.
   --  This enables hosts to e.g. quickly load and unload a DSO for scanning its plugins, and then
   --  load it again later to actually use the plugins if needed.
   --
   --  As stated above, even though hosts are forbidden to do so directly, multiple calls before any
   --  deinit() call may still happen. Implementations *should* take this into account, and *must*
   --  do so as of CLAP 1.2.0.
   --
   --  It should be as fast as possible, in order to perform a very quick scan of the plugin
   --  descriptors.
   --
   --  It is forbidden to display graphical user interfaces in this call.
   --  It is forbidden to perform any user interaction in this call.
   --
   --  If the initialization depends upon expensive computation, maybe try to do them ahead of time
   --  and cache the result.
   --
   --  Returns true on success. If Init returns false, then the DSO must be considered
   --  uninitialized, and the host must not call Deinit nor any other CLAP-related symbols from the
   --  DSO.
   --  This function also returns true in the case where the DSO is already initialized, and no
   --  actual initialization work is done in this call, as explain above.
   --
   --  plugin_path is the path to the DSO (Linux, Windows), or the bundle (macOS).
   --
   --  This function may be called on any thread, including a different one from the one a later
   --  call to Deinit (or a later Init) can be made.
   --  However, it is forbidden to call this function simultaneously from multiple threads.
   --  It is also forbidden to call it simultaneously with *any* other CLAP-related symbols from the
   --  DSO, including (but not limited to) Deinit.

   type DeInit_Function is access procedure
   with Convention => C;
   --  De-initializes the DSO, freeing any resources allocated or initialized by Init.
   --
   --  After this function is called, no more calls into the DSO must be made, except calling Init
   --  again to re-initialize the DSO.
   --  This means that after Deinit is called, the DSO can be considered to be in the same state
   --  as if Init was never called at all yet, enabling it to be re-initialized as needed.
   --
   --  As stated above, even though hosts are forbidden to do so directly, multiple calls before any
   --  new Init call may still happen. Implementations *should* take this into account, and *must*
   --  do so as of CLAP 1.2.0.
   --
   --  Just like Init, this function may be called on any thread, including a different one from
   --  the one Init was called from, or from the one a later Init call can be made.
   --  However, it is forbidden to call this function simultaneously from multiple threads.
   --  It is also forbidden to call it simultaneously with *any* other CLAP-related symbols from the
   --  DSO, including (but not limited to) Deinit.

   type Get_Factory_Function is access
     function (Factory_ID : CLAP_Chars_Ptr)
               return CfA.Plugin_Factory.CLAP_Plugin_Factory_Access
   with Convention => C;
   -- Get the pointer to a factory. See Factory/cfa-Plugin_Factory.ads for an example.
   --
   -- Returns null if the factory is not provided.
   -- The returned pointer must *not* be freed by the caller.
   --
   -- Unlike Init and Deinit, this function can be called simultaneously by multiple threads.
   --
   -- [thread-safe]

   type CLAP_Entry is
      record
         Version     : CfA.Version.CLAP_Version := CfA.Version.CLAP_Version_Init;
         Init        : Init_Function            := null;
         DeInit      : DeInit_Function          := null;
         Get_Factory : Get_Factory_Function     := null;
      end record
     with Convention => C;

   type CLAP_Entry_Access is access CLAP_Entry with Convention => C;

end CfA.Plugin_Entry;
