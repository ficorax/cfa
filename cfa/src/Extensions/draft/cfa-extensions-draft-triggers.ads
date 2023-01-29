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
--  Trigger events
--
--  This extension enables the plugin to expose a set of triggers to the host.
--
--  Some examples for triggers:
--  - trigger an envelope which is independent of the notes
--  - trigger a sample-and-hold unit (maybe even per-voice)
--
--  ------------------------------------------------------------------------------------------------
--  Given that this extension is still draft, it'll use the event-registry and its own event
--  namespace until we stabilize it.

with CfA.Events;
with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Triggers is

   CLAP_Ext_Triggers : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.triggers.draft/0");

   type CLAP_Trigger_Info_Flag_Index is
     (
      --  Does this trigger support per note automations?
      CLAP_Trigger_Is_Automatable_Per_Note_Id,

      --  Does this trigger support per key automations?
      CLAP_Trigger_Is_Automatable_Per_Key,

      --  Does this trigger support per channel automations?
      CLAP_Trigger_Is_Automatable_Per_Channel,

      --  Does this trigger support per port automations?
      CLAP_Trigger_Is_Automatable_Per_Port
     );

   pragma Warnings (Off);
   type CLAP_Trigger_Info_Flags is array (CLAP_Trigger_Info_Flag_Index) of Boolean
     with Pack, Size => UInt32_t'Size;
   pragma Warnings (On);

   CLAP_Events_Trigger : constant UInt16_t := 0;

   type CLAP_Event_Trigger is
      record
         Header : Events.CLAP_Event_Header;

         --  target trigger
         Trigger_ID : CLAP_ID;  --  CLAP_Trigger_Info.Id
         cookie     : Void_Ptr; --  CLAP_Trigger_Info.Cookie

         --  target a specific note_id, port, key and channel, -1 for global
         Node_ID    : Int32_t;
         Port_Index : Int16_t;
         Channel    : Int16_t;
         Key        : Int16_t;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------
   --  This describes a trigger

   use type Interfaces.C.size_t;

   type Clap_Trigger_Info is
      record
         ID    : CLAP_ID;
         --  stable trigger identifier, it must never change.

         Flags : CLAP_Trigger_Info_Flags;

         Cookie : Void_Ptr;
         --  displayable name

         Name  : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         --  displayable name

         Module : Interfaces.C.char_array (0 .. CLAP_Path_Size - 1);
         --  the module path containing the trigger, eg:"sequencers/seq1"
         --  '/' will be used as a separator to show a tree like structure.
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return UInt32_t
     with Convention => C;
   --  Returns the number of triggers.
   --  [main-thread]

   type Get_Info_Function is access
     function (Plugin       :     Plugins.CLAP_Plugin_Access;
               Index        :     UInt32_t;
               Trigger_Info : out Clap_Trigger_Info)
               return Bool
     with Convention => C;
   --  Copies the trigger's info to trigger_info and returns true on success.
   --  Returns True on success.
   --  [main-thread]

   type CLAP_Plugin_Triggers is
      record
         Count    : Count_Function;
         Get_Info : Get_Info_Function;
      end record
     with Convention => C;

   type CLAP_Trigger_Rescan_Index is
     (
      CLAP_Trigger_Rescan_Info,
      --  The trigger info did change, use this flag for:
      --  - name change
      --  - module change
      --  New info takes effect immediately.

      CLAP_TRIGGER_RESCAN_ALL
      --  Invalidates everything the host knows about triggers.
      --  It can only be used while the plugin is deactivated.
      --  If the plugin is activated use CLAP_Host,Restart and delay any change until the host calls
      --  CLAP_Plugin.Deactivate.
      --
      --  You must use this Flag if:
      --  - some triggers were added or removed.
      --  - some triggers had critical changes:
      --    - Is_Per_Note (Flag)
      --    - Is_Per_Key (Flag)
      --    - Is_Per_Channel (Flag)
      --    - Is_Per_Port (Flag)
      --    - cookie
     );

   pragma Warnings (Off);
   type CLAP_Trigger_Rescan_Flags is array (CLAP_Trigger_Rescan_Index) of Boolean
     with Pack, Size => UInt32_t'Size;
   pragma Warnings (On);

   type CLAP_Trigger_Clear_Index is
     (
      CLAP_Trigger_Clear_All,
      --  Clears all possible references to a trigger

      --  Clears all automations to a trigger
      CLAP_Trigger_Clear_Automations
     );

   pragma Warnings (Off);
   type CLAP_Trigger_Clear_Flags is array (CLAP_Trigger_Clear_Index) of Boolean
     with Pack, Size => UInt32_t'Size;
   pragma Warnings (On);

   type Rescan_Function is access
     procedure (Host  : Hosts.CLAP_Host_Access;
                Flags : CLAP_Trigger_Rescan_Flags)
     with Convention => C;
   --  Rescan the full list of triggers according to the Flags.
   --  [main-thread]

   type Clear_Function is access
     procedure (Host       : Hosts.CLAP_Host_Access;
                Trigger_ID : CLAP_ID;
                Flags      : CLAP_Trigger_Clear_Flags)
     with Convention => C;
   --  Clears references to a trigger.
   --  [main-thread]

   type CLAP_Host_Triggers is
      record
         Rescan : Rescan_Function;
         Clear  : Clear_Function;
      end record
     with Convention => C;

end CfA.Extensions.Draft.Triggers;
