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

----------------------------------------------------------------------------------------------------
--  This extension can be used to specify the CV channel type used by
--  the plugin.
--  Work in progress, suggestions are welcome

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.CVs is

   CLAP_Ext_CV : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.cv.draft/0");

   CLAP_Port_CV : constant Char_Ptr :=
                    Interfaces.C.Strings.New_String ("cv");

   type CLAP_CV_Signal is
     (
      --  TODO: standardize values?
      Value,
      Gate,
      Pitch
     ) with Convention => C, Size => 32;

   --  TODO: maybe we want a Channel_Info instead, where we could have more
   --  details about the supported ranges?

   type Get_Channel_Type_Function is access
     function (Plugin        : Plugins.CLAP_Plugin_Access;
               Is_Input      : Bool;
               Port_Index    : UInt32_t;
               Channel_Index : UInt32_t;
               Channel_Type  : out CLAP_CV_Signal)
               return Bool
     with Convention => C;
   --  Returns True on success.
   --  [main-thread]

   type CLAP_Plugin_CV is
      record
         Get_Channel_Type : Get_Channel_Type_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_CV_Access is access CLAP_Plugin_CV
     with Convention => C;

   type Changed_Function is access
     procedure (Host : CfA.Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the channels type have changed.
   --  The channels type can only change when the plugin is de-activated.
   --  [main-thread,!active]

   type CLAP_Host_CV is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_CV_Access is access CLAP_Host_CV
     with Convention => C;

end CfA.Extensions.Draft.CVs;
