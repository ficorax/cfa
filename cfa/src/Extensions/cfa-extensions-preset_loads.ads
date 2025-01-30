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

with CfA.Hosts;
with CfA.Plugins;
with CfA.Preset_Discovery;

package CfA.Extensions.Preset_Loads is

   CLAP_Ext_Preset_Load : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.preset-load/2");

   CLAP_Ext_Preset_Load_Compat : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.preset-load.draft/2");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   type From_Location_Function is access
     function (Plugin        : Plugins.CLAP_Plugin_Access;
               Location_Kind : Preset_Discovery.CLAP_Preset_Discovery_Location_Kind;
               Location      : CLAP_Chars_Ptr;
               Load_Key      : CLAP_Chars_Ptr) return Bool
     with Convention => C;
   --  Loads a preset in the plugin native preset file format from a URI. eg:
   --  - "file:///home/abique/.u-he/Diva/Presets/Diva/HS Bass Nine.h2p", load_key: null
   --  - "plugin://<plugin-id>", load_key: <XXX>
   --
   --  The preset discovery provider defines the uri and load_key to be passed to this function.
   --
   --  [main-thread]

   type CLAP_Plugin_Preset_Load is
      record
         From_Location : From_Location_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Preset_Load_Access is access CLAP_Plugin_Preset_Load
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type On_Error_Function is access
     procedure (Host          : Hosts.CLAP_Host_Access;
                Location_Kind : Preset_Discovery.CLAP_Preset_Discovery_Location_Kind;
                Location      : CLAP_Chars_Ptr;
                Load_Key      : CLAP_Chars_Ptr;
                OS_Error      : Int32_t;
                Msg           : CLAP_Chars_Ptr)
     with Convention => C;
   --  Called if CLAP_Plugin_Preset_Load.Load failed.
   --  OS_Error: the operating system error, if applicable. If not applicable set it to a non-error
   --  value, eg: 0 on unix and Windows.
   --
   --  [main-thread]

   type Loaded_Function is access
     procedure (Host          : Hosts.CLAP_Host_Access;
                Location_Kind : Preset_Discovery.CLAP_Preset_Discovery_Location_Kind;
                Location      : CLAP_Chars_Ptr;
                Load_Key      : CLAP_Chars_Ptr)
     with Convention => C;
   --  Informs the host that the following preset has been loaded.
   --  This contributes to keep in sync the host preset browser and plugin preset browser.
   --  If the preset was loaded from a container file, then the load_key must be set, otherwise it
   --  must be null.
   --
   --  [main-thread]

   type CLAP_Host_Preset_Load is
      record
         On_Error : On_Error_Function;
         Loaded   : Loaded_Function;
      end record
     with Convention => C;

   type CLAP_Host_Preset_Load_Access is access all CLAP_Host_Preset_Load
     with Convention => C;

end CfA.Extensions.Preset_Loads;
