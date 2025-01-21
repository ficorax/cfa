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
--  GUI
--
--  This extension defines how the plugin will present its GUI.
--
--  There are two approaches:
--  1. the plugin creates a window and embeds it into the host's window
--  2. the plugin creates a floating window
--
--  Embedding the window gives more control to the host, and feels more
--  integrated.
--  Floating window are sometimes the only option due to technical limitations.
--
--  The Embedding protocol is by far the most common, supported by all hosts to date,
--  and a plugin author should support at least that case.
--
--  Showing the GUI works as follow:
--   1. CLAP_Plugin_GUI.Is_API_Supported, check what can work
--   2. CLAP_Plugin_GUI.Create, allocates GUI resources
--   3. if the plugin window is floating
--   4.    -> CLAP_Plugin_GUI.Set_Transient
--   5.    -> CLAP_Plugin_GUI.Suggest_Title
--   6. else
--   7.    -> CLAP_Plugin_GUI.Set_Scale
--   8.    -> CLAP_Plugin_GUI.Can_Resize
--   9.    -> if resizable and has known size from previous session,
--            CLAP_Plugin_GUI.Set_Size
--  10.    -> else CLAP_Plugin_GUI.Get_Size, gets initial size
--  11.    -> CLAP_Plugin_GUI.Set_Parent
--  12. CLAP_Plugin_GUI.Show
--  13. CLAP_Plugin_GUI.Hide/Show ...
--  14. CLAP_Plugin_GUI.Destroy when done with the GUI
--
--  Resizing the window (initiated by the plugin, if embedded):
--  1. Plugins calls CLAP_Host_GUI.Request_Resize
--  2. If the host returns True the new size is accepted,
--     the host doesn't have to call CLAP_Plugin_GUI.Set_Size.
--     If the host returns False, the new size is rejected.
--
--  Resizing the window (drag, if embedded)):
--  1. Only possible if CLAP_Plugin_GUI.Can_Resize returns True
--  2. Mouse drag -> New_Size
--  3. CLAP_Plugin_GUI.Adjust_Size (New_Size) -> Working_Size
--  4. CLAP_Plugin_GUI.Set_Size (Working_Size)

