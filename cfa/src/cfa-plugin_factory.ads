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

with CfA.Hosts;
with CfA.Plugins;

package CfA.Plugin_Factory is

   CLAP_Plugin_Factory_ID : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.plugin-factory");

   type CLAP_Plugin_Factory;
   type CLAP_Plugin_Factory_Access is access all CLAP_Plugin_Factory
     with Convention => C;

   type Get_Plugin_Count_Function is access
     function (Factory : CLAP_Plugin_Factory_Access) return UInt32_t
     with Convention => C;
   --  Get the number of plugins available.
   --  [thread-safe]

   type Get_Plugin_Descriptor_Function is access
     function (Factory : CLAP_Plugin_Factory_Access;
               Index   : UInt32_t)
               return CfA.Plugins.CLAP_Plugin_Descriptor_Access
     with Convention => C;
   --  Retrieves a plugin descriptor by its index.
   --  Returns null in case of error.
   --  The descriptor must not be freed.
   --  [thread-safe]

   type Create_Plugin_Function is access
     function (Factory   : CLAP_Plugin_Factory_Access;
               Host      : CfA.Hosts.CLAP_Host_Access;
               Plugin_ID : Char_Ptr)
               return CfA.Plugins.CLAP_Plugin_Access
     with Convention => C;
   --  Create a clap_plugin by its Plugin_ID.
   --  The returned pointer must be freed by calling Plugin.Destroy (Plugin);
   --  The plugin is not allowed to use the host callbacks in the create method.
   --  Returns null in case of error.
   --  [thread-safe]

   --  Every method must be thread-safe.
   --  It is very important to be able to scan the plugin as quickly as
   --  possible.
   --
   --  The host may use CLAP_Plugin_Invalidation_Factory to detect filesystem changes
   --  which may change the factory's content.
   type CLAP_Plugin_Factory is
      record
         Get_Plugin_Count      : Get_Plugin_Count_Function := null;
         Get_Plugin_Descriptor : Get_Plugin_Descriptor_Function := null;
         Create_Plugin         : Create_Plugin_Function := null;
      end record
     with Convention => C;

end CfA.Plugin_Factory;
