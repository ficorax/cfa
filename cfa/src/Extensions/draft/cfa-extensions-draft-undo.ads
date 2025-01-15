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
--  Undo
--
--  This extension enables the plugin to merge its undo history with the host.
--  This leads to a single undo history shared by the host and many plugins.
--
--  Calling Host.Undo or Host.Redo is equivalent to clicking undo/redo within the host's GUI.
--
--  If the plugin uses this interface then its undo and redo should be entirely delegated to
--  the host; clicking in the plugin's UI undo or redo is equivalent to clicking undo or redo in the
--  host's UI.
--
--  Some changes are long running changes, for example a mouse interaction will begin editing some
--  complex data and it may take multiple events and a long duration to complete the change.
--  In such case the plugin will call Host.Begin_Change to indicate the beginning of a long
--  running change and complete the change by calling Host.Change_Made.
--
--  The host may group changes together:
--  [---------------------------------]
--  ^-T0      ^-T1    ^-T2            ^-T3
--  Here a long running change C0 begin at T0.
--  A instantaneous change C1 at T1, and another one C2 at T2.
--  Then at T3 the long running change is completed.
--  The host will then create a single undo step that will merge all the changes into C0.
--
--  This leads to another important consideration: starting a long running change without
--  terminating is **VERY BAD**, because while a change is running it is impossible to call undo or
--  redo.
--
--  Rationale: multiple designs were considered and this one has the benefit of having a single undo
--  history. This simplifies the host implementation, leading to less bugs, a more robust design
--  and maybe an easier experience for the user because there's a single undo context versus one
--  for the host and one for each plugin instance.
--
--  This extension tries to make it as easy as possible for the plugin to hook into the host undo
--  and make it efficient when possible by using deltas. The plugin interfaces are all optional, and
--  the plugin can for a minimal implementation, just use the host interface and call
--  Host.Change_Made without providing a delta. This is enough for the host to know that it can
--  capture a plugin state for the undo step.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Undo is

   CLAP_Ext_Undo : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.undo/4");

   CLAP_Ext_Undo_Context : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.undo_context/4");

   CLAP_Ext_Undo_Delta : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.undo_delta/4");

   type CLAP_Undo_Delta_Properties is
      record
         Has_Delta             : Bool;
         --  If true, then the plugin will provide deltas in host->change_made().
         --  If false, then all clap_undo_delta_properties's attributes become irrelevant.

         Are_Deltas_Persistent : Bool;
         --  If true, then the deltas can be stored on disk and re-used in the future as
         --  long as the plugin is compatible with the given format_version.
         --
         --  If false, then format_version must be set to CLAP_INVALID_ID.

         Format_Version        : CLAP_ID;
         --  This represents the delta format version that the plugin is currently using.
         --  Use CLAP_INVALID_ID for invalid value.
      end record
     with Convention => C;

   type CLAP_Undo_Delta_Properties_Access is access all CLAP_Undo_Delta_Properties
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Get_Delta_Properties_Function is access
     procedure (Plugin     : Plugins.CLAP_Plugin_Access;
                Properties : CLAP_Undo_Delta_Properties_Access)
     with Convention => C;
   --  Asks the plugin the delta properties.
   --  [main-thread]

   type Can_Use_Delta_Format_Version_Function is access
     function (Plugin         : Plugins.CLAP_Plugin_Access;
               Format_Version : CLAP_ID) return Bool
     with Convention => C;
  --  Asks the plugin if it can apply a delta using the given format version.
  --  Returns true if it is possible.
  --  [main-thread]

   type Undo_Function is access
     function (Plugin         : Plugins.CLAP_Plugin_Access;
               Format_Version : CLAP_ID;
               Delta_Undo     : Void_Ptr;
               Delta_Size     : Interfaces.C.size_t) return Bool
     with Convention => C;
  --  Undo using the delta.
  --  Returns true on success.
   --
  --  [main-thread]

   type Redo_Function is access
     function (Plugin         : Plugins.CLAP_Plugin_Access;
               Format_Version : CLAP_ID;
               Delta_Undo     : Void_Ptr;
               Delta_Size     : Interfaces.C.size_t) return Bool
     with Convention => C;
  --  Redo using the delta.
  --  Returns true on success.
   --
  --  [main-thread]

   --  Use Clap_Ext_Undo_Delta.
   --  This is an optional interface, using deltas is an optimization versus making
   --  a state snapshot.
   type CLAP_Plugin_Undo_Delta is
      record
         Get_Delta_Properties         : Get_Delta_Properties_Function         := null;
         Can_Use_Delta_Format_Version : Can_Use_Delta_Format_Version_Function := null;
         Undo                         : Undo_Function                         := null;
         Redo                         : Redo_Function                         := null;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------
   --  Use Clap_Ext_Undo_Context.
   --  This is an optional interface, that the plugin can implement in order to kno about
   --  the current undo context.

   type Set_Can_Undo_Function is access
     procedure (Plugin   : Plugins.CLAP_Plugin_Access;
                Can_Undo : Bool)
     with Convention => C;
   type Set_Can_Redo_Function is access
     procedure (Plugin   : Plugins.CLAP_Plugin_Access;
                Can_Redo : Bool)
     with Convention => C;
   --  Indicate if it is currently possible to perform an undo or redo operation.
   --  [main-thread & plugin-subscribed-to-undo-context]

   type Set_Undo_Name_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access;
                Name   : Chars_Ptr)
     with Convention => C;
   type Set_Redo_Name_Function is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access;
                Name   : Chars_Ptr)
     with Convention => C;
   --  Sets the name of the next undo or redo step.
   --  name: null terminated string.
   --  [main-thread & plugin-subscribed-to-undo-context]

   --  This is an optional interface, that the plugin can implement in order to know about
   --  the current undo context.
   type CLAP_Plugin_Undo_Context is
      record
         Set_Can_Undo  : Set_Can_Undo_Function  := null;
         Set_Can_Redo  : Set_Can_Redo_Function  := null;
         Set_Undo_Name : Set_Undo_Name_Function := null;
         Set_Redo_Name : Set_Redo_Name_Function := null;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Begin_Change_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Begins a long running change.
   --  The plugin must not call this twice: there must be either a call to cancel_change() or
   --  change_made() before calling begin_change() again.
   --  [main-thread]

   type Cancel_Change_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Cancels a long running change.
   --  cancel_change() must not be called without a preceding begin_change().
   --  [main-thread]

   type Change_Made_Function is access
     procedure (Host           : Hosts.CLAP_Host_Access;
                Name           : Chars_Ptr;
                Delta_Undo     : Void_Ptr;
                Delta_Size     : Interfaces.C.size_t;
                Delta_Can_Undo : Bool)
     with Convention => C;
   --  Completes an undoable change.
   --  At the moment of this function call, Plugin_State.Save would include the current change.
   --
   --  name: mandatory null terminated string describing the change, this is displayed to the user
   --
   --  delta: optional, it is a binary blobs used to perform the undo and redo. When not available
   --  the host will save the plugin state and use State.Load to perform undo and redo.
   --  The plugin must be able to perform a redo operation using the delta, though the undo
   --  operation is only possible if delta_can_undo is true.
   --
   --  Note: the provided delta may be used for incremental state saving and crash recovery. The
   --  plugin can indicate a format version id and the validity lifetime for the binary blobs.
   --  The host can use these to verify the compatibility before applying the delta.
   --  If the plugin is unable to use a delta, a notification should be provided to the user and
   --  the crash recovery should perform a best effort job, at least restoring the latest saved
   --  state.
   --
   --  Special case: for objects with shared and synchronized state, changes shouldn't be reported
   --  as the host already knows about it.
   --  For example, plugin parameter changes shouldn't produce a call to change_made().
   --
   --  Note: if the plugin asked for this interface, then Host_State.Mark_Dirty will not create an
   --  implicit undo step.
   --
   --  Note: if the plugin did load a preset or did something that leads to a large delta,
   --  it may consider not producing a delta (pass null) and let the host make a state snapshot
   --  instead.
   --
   --  Note: if a plugin is producing a lot of changes within a small amount of time, the host
   --  may merge them into a single undo step.
   --
   --  [main-thread]

   type Request_Undo_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   type Request_Redo_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Asks the host to perform the next undo or redo step.
   --
   --  Note: this maybe a complex and asynchronous operation, which may complete after
   --  this function returns.
   --
   --  Note: the host may ignore this request if there is no undo/redo step to perform,
   --  or if the host is unable to perform undo/redo at the time (eg: a long running
   --  change is going on).
   --
   --  [main-thread]

   type Set_Wants_Context_Updates_Function is access
     procedure (Host          : Hosts.CLAP_Host_Access;
                Is_Subscribed : Bool)
     with Convention => C;
   --  Subscribes to or unsubscribes from undo context info.
   --
   --  This method helps reducing the number of calls the host has to perform when updating
   --  the undo context info. Consider a large project with 1000+ plugins, we don't want to
   --  call 1000+ times update, while the plugin may only need the context info if its GUI
   --  is shown and it wants to display undo/redo info.
   --
   --  Initial state is unsubscribed.
   --
   --  is_subscribed: set to true to receive context info
   --
   --  It is mandatory for the plugin to implement CLAP_EXT_UNDO_CONTEXT when using this method.
   --
   --  [main-thread]

   --  Use Clap_Ext_Undo.
   type CLAP_Host_Undo is
      record
         Begin_Change              : Begin_Change_Function              := null;
         Cancel_Change             : Cancel_Change_Function             := null;
         Change_Made               : Change_Made_Function               := null;
         Request_Undo              : Request_Undo_Function              := null;
         Request_Redo              : Request_Redo_Function              := null;
         Set_Wants_Context_Updates : Set_Wants_Context_Updates_Function := null;
      end record
     with Convention => C;

end CfA.Extensions.Draft.Undo;
