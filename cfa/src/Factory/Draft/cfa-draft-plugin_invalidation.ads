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

package CfA.Draft.Plugin_Invalidation is

   CLAP_Plugin_Invalidation_Factory_ID : constant Chars_Ptr :=
     Interfaces.C.Strings.New_String
       ("clap.plugin-invalidation-factory/draft0");
   --  Use it to retrieve const clap_plugin_invalidation_factory_t* from
   --  clap_plugin_entry.get_factory()

   type CLAP_Plugin_Invalidation_Source is
      record
         Directory      : Chars_Ptr := Null_Ptr;
         --  Directory containing the file(s) to scan, must be absolute

         Filename_Glob  : Chars_Ptr := Null_Ptr;
         --  globing pattern, in the form *.dll

         Recursive_Scan : Bool     := False;
         --  should the directory be scanned recursively?
      end record
     with Convention => C;

   --  Used to figure out when a plugin needs to be scanned again.
   --  Imagine a situation with a single entry point: my-plugin.clap which then
   --  scans itself a set of "sub-plugins". New plugin may be available even if
   --  my-plugin.clap file doesn't change. This interfaces solves this issue and
   --  gives a way to the host to monitor additional files.

   type CLAP_Plugin_Invalidation_Factory;
   type CLAP_Plugin_Invalidation_Factory_Access is
     access CLAP_Plugin_Invalidation_Factory
       with Convention => C;

   type Count_Function is access
     function (Factory : CLAP_Plugin_Invalidation_Factory_Access) return UInt32_t
     with Convention => C;
   --  Get the number of invalidation source.

   type Get_Function is access
     function (Factory : CLAP_Plugin_Invalidation_Factory_Access;
               Index   : UInt32_t)
               return access CLAP_Plugin_Invalidation_Source
     with Convention => C;
   --  Get the invalidation source by its index.
   --  [thread-safe]

   type Refresh_Function is access
     function (Factory : CLAP_Plugin_Invalidation_Factory_Access) return Bool
     with Convention => C;
   --  In case the host detected a invalidation event, it can call refresh() to let the
   --  plugin_entry update the set of plugins available.
   --  If the function returned false, then the plugin needs to be reloaded.

   type CLAP_Plugin_Invalidation_Factory is
      record
         Count   : Count_Function   := null;
         Get     : Get_Function     := null;
         Refresh : Refresh_Function := null;
      end record
     with Convention => C;

end CfA.Draft.Plugin_Invalidation;
