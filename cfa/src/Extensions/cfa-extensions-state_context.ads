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
--  This extension lets the host save and load the plugin state with different semantics depending
--  on the context.
--
--  Briefly, when loading a preset or duplicating a device, the plugin may want to partially load
--  the state and initialize certain things differently.
--
--  Save and Load operations may have a different context.
--  All three operations should be equivalent:
--  1. CLAP_Plugin_State_Context.Load (CLAP_Plugin_State.Save, CLAP_State_Context_For_Preset)
--  2. CLAP_Plugin_State.Load (CLAP_Plugin_State_Context.Save (CLAP_State_Context_For_Preset))
--  3. CLAP_Plugin_State_Context.Load
--         (CLAP_Plugin_State_Context.Save (CLAP_State_Context_For_Preset),
--          CLAP_State_Context_For_Preset)
--
--  If the plugin implements CLAP_Ext_State_Context then it is mandatory to also implement
--  CLAP_Ext_State.

with CfA.Plugins;
with CfA.Streams;

package CfA.Extensions.State_Context is

   CLAP_Ext_State_Context : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.state-context.draft/1");

   type CLAP_Plugin_State_Context_Type is
   (
    CLAP_STATE_CONTEXT_FOR_DUPLICATE,
    --  suitable for duplicating a plugin instance

    CLAP_STATE_CONTEXT_FOR_PRESET
    --  suitable for loading a state Chars_Ptrset
   ) with Convention => C, Size => 32;

   type Save_Function is access
     function (Plugin       : Plugins.CLAP_Plugin_Access;
               Stream       : Streams.CLAP_Output_Stream_Access;
               Context_Type : CLAP_Plugin_State_Context_Type)
               return Bool
     with Convention => C;
   --  Saves the plugin state into stream, according to Context_Type.
   --  Returns True if the state was correctly saved.
   --
   --  Note that the result may be loaded by both CLAP_Plugin_State.Load and
   --  CLAP_Plugin_State_Context.Load.
   --  [main-thread]

   type Load_Function is access
     function (Plugin       : Plugins.CLAP_Plugin_Access;
               Stream       : Streams.CLAP_Input_Stream_Access;
               Context_Type : CLAP_Plugin_State_Context_Type)
               return Bool
     with Convention => C;
   --  Loads the plugin state from stream, according to Context_Type.
   --  Returns True if the state was correctly restored.
   --
   --  Note that the state may have been saved by CLAP_Plugin_State.Save or
   --  CLAP_Plugin_State_Context.Save with a different context_type.
   --  [main-thread]

   type CLAP_Plugin_State_Context is
      record
         Save : Save_Function;
         Load : Load_Function;
      end record
     with Convention => C;

end CfA.Extensions.State_Context;
