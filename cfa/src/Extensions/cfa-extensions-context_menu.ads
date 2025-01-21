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
--  This extension lets the host and plugin exchange menu items and let the plugin ask the host to
--  show its context menu.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Context_Menu is

   CLAP_Ext_Context_Menu : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.context-menu/1");

   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.
   CLAP_Ext_Context_Menu_Compat : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.context-menu.draft/0");

   --  There can be different target kind for a context menu

   type CLAP_Context_Menu_Target_Kind is
     (
      CLAP_Context_Menu_Target_Kind_Global,
      CLAP_Context_Menu_Target_Kind_Param
      --  TODO: kind trigger once the trigger ext is marked as stable
     ) with Convention => C, Size => 32;

   for CLAP_Context_Menu_Target_Kind use
     (
      CLAP_Context_Menu_Target_Kind_Global => 0,
      CLAP_Context_Menu_Target_Kind_Param  => 1
     );

   --  Describes the context menu target
   type CLAP_Context_Menu_Target is
      record
         Kind : CLAP_Context_Menu_Target_Kind;
         ID   : CLAP_ID;
      end record
     with Convention => C;

   type CLAP_Context_Menu_Target_Access is access all CLAP_Context_Menu_Target;

   type CLAP_Context_Menu_Item_Kind is
     (
      CLAP_Context_Menu_Item_Entry,
      --  Adds a clickable menu entry.
      --  data: CLAP_Context_Menu_Entry_Access

      CLAP_Context_Menu_Item_Check_Entry,
      --  Adds a clickable menu entry which will feature both a checkmark and a label.
      --  data: CLAP_Context_Menu_Check_Entry_Access

      CLAP_Context_Menu_Item_Separator,
      --  Adds a separator line.
      --  data: null

      CLAP_Context_Menu_Item_Begin_Submenu,
      --  Starts a sub menu with the given label.
      --  data: CLAP_Context_Menu_Submenu_Access

      CLAP_Context_Menu_Item_End_Submenu,
      --  Ends the current sub menu.
      --  data: null

      CLAP_Context_Menu_Item_Title
      --  Adds a title entry
      --  data: CLAP_Context_Menu_Item_Title_Access
     ) with Convention => C, Size => 32;

   type CLAP_Context_Menu_Entry is
      record
         Label      : Interfaces.C.Strings.chars_ptr;
         --  text to be displayed

         Is_Enabled : Bool;
         --  if False, then the menu entry is greyed out and not clickable

         Action_ID  : CLAP_ID;
      end record
     with Convention => C;

   type CLAP_Context_Menu_Check_Entry is
      record
         Label      : Interfaces.C.Strings.chars_ptr;
         --  text to be displayed

         Is_Enabled : Bool;
         --  if False, then the menu entry is greyed out and not clickable

         Is_Checked : Bool;
         --  if True, then the menu entry will be displayed as checked

         Action_ID  : CLAP_ID;
      end record
     with Convention => C;

   type CLAP_Context_Menu_Title is
      record
         Title      : Interfaces.C.Strings.chars_ptr;
         --  text to be displayed

         Is_Enabled : Bool;
         --  if False, then the menu entry is greyed out
      end record
     with Convention => C;

   type CLAP_Context_Menu_Submenu is
      record
         Label      : Interfaces.C.Strings.chars_ptr;
         --  text to be displayed

         Is_Enabled : Bool;
         --  if False, then the menu entry is greyed out and won't show submenu
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------
   --  Context menu builder.
   --  This object isn't thread-safe and must be used on the same thread as it was provided.

   type CLAP_Context_Menu_Builder;
   type CLAP_Context_Menu_Builder_Access is access all CLAP_Context_Menu_Builder;

   type Add_Item_Function is access
     function (Builder   : CLAP_Context_Menu_Builder_Access;
               Item_Kind : CLAP_Context_Menu_Item_Kind;
               Item_Data : Void_Ptr)
               return Bool
     with Convention => C;
   --  Adds an entry to the menu.
   --  Item_Data type is determined by Item_Kind.

   type Supports_Function is access
     function (Builder   : CLAP_Context_Menu_Builder_Access;
               Item_Kind : CLAP_Context_Menu_Item_Kind)
               return Bool
     with Convention => C;
   --  Returns True if the menu builder supports the given item kind

   type CLAP_Context_Menu_Builder is
      record
         Ctx      : Void_Ptr;
         Add_Item : Add_Item_Function;
         Supports : Supports_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Populate_Function is access
     function (Plugin  : Plugins.CLAP_Plugin_Access;
               Target  : CLAP_Context_Menu_Target_Access;
               Builder : CLAP_Context_Menu_Builder_Access)
               return Bool
     with Convention => C;
   --  Insert plugin's menu items into the menu builder.
   --  If target is null, assume global context.
   --  [main-thread]

   type Perform_Function is access
     function (Plugin    : Plugins.CLAP_Plugin_Access;
               Target    : CLAP_Context_Menu_Target_Access;
               Action_ID : CLAP_ID)
               return Bool
     with Convention => C;
   --  Performs the given action, which was previously provided to the host via Populate.
   --  If target is null, assume global context.
   --  [main-thread]

   type CLAP_Plugin_Context_Menu is
      record
         Populate : Populate_Function;
         Perform  : Perform_Function;
      end record
     with Convention => C;

   type CLAP_Plugin_Context_Menu_Access is access all CLAP_Plugin_Context_Menu
     with Convention => C;
   -------------------------------------------------------------------------------------------------

   type Host_Populate_Function is access
     function (Host    : Hosts.CLAP_Host_Access;
               Target  : CLAP_Context_Menu_Target_Access;
               Builder : CLAP_Context_Menu_Builder_Access)
               return Boolean
     with Convention => C;
   --  Insert host's menu items into the menu builder.
   --  If target is null, assume global context.
   --  [main-thread]

   type Host_Perform_Function is access
     function (Host      : Hosts.CLAP_Host_Access;
               Target    : CLAP_Context_Menu_Target_Access;
               Action_ID : CLAP_ID)
               return Bool
     with Convention => C;
   --  Performs the given action, which was previously provided to the plugin via Populate.
   --  If target is null, assume global context.
   --  [main-thread]

   type Can_Popup_Function is access
     function (Host : Hosts.CLAP_Host_Access)
               return Bool
     with Convention => C;
   --  Returns true if the host can display a popup menu for the plugin.
   --  This may depends upon the current windowing system used to display the plugin, so the
   --  return value is invalidated after creating the plugin window.
   --  [main-thread]

   type Popup_Function is access
     function (Host         : Hosts.CLAP_Host_Access;
               Target       : CLAP_Context_Menu_Target_Access;
               Screen_Index : UInt32_t;
               X            : UInt32_t;
               Y            : UInt32_t)
               return Bool
     with Convention => C;
   --  Shows the host popup menu for a given parameter.
   --  If the plugin is using embedded GUI, then X and Y are relative to the plugin's window,
   --  otherwise they're absolute coordinate, and Screen Index might be set accordingly.
   --  If target is null, assume global context.
   --  [main-thread]

   type CLAP_Host_Context_Menu is
      record
         Populate  : Host_Populate_Function;
         Perform   : Host_Perform_Function;
         Can_Popup : Can_Popup_Function;
         Popup     : Popup_Function;
      end record
     with Convention => C;

   type CLAP_Host_Context_Menu_Access is access all CLAP_Host_Context_Menu
     with Convention => C;

end CfA.Extensions.Context_Menu;
