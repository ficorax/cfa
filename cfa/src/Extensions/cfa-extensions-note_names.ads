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

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Note_Names is

   use type Interfaces.C.size_t;

   CLAP_Ext_Note_Name : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.note-name");

   type CLAP_Note_Name is
      record
         Name      : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Port      : Int16_t := 0;    --  -1 for every port
         Key       : Int16_t := 0;    --  -1 for every key
         T_Channel : Int16_t := 0;    --  -1 for every channel
      end record
     with Convention => C;

   type CLAP_Note_Name_Access is access CLAP_Note_Name with Convention => C;

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  Return the number of note names
   --  [main-thread]

   type Get_Function is access
     function (Plugin    : Plugins.CLAP_Plugin_Access;
               Index     : UInt32_t;
               Note_Name : CLAP_Note_Name_Access)
               return Bool
     with Convention => C;
   --  Returns true on success and stores the result into note_name
   --  [main-thread]

   type CLAP_Plugin_Note_Name is
      record
         Count : Count_Function := null;
         Get   : Get_Function   := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Note_Name_Access is access CLAP_Plugin_Note_Name
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the note names have changed.
   --  [main-thread]

   type CLAP_Host_Note_Name is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Note_Name_Access is access all CLAP_Host_Note_Name
     with Convention => C;

end CfA.Extensions.Note_Names;
