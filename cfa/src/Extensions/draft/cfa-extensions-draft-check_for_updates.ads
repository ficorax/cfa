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

package CfA.Extensions.Draft.Check_For_Updates is

   CLAP_Ext_Check_For_Update : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.check_for_update.draft/0");

   type CLAP_Check_For_Update_Info is
      record
         Version : Char_Ptr := Null_Ptr;
         --  latest version

         Release_Date : Char_Ptr := Null_Ptr;
         --  YYYY-MM-DD

         URL          : Char_Ptr := Null_Ptr;
         --  url to a download page which the user can visit

         Is_Preview : Bool := False;
         --  True if this version is a preview release
      end record
     with Convention => C;

   type CLAP_Check_For_Update_Info_Access is access CLAP_Check_For_Update_Info
     with Convention => C;

   type Check_Function is access
     procedure (Plugin          : Plugins.CLAP_Plugin_Access;
                Include_Preview : Bool)
     with Convention => C;
   --  [main-thread]

   type CLAP_Plugin_Check_For_Update is
      record
         Check : Check_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Check_For_Update_Access is access CLAP_Plugin_Check_For_Update
     with Convention => C;

   type On_New_Version_Function is access
     procedure (Host        : Hosts.CLAP_Host_Access;
                Update_Info : CLAP_Check_For_Update_Info_Access)
     with Convention => C;
   --  [main-thread]

   type CLAP_Host_Check_For_Update is
      record
         On_New_Version : On_New_Version_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Check_For_Update_Access is access CLAP_Host_Check_For_Update
     with Convention => C;

end CfA.Extensions.Draft.Check_For_Updates;
