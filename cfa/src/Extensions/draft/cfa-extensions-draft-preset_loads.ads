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

with CfA.Plugins;

package CfA.Extensions.Draft.Preset_Loads is

   CLAP_Ext_Preset_Load : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.preset-load.draft/0");

   type From_File_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Path   : out Char_Ptr)
               return Bool
     with Convention => C;
   --  Loads a preset in the plugin native preset file format from a path.
   --  [main-thread]

   type CLAP_Plugin_Preset_Load is
      record
         From_File : From_File_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Preset_Load_Access is access CLAP_Plugin_Preset_Load
     with Convention => C;

end CfA.Extensions.Draft.Preset_Loads;
