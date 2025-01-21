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
--  This extension lets the plugin report the current gain adjustment
--  (typically, gain reduction) to the host.

with CfA.Plugins;

package CfA.Extensions.Draft.Gain_Adhustment_Metering is

   CLAP_Ext_Gain_Adjustment_Metering : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.gain-adjustment-metering/0");

   type Get_Fucntion is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return CLAP_Double
     with Convention => C;
   --  Returns the current gain adjustment in dB. The value is intended
   --  for informational display, for example in a host meter or tooltip.
   --  The returned value represents the gain adjustment that the plugin
   --  applied to the last sample in the most recently processed block.
   --
   --  The returned value is in dB. Zero means the plugin is applying no gain
   --  reduction, or is not processing. A negative value means the plugin is
   --  applying gain reduction, as with a compressor or limiter. A positive
   --  value means the plugin is adding gain, as with an expander. The value
   --  represents the dynamic gain reduction or expansion applied by the
   --  plugin, before any make-up gain or other adjustment. A single value is
   --  returned for all audio channels.
   --
   --  [audio-thread]

   type CLAP_Plugin_Gain_Adjustment_Metering is
      record
         Get : Get_Fucntion;
      end record
     with Convention => C;

   type CLAP_Plugin_Gain_Adjustment_Metering_Access is
     access all CLAP_Plugin_Gain_Adjustment_Metering
   with Convention => C;

end CfA.Extensions.Draft.Gain_Adhustment_Metering;
