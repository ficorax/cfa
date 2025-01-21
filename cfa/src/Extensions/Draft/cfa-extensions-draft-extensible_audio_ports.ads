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
--  This extension lets the host add and remove audio ports to the plugin.

with CfA.Plugins;

package CfA.Extensions.Draft.Extensible_Audio_Ports is

   CLAP_Ext_Extensible_Audio_Ports : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.extensible-audio-ports/1");

   type Add_Port_Function is access
     function (Plugin        : Plugins.CLAP_Plugin_Access;
               Is_Input      : Bool;
               Channel_Count : UInt32_t;
               Port_Type     : CLAP_Chars_Ptr;
               Port_Details  : CLAP_Chars_Ptr) return Bool
     with Convention => C;
   --  Asks the plugin to add a new port (at the end of the list), with the following settings.
   --  port_type: see clap_audio_port_info.port_type for interpretation.
   --  port_details: see clap_audio_port_configuration_request.port_details for interpretation.
   --  Returns true on success.
   --  [main-thread && !is_active]

   type Remove_Port_Function is access
     function (Plugin   : Plugins.CLAP_Plugin_Access;
               Is_Input : Bool;
               Index    : UInt32_t) return Bool
     with Convention => C;
   --  Asks the plugin to remove a port.
   --  Returns true on success.
   --  [main-thread && !is_active]

   type CLAP_Plugin_Extensible_Audio_Ports is
      record
         Add_Port    : Add_Port_Function := null;
         Remove_Port : Add_Port_Function := null;

      end record
     with Convention => C;
end CfA.Extensions.Draft.Extensible_Audio_Ports;
