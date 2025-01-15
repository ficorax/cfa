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
--  State
--
--  State management
--
--  Plugins can implement this extension to save and restore both parameter
--  values and non-parameter state. This is used to persist a plugin's state
--  between project reloads, when duplicating and copying plugin instances, and
--  for host-side preset management.
--
--  If you need to know if the save/load operation is meant for duplicating a plugin
--  instance, for saving/loading a plugin preset or while saving/loading the project
--  then consider implementing Clap_Ext_State_Context in addition to Clap_Ext_State.

with CfA.Hosts;
with CfA.Plugins;
with CfA.Streams;

package CfA.Extensions.State is

   CLAP_Ext_State : constant Chars_Ptr :=
                      Interfaces.C.Strings.New_String ("clap.state");

   type Save_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Stream : CfA.Streams.CLAP_Output_Stream_Access)
               return Bool
     with Convention => C;
   --  Saves the plugin state into stream.
   --  Returns true if the state was correctly saved.
   --  [main-thread]

   type Load_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Stream : CfA.Streams.CLAP_Input_Stream_Access)
               return Bool
     with Convention => C;
   --  Loads the plugin state from stream.
   --  Returns true if the state was correctly restored.
   --  [main-thread]

   type CLAP_Plugin_State is
      record
         Save : Save_Function := null;
         Load : Load_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_State_Access is access CLAP_Plugin_State
     with Convention => C;

   type Mark_Dirty_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Tell the host that the plugin state has changed and should be saved again.
   --  If a parameter value changes, then it is implicit that the state is dirty.
   --  [main-thread]

   type CLAP_Host_State is
      record
         Mark_Dirty : Mark_Dirty_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_State_Access is access all CLAP_Host_State
     with Convention => C;

end CfA.Extensions.State;
