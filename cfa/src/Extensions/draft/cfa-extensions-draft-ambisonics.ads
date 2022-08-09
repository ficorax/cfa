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
--  This extension can be used to specify the channel mapping used by
--  the plugin.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Ambisonics is

   CLAP_Ext_Ambisonic : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.ambisonic.draft/0");

   CLAP_Port_Ambisonic : constant Char_Ptr :=
                           Interfaces.C.Strings.New_String ("ambisonic");

   type CLAP_Ambisonic_Channel_Ordering is
   (
    FuMa,
    --  FuMa channel ordering

    ACN
   --  ACN channel ordering
   ) with Convention => C, Size => 32;

   type CLAP_Ambisonic_Normalization is
     (
      MaxN,
      SN3D,
      N3D,
      SN2D,
      N2D
     ) with Convention => C, Size => 32;

   type CLAP_Ambisonic_Info is
      record
         Ordering      : CLAP_Ambisonic_Channel_Ordering;
         Normalization : CLAP_Ambisonic_Normalization;
      end record
     with Convention => C;

   type CLAP_Ambisonic_Info_Access is access CLAP_Ambisonic_Info
     with Convention => C;

   type Get_Info_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Is_Input   : Bool;
               Port_Index : UInt32_t;
               Info       : CLAP_Ambisonic_Info_Access)
               return Bool
     with Convention => C;
   --  Returns true on success
   --  [main-thread]

   type CLAP_Plugin_Ambisonic is
      record
         Get_Info : Get_Info_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Ambisonic_Access is access CLAP_Plugin_Ambisonic
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the info has changed.
   --  The info can only change when the plugin is de-activated.
   --  [main-thread]

   type CLAP_Host_Ambisonic is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Ambisonic_Access is access CLAP_Host_Ambisonic
     with Convention => C;

end CfA.Extensions.Draft.Ambisonics;
