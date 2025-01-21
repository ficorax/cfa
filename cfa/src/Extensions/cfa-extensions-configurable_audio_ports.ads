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

--  This extension lets the host configure the plugin's input and output audio ports.
--  This is a "push" approach to audio ports configuration.

with CfA.Plugins;

package CfA.Extensions.Configurable_Audio_Ports is

   CLAP_Ext_Configurable_Audio_Ports : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.configurable-audio-ports/1");

   CLAP_Ext_Configurable_Audio_Ports_Compat : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.configurable-audio-ports.draft1");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   type CLAP_Audio_Port_Configuration_Request is
      record
         Is_Input      : Bool;
         Port_Index    : UInt32_t := 0;
         --  Identifies the port by is_input and port_index

         Channel_Count : UInt32_t := 0;
         --  The requested number of channels.

         Port_Type     : CLAP_Chars_Ptr := CLAP_Null_Ptr;
         --  The port type, see audio-ports.h, clap_audio_port_info.port_type for interpretation.

         Port_Details  : Void_Ptr := Null_Void_Ptr;
         --  cast port_details according to port_type:
         --  - CLAP_Port_Mono: (discard)
         --  - CLAP_Port_Stereo: (discard)
         --  - CLAP_Port_Surround: Channel_Map : out UInt8_t
         --  - CLAP_Port_Ambisonic: Info : out Clap_Ambisonic_Config
      end record
     with Convention => C;

   type CLAP_Audio_Port_Configuration_Request_Access is
     access all CLAP_Audio_Port_Configuration_Request
   with Convention => C;

   type Can_Apply_Configuration_Function is access
     function (Plugin        : CfA.Plugins.CLAP_Plugin_Access;
               Requests      : CLAP_Audio_Port_Configuration_Request_Access;
               Request_Count : UInt32_t) return Bool
     with Convention => C;
   --  Returns true if the given configurations can be applied using apply_configuration().
   --  [main-thread && !active]

   type Apply_Configuration_Function is access
     function (Plugin        : CfA.Plugins.CLAP_Plugin_Access;
               Request       : CLAP_Audio_Port_Configuration_Request_Access;
               Request_Count : UInt32_t) return Bool
     with Convention => C;
   --  Submit a bunch of configuration requests which will atomically be applied together,
   --  or discarded together.
   --
   --  Once the configuration is successfully applied, it isn't necessary for the plugin to call
   --  Clap_Host_Audio_Ports.Changed; and it isn't necessary for the host to scan the
   --  audio ports.
   --
   --  Returns true if applied.
   --  [main-thread && !active]

   type CLAP_Plugin_Configurable_Audio_Ports is
      record
         Can_Apply_Configuration : Can_Apply_Configuration_Function;
         Apply_Configuration     : Apply_Configuration_Function;
      end record;

end CfA.Extensions.Configurable_Audio_Ports;
