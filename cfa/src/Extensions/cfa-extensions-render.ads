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

with CfA.Plugins;

package CfA.Extensions.Render is

   CLAP_Ext_Render : constant Chars_Ptr :=
                       Interfaces.C.Strings.New_String ("clap.render");

   type CLAP_Plugin_Render_Mode is
     (
      CLAP_Render_Realtime,
      --  Default setting, for "realtime" processing

      CLAP_Render_Offline
      --  For processing without realtime pressure
      --  The plugin may use more expensive algorithms for higher sound quality.
     ) with Convention => C, Size => 32;

   --  The render extension is used to let the plugin know if it has "realtime"
   --  pressure to process.
   --
   --  If this information does not influence your rendering code, then don't
   --  implement this extension.

   type Has_Hard_Realtime_Requirement_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return Bool
     with Convention => C;
   --  Returns true if the plugin has an hard requirement to process in
   --  real-time. This is especially useful for plugin acting as a proxy to
   --  an hardware device.
   --  [main-thread]

   type Set_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Mode   : CLAP_Plugin_Render_Mode)
               return Bool
     with Convention => C;
   --  Returns true if the rendering mode could be applied.
   --  [main-thread]

   type CLAP_Plugin_Render is
      record
         Has_Hard_Realtime_Requirement : Has_Hard_Realtime_Requirement_Function := null;
         Set                           : Set_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Render_Access is access CLAP_Plugin_Render
     with Convention => C;

end CfA.Extensions.Render;
