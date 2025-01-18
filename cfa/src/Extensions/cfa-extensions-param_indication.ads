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
--  This extension lets the host tell the plugin to display a little color based indication on the
--  parameter. This can be used to indicate:
--  - a physical controller is mapped to a parameter
--  - the parameter is current playing an automation
--  - the parameter is overriding the automation
--  - etc...
--
--  The color semantic depends upon the host here and the goal is to have a consistent experience
--  across all plugins.

with CfA.Colors;
with CfA.Plugins;

package CfA.Extensions.Param_Indication is

   CLAP_Ext_Param_Indication : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.param-indication/4");

   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.
   CLAP_Ext_Param_Indication_Compat : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.param-indication.draft/4");

   type CLAP_Param_Indication_Automation is
     (
      CLAP_Param_Indication_Automation_None,
      --  The host doesn't have an automation for this parameter

      CLAP_Param_Indication_Automation_Present,
      --  The host has an automation for this parameter, but it isn't playing it

      CLAP_Param_Indication_Automation_Playing,
      --  The host is playing an automation for this parameter

      CLAP_Param_Indication_Automation_Recording,
      --  The host is recording an automation on this parameter

      CLAP_Param_Indication_Automation_Overriding
      --  The host should play an automation for this parameter, but the user has started to ajust
      --  this parameter and is overriding the automation playback
     ) with Convention => C, Size => UInt32_t'Size;

   for CLAP_Param_Indication_Automation use
     (
      CLAP_Param_Indication_Automation_None       => 0,
      CLAP_Param_Indication_Automation_Present    => 1,
      CLAP_Param_Indication_Automation_Playing    => 2,
      CLAP_Param_Indication_Automation_Recording  => 3,
      CLAP_Param_Indication_Automation_Overriding => 4
     );

   -------------------------------------------------------------------------------------------------

   type Set_Mapping_Function is access
     procedure (Plugin      : Plugins.CLAP_Plugin_Access;
                Param_ID    : CLAP_ID;
                Has_Mapping : Bool;
                Color       : Colors.CLAP_Color_Access;
                Label       : Interfaces.C.Strings.chars_ptr;
                Description : Interfaces.C.Strings.chars_ptr)
     with Convention => C;
   --  Sets or clears a mapping indication.
   --
   --  Has_Mapping: does the parameter currently has a mapping?
   --  Color: if set, the color to use to highlight the control in the plugin GUI
   --  Label: if set, a small string to display on top of the knob which identifies the hardware
   --         controller
   --  Description: if set, a string which can be used in a tooltip, which describes the
   --         current mapping
   --
   --  Parameter indications should not be saved in the plugin context, and are off by default.
   --  [main-thread]

   type Set_Automation_Function is access
     procedure (Plugin           : Plugins.CLAP_Plugin_Access;
                Param_ID         : CLAP_ID;
                Automation_State : CLAP_Param_Indication_Automation;
                Color            : Colors.CLAP_Color_Access)
     with Convention => C;
   --  Sets or clears an automation indication.
   --
   --  Automation_State: current automation state for the given parameter
   --  Color: if set, the color to use to display the automation indication in the plugin GUI
   --
   --  Parameter indications should not be saved in the plugin context, and are off by default.
   --  [main-thread]

   type CLAP_Plugin_Param_Indication is
      record
         Set_Mapping    : Set_Mapping_Function;
         Set_Automation : Set_Automation_Function;
      end record
     with Convention => C;

end CfA.Extensions.Param_Indication;
