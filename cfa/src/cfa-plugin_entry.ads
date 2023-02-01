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

with CfA.Plugin_Factory;
with CfA.Version;

package CfA.Plugin_Entry is

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
   --  In addition to the OS-specific default locations above, a CLAP host must
   --  query the environment for a CLAP_PATH variable, which is a list of
   --  directories formatted in the same manner as the host OS binary search
   --  path (PATH on Unix, separated by `:` and Path on Windows, separated
   --  by ';', as of this writing).
   --
   --  Each directory should be recursively searched for files and/or bundles
   --  as appropriate in your OS ending with the extension `.clap`.
   --
   --  Every method must be thread-safe.

   type Init_Function is access
     function (Plugin_Path : Char_Ptr) return Bool
   with Convention => C;
   --  This function must be called first, and can only be called once.
   --
   --  It should be as fast as possible, in order to perform a very quick scan of the plugin
   --  descriptors.
   --
   --  It is forbidden to display graphical user interface in this call.
   --  It is forbidden to perform user interaction in this call.
   --
   --  If the initialization depends upon expensive computation, maybe try to do them ahead of time
   --  and cache the result.
   --
   --  If Init returns False, then the host must not call dDeIinit nor any other clap
   --  related symbols from the DSO.

   type DeInit_Function is access procedure
   with Convention => C;
   --  No more calls into the DSO must be made after calling DeInit.

   type Get_Factory_Function is access
     function (Factory_ID : Char_Ptr)
               return CfA.Plugin_Factory.CLAP_Plugin_Factory_Access
   with Convention => C;
   --  Get the pointer to a factory. See facotyr/cfa-plugin_factory.adsfactory.ads for an example.
   --
   --  Returns null if the factory is not provided.
   --  The returned pointer must *not* be freed by the caller.

   type CLAP_Entry is
      record
         Version     : CfA.Version.CLAP_Version :=
                         CfA.Version.CLAP_Version_Init;
         Init        : Init_Function := null;
         DeInit      : DeInit_Function := null;
         Get_Factory : Get_Factory_Function := null;
      end record
     with Convention => C;

   type CLAP_Entry_Access is access CLAP_Entry with Convention => C;

end CfA.Plugin_Entry;
