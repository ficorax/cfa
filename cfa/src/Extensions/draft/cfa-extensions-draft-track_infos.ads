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

with CfA.Hosts;
with CfA.Plugins;
with CfA.Colors;

package CfA.Extensions.Draft.Track_Infos is

   use type Interfaces.C.size_t;

   CLAP_Ext_Track_Info : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.track-info.draft/0");

   type CLAP_Track_Info is
      record
         ID              : CLAP_ID;
         Index           : UInt32_t := 0;
         Name            : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Path            : Interfaces.C.char_array (0 .. CLAP_Path_Size - 1);
         --  Like "/group1/group2/drum-machine/drum-pad-13"
         Channel_Count   : UInt32_t := 0;
         Audio_Port_Type : Char_Ptr := Null_Ptr;
         Color           : CfA.Colors.CLAP_Color;
         Is_Return_Track : Bool := False;
      end record
     with Convention => C;

   type CLAP_Track_Info_Access is access all CLAP_Track_Info
     with Convention => C;

   type Changed_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access)
     with Convention => C;
   --  [main-thread]

   type CLAP_Plugin_Track_Info is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Track_Info_Access is access CLAP_Plugin_Track_Info
     with Convention => C;

   type Get_Function is access
     function (Host : Hosts.CLAP_Host_Access;
               Info : out CLAP_Track_Info)
               return Bool
     with Convention => C;
   --  Get info about the track the plugin belongs to.
   --  [main-thread]

   type CLAP_Host_Track_Info is
      record
         Get : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Track_Info_Access is access all CLAP_Host_Track_Info
     with Convention => C;

end CfA.Extensions.Draft.Track_Infos;