with System;

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.GUIs is

   CLAP_Ext_GUI : constant CLAP_Chars_Ptr :=
                    Interfaces.C.Strings.New_String ("clap.GUI");

   --  If your windowing API is not listed here, please open an issue and we'll
   --  figure it out.
   --  https:--github.com/free-audio/clap/issues/new

   --  uses physical size
   --  embed using https:--docs.microsoft.com/en-us/windows/win32/api/winuser/
   --                      nf-winuser-setparent
   CLAP_Window_API_Win32 : constant CLAP_Chars_Ptr :=
                             Interfaces.C.Strings.New_String ("win32");

   --  uses logical size, don't CALL Clap_Plugin_GUI.Set_Scale
   CLAP_Window_API_Cocoa : constant CLAP_Chars_Ptr :=
                             Interfaces.C.Strings.New_String ("cocoa");

   --  uses physical size
   --  embed using https:--specifications.freedesktop.org/xembed-spec/
   --                      xembed-spec-latest.html
   CLAP_Window_API_X11 : constant CLAP_Chars_Ptr :=
                           Interfaces.C.Strings.New_String ("x11");

   --  uses physical size
   --  embed is currently not supported, use floating windows
   CLAP_Window_API_Wayland : constant CLAP_Chars_Ptr :=
                               Interfaces.C.Strings.New_String ("wayland");

   subtype CLAP_Hwnd   is Void_Ptr;
   subtype CLAP_Nsview is Void_Ptr;
   subtype CLAP_Xwnd   is Interfaces.C.unsigned_long;

   --  Represent a window reference.

   type Window_API_Index is (Cocoa_Idx, X11_Idx, Win32_Idx, Unknown_Idx);

   type Window_API (Which : Window_API_Index := Unknown_Idx) is
      record
         case Which is
            when Cocoa_Idx =>
               Cocoa : CLAP_Nsview := System.Null_Address;

            when X11_Idx =>
               X11   : CLAP_Xwnd := 0;

            when Win32_Idx =>
               Win32 : CLAP_Hwnd := System.Null_Address;

            when Unknown_Idx =>    -- for anything defined outside of CLAP
               Unknown : Void_Ptr := Null_Void_Ptr;
         end case;
      end record
     with Convention => C, Unchecked_Union;

   type Window_API_Access is access Window_API with Convention => C;

   type CLAP_Window is
      record
         API    : CLAP_Chars_Ptr := CLAP_Null_Ptr; --  one of CLAP_Window_API_XXX
         Handle : Window_API := (others => <>);
      end record
   with Convention => C;

   type CLAP_Window_Access is access CLAP_Window with Convention => C;

   --  Information to improve window resizing when initiated by the host or
   --  window manager.
   type CLAP_GUI_Resize_Hints is
      record
         Can_Resize_Horizontally : Bool := False;
         Can_Resize_Vertically   : Bool := False;

         --  if both horizontal and vertical resize are available, do we preserve the
         --  aspect ratio, and if so, what is the width x height aspect ratio to preserve.
         --  These flags are unused if can_resize_horizontally or vertically are false,
         --  and ratios are unused if preserve is false.
         Preserve_Aspect_Ratio : Bool := False;
         Aspect_Ratio_Width    : UInt32_t := 0;
         Aspect_Ratio_Height   : UInt32_t := 0;
      end record
     with Convention => C;

   type CLAP_GUI_Resize_Hints_Access is access CLAP_GUI_Resize_Hints
     with Convention => C;

   type Is_API_Supported_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               API         : CLAP_Chars_Ptr;
               Is_Floating : Bool)
               return Bool
     with Convention => C;
   --  Returns True if the requested GUI API is supported, either in floating (plugin-created)
   --  or non-floating (embedded) mode.
   --  [main-thread]

   type Get_Preferred_API_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               API         : out CLAP_Chars_Ptr;
               Is_Floating : out Bool)
               return  Bool
     with Convention => C;
   --  Returns True if the plugin has a preferred API.
   --  The host has no obligation to honor the plugin preference, this is just
   --  a hint.
   --  The Window_API_Access variable should be explicitly assigned as a pointer to
   --  one of the CLAP_Window_API constants defined above, not copied.
   --
   --  [main-thread]

   type Create_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               API         : CLAP_Chars_Ptr;
               Is_Floating : Bool)
               return Bool
     with Convention => C;
   --  Create and allocate all resources necessary for the GUI.
   --
   --  If Is_Floating is True, then the window will not be managed by the host.
   --  The plugin can set its window to stays above the parent window, see
   --  Set_Transient.
   --  API api may be null or blank for floating window.
   --
   --  If Is_Floating is False, then the plugin has to embbed its window into
   --  the parent window, see Set_Parent.
   --
   --  After this call, the GUI may not be visible yet; don't forget to call
   --  Show.
   --  [main-thread]

   type Destroy_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access)
     with Convention => C;
   --  Free all resources associated with the GUI.
   --  [main-thread]

   type Set_Scale_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Scale  : CLAP_Double)
               return Bool
     with Convention => C;
   --  Set the absolute GUI scaling factor, and override any OS info.
   --  Should not be used if the windowing api relies upon logical pixels.
   --
   --  If the plugin prefers to work out the scaling factor itself by querying the OS directly,
   --  then ignore the call.
   --
   --  Returns true if the scaling could be applied
   --  Returns false if the call was ignored, or the scaling could not be applied.
   --  [main-thread]

   type Get_Size_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Width  : out UInt32_t;
               Height : out UInt32_t)
               return Bool
     with Convention => C;
   --  Get the current size of the plugin UI.
   --  clap_plugin_GUI->create() must have been called prior to asking the size.
   --  [main-thread]

   type Can_Resize_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return Bool
     with Convention => C;
   --  Returns True if the window is resizeable (mouse drag).
   --  Only for embedded windows.
   --  [main-thread]

   type Get_Resize_Hints_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Hints  : CLAP_GUI_Resize_Hints_Access)
               return Bool
     with Convention => C;
   --  Returns True if the plugin can provide hints on how to resize the window.
   --  [main-thread]

   type Adjust_Size_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Width  : in out UInt32_t;
               Height : in out UInt32_t)
               return Bool
     with Convention => C;
   --  If the plugin GUI is resizable, then the plugin will calculate
   --  the closest usable size which fits in the given size.
   --  This method does not change the size.
   --
   --  Only for embedded windows.
   --  [main-thread]

   type Set_Size_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Width  : UInt32_t;
               Height : UInt32_t)
               return Bool
     with Convention => C;
   --  Sets the window size. Only for embedded windows.
   --  [main-thread]

   type Set_Parent_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Window : CLAP_Window_Access)
               return Bool
     with Convention => C;
   --  Embbeds the plugin window into the given window.
   --  [main-thread & !floating]

   type Set_Transient_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Window : CLAP_Window_Access)
               return Bool
     with Convention => C;
   --  Set the plugin floating window to stay above the given window.
   --  [main-thread & floating]

   type Suggest_Title_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access;
                Title  : CLAP_Chars_Ptr)
     with Convention => C;
   --  Suggests a window title. Only for floating windows.
   --  [main-thread & floating]

   type Show_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return Bool
     with Convention => C;
   --  Show the window.
   --  [main-thread]

   type Hide_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return Bool
     with Convention => C;
   --  Hide the window, this method does not free the resources, it just hides
   --  the window content. Yet it may be a good idea to stop painting timers.
   --  [main-thread]

   --  Size (Width, Height) is in pixels; the corresponding windowing system
   --  extension is responsible for defining if it is physical pixels or logical
   --  pixels.
   type CLAP_Plugin_GUI is
      record
         Is_API_Supported  : Is_API_Supported_Function  := null;
         Get_Preferred_API : Get_Preferred_API_Function := null;
         Create            : Create_Function            := null;
         Destroy           : Destroy_Function           := null;
         Set_Scale         : Set_Scale_Function         := null;
         Get_Size          : Get_Size_Function          := null;
         Can_Resize        : Can_Resize_Function        := null;
         Get_Resize_Hints  : Get_Resize_Hints_Function  := null;
         Adjust_Size       : Adjust_Size_Function       := null;
         Set_Size          : Set_Size_Function          := null;
         Set_Parent        : Set_Parent_Function        := null;
         Set_Transient     : Set_Transient_Function     := null;
         Suggest_Title     : Suggest_Title_Function     := null;
         Show              : Show_Function              := null;
         Hide              : Hide_Function              := null;
      end record
     with Convention => C;

   type CLAP_Plugin_GUI_Access is access CLAP_Plugin_GUI with Convention => C;

   type Resize_Hints_Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  The host should call Get_Resize_Hints again.
   --  [thread-safe]

   type Request_Resize_Function is access
     function (Host   : Hosts.CLAP_Host_Access;
               Width  : UInt32_t;
               Height : UInt32_t)
               return Bool
     with Convention => C;
   --  Request the host to resize the client area to Width, Height.
   --  Return True if the new size is accepted, False otherwise.
   --  The host doesn't have to call Set_Size.
   --
   --  Note: if not called from the main thread, then a return value simply
   --  means that the host acknowledged the request and will process it
   --  asynchronously. If the request then can't be satisfied then the host will
   --  call Set_Size to revert the operation.
   --
   --  [thread-safe] */

   type Request_Show_Function is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Request the host to show the plugin GUI.
   --  Return True on success, False otherwise.
   --  [thread-safe] */

   type Request_Hide_Function is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Request the host to hide the plugin GUI.
   --  Return true on success, false otherwise.
   --  [thread-safe] */

   type Closed_Function is access
     procedure (Host          : Hosts.CLAP_Host_Access;
                Was_Destroyed : Bool)
     with Convention => C;
   --  The floating window has been closed, or the connection to the GUI has
   --  been lost.
   --
   --  If Was_Destroyed is True, then the host must call CLAP_Plugin_GUI.Destroy
   --  to acknowledge the GUI destruction.
   --  [thread-safe]

   type CLAP_Host_GUI is
      record
         Resize_Hints_Changed : Resize_Hints_Changed_Function := null;
         Request_Resize       : Request_Resize_Function       := null;
         Request_Show         : Request_Show_Function         := null;
         Request_Hide         : Request_Hide_Function         := null;
         Closed               : Closed_Function               := null;
      end record
     with Convention => C;

   type CLAP_Host_GUI_Access is access all CLAP_Host_GUI with Convention => C;

end CfA.Extensions.GUIs;
