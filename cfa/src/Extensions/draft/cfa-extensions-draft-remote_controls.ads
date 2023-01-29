--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2023 Marek Kuziel
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
--  This extension let the plugin provide a structured way of mapping parameters to an hardware
--  controller.
--
--  This is done by providing a set of remote control pages organized by section.
--  A page contains up to 8 controls, which references parameters using param_id.
--
--  |`- [section:main]
--  |    `- [name:main] performance controls
--  |`- [section:osc]
--  |   |`- [name:osc1] osc1 page
--  |   |`- [name:osc2] osc2 page
--  |   |`- [name:osc-sync] osc sync page
--  |    `- [name:osc-noise] osc noise page
--  |`- [section:filter]
--  |   |`- [name:flt1] filter 1 page
--  |    `- [name:flt2] filter 2 page
--  |`- [section:env]
--  |   |`- [name:env1] env1 page
--  |    `- [name:env2] env2 page
--  |`- [section:lfo]
--  |   |`- [name:lfo1] env1 page
--  |    `- [name:lfo2] env2 page
--   `- etc...
--
--  One possible workflow is to have a set of buttons, which correspond to a section.
--  Pressing that button once gets you to the first page of the section.
--  Press it again to cycle through the section's pages.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Remote_Controls is

   use type Interfaces.C.size_t;

   CLAP_Ext_Remote_Controls : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.remote-controls.draft/1");

   CLAP_Remote_Controls_Count : constant Interfaces.C.size_t := 8;

   type CLAP_Remote_Controls_Page is
      record
         Section_Name : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Page_ID      : CLAP_ID;
         Page_Name    : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         Param_IDs    : CLAP_ID_Array (0 .. CLAP_Remote_Controls_Count - 1);
      end record
     with Convention => C;

   ----------------------------------------------------------------------------`--------------------

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return UInt32_t
     with Convention => C;
   --  Returns the number of pages.
   --  [main-thread]

   type Get_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Page_Index : UInt32_t;
               Page       : out CLAP_Remote_Controls_Page)
               return Bool
     with Convention => C;
   --  Get a page by index.
   --  [main-thread]

   type CLAP_Plugin_Remote_Controls is
      record
         Count : Count_Function;
         Get   : Get_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the remote controls have changed.
   --  [main-thread]

   type Suggest_Page_Function is access
     procedure (Host    : Hosts.CLAP_Host_Access;
                Page_ID : CLAP_ID)
     with Convention => C;
   --  Suggest a page to the host because it correspond to what the user is currently editing in the
   --  plugin's GUI.
   --  [main-thread]

   type CLAP_Host_Remote_Controls is
      record
         Changed      : Changed_Function;
         Suggest_Page : Suggest_Page_Function;
      end record
     with Convention => C;

end CfA.Extensions.Draft.Remote_Controls;
