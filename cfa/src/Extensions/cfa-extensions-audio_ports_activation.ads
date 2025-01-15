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
--  Audio Ports Activation
--
--  This extension provides a way for the host to activate and de-activate audio ports.
--  Deactivating a port provides the following benefits:
--  - the plugin knows ahead of time that a given input is not present and can choose
--    an optimized computation path,
--  - the plugin knows that an output is not consumed by the host, and doesn't need to
--    compute it.
--
--  Audio ports can only be activated or deactivated when the plugin is deactivated, unless
--  Can_Activate_While_Processing returns True.
--
--  Audio buffers must still be provided if the audio port is deactivated.
--  In such case, they shall be filled with 0 (or whatever is the neutral value in your context)
--  and the Constant_Mask shall be set.
--
--  Audio ports are initially in the active state after creating the plugin instance.
--  Audio ports state are not saved in the plugin state, so the host must restore the
--  audio ports state after creating the plugin instance.
--
--  Audio ports state is invalidated by CLAP_Plugin_Audio_Ports_Config.Select and
--  CLAP_Host_Audio_Ports.Rescan (CLAP_Audio_Ports_Rescan_List).

with CfA.Plugins;

package CfA.Extensions.Audio_Ports_Activation is

   CLAP_Ext_Audio_Ports_Activation : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.audio-ports-activation/2");

   CLAP_Ext_Audio_Ports_Activation_Compat : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.audio-ports-activation/draft-2");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   type Can_Activate_While_Processing_Funcion is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return Bool
     with Convention => C;
   --  Returns True if the plugin supports activation/deactivation while processing.
   --  [main-thread]

   type Set_Active_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Is_Input   : Bool;
               Port_Index : UInt32_t;
               Is_Active  : Bool)
               return Bool
     with Convention => C;
   --  Activate the given port.
   --
   --  It is only possible to activate and de-activate on the audio-thread if
   --  Can_Activate_While_Processing returns true.
   --
   --  Sample_Size indicate if the host will provide 32 bit audio buffers or 64 bits one.
   --  Possible values are: 32, 64 or 0 if unspecified.
   --
   --  returns false if failed, or invalid parameters
   --  [active ? audio-thread : main-thread]

   type CLAP_Plugin_Audio_Ports_Activation is
      record
         Can_Activate_While_Processing : Can_Activate_While_Processing_Funcion;
         Set_Active                    : Set_Active_Function;
      end record
     with Convention => C;

end CfA.Extensions.Audio_Ports_Activation;
