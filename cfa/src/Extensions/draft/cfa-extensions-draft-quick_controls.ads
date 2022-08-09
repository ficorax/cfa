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
--  This extensions provides a set of pages, where each page contains up
--  to 8 controls. Those controls are param_id, and they are meant to be mapped
--  onto a physical controller. We chose 8 because this what most controllers
--  offer, and it is more or less a standard.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Quick_Controls is

   use type Interfaces.C.size_t;

   CLAP_Ext_Quick_Controls : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.quick-controls.draft/0");

   CLAP_Quick_Controls_Count : constant := 8;

   type CLAP_Quick_Controls_Page is
      record
         ID        : CLAP_ID;
         Name      : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Param_IDs : CLAP_ID_Array (0 .. CLAP_Quick_Controls_Count - 1);
      end record
     with Convention => C;

   type CLAP_Quick_Controls_Page_Access is access CLAP_Quick_Controls_Page
     with Convention => C;

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  [main-thread]

   type Get_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Page_Index : UInt32_t;
               Page       : CLAP_Quick_Controls_Page_Access)
               return Bool
     with Convention => C;
   --  [main-thread]

   type CLAP_Plugin_Quick_Controls is
      record
         Count : Count_Function := null;
         Get   : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Quick_Controls_Access is access CLAP_Plugin_Quick_Controls
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the quick controls have changed.
   --  [main-thread]

   type Suggest_Page_Function is access
     procedure (Host    : Hosts.CLAP_Host_Access;
                Page_ID : CLAP_ID)
     with Convention => C;
   --  Suggest a page to the host because it correspond to what the user is
   --  currently editing in the plugin's GUI.
   --  [main-thread]

   type CLAP_Host_Quick_Controls is
      record
         Changed      : Changed_Function := null;
         Suggest_Page : Suggest_Page_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Quick_Controls_Access is access all CLAP_Host_Quick_Controls
     with Convention => C;

end CfA.Extensions.Draft.Quick_Controls;
