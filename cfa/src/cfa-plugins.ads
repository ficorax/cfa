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

with CfA.Processes;
with CfA.Version;

package CfA.Plugins is

   type Chars_Ptr_Array_Access is access constant Interfaces.C.Strings.chars_ptr_array;

   type CLAP_Plugin_Descriptor is
      record
         Version     : CfA.Version.CLAP_Version :=
                         CfA.Version.CLAP_Version_Init;

         --  Mandatory fields must be set and must not be blank.
         --  Otherwise the fields can be null or blank, though it is safer to
         --  make them blank.
         --
         --  Some indications regarding id and version
         --  - id is an arbritrary string which should be unique to your plugin,
         --    we encourage you to use a reverse URI eg: "com.u-he.diva"
         --  - version is an arbitrary string which describes a plugin,
         --    it is useful for the host to understand and be able to compare two different
         --    version strings, so here is a regex like expression which is likely to be
         --    understood by most hosts: MAJOR(.MINOR(.REVISION)?)?( (Alpha|Beta) XREV)?

         ID          : Chars_Ptr := Null_Ptr;
         --  eg: "com.u-he.diva", mandatory

         Name        : Chars_Ptr := Null_Ptr;
         --  eg: "Diva", mandatory

         Vendor      : Chars_Ptr := Null_Ptr;
         --  eg: "u-he"

         URL         : Chars_Ptr := Null_Ptr;
         --  eg: "https://u-he.com/products/diva/"

         Manual_URL  : Chars_Ptr := Null_Ptr;
         --  eg: "https://dl.u-he.com/manuals/plugins/diva/Diva-user-guide.pdf"

         Support_URL : Chars_Ptr := Null_Ptr;
         --  eg: "https://u-he.com/support/"

         Version_Str : Chars_Ptr := Null_Ptr;
         --  eg: "1.4.4"

         Description : Chars_Ptr := Null_Ptr;
         --  eg: "The spirit of analogue"

         --  Arbitrary list of keywords.
         --  They can be matched by the host indexer and used to classify
         --  the plugin.
         --  The array of pointers must be null terminated.
         --  For some standard features see plugin-features.h
         Features    : Chars_Ptr_Array_Access := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Descriptor_Access is access all CLAP_Plugin_Descriptor
       with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Plugin;
   type CLAP_Plugin_Access is access all CLAP_Plugin with Convention => C;

   type Init_Function is access
     function (P : CLAP_Plugin_Access) return Bool
     with Convention => C;
   --  Must be called after creating the plugin.
   --  If init returns false, the host must destroy the plugin instance.
   --  If init returns true, then the plugin is initialized and in the deactivated state.
   --  Unlike in `plugin-factory::create_plugin`, in init you have complete access to the host
   --  and host extensions, so clap related setup activities should be done here rather than in
   --  create_plugin.
   --  // [main-thread]

   type Destroy_Function is access
     procedure (P : CLAP_Plugin_Access)
     with Convention => C;
   --  Free the plugin and its resources.
   --  It is required to deactivate the plugin prior to this call.
   --  [main-thread & !active]

   type Activate_Function is access
     function (P                : CLAP_Plugin_Access;
               Sample_Rate      : CLAP_Double;
               Min_Frames_Count : UInt32_t;
               Max_Frames_Count : UInt32_t)
               return Bool
     with Convention => C;
   --  Activate and deactivate the plugin.
   --  In this call the plugin may allocate memory and prepare everything needed for the process
   --  call. The process's sample rate will be constant and process's frame count will included in
   --  the [min, max] range, which is bounded by [1, INT32_MAX].
   --  Once activated the latency and port configuration must remain constant, until deactivation.
   --  Returns true on success.
   --  [main-thread & !active]

   type Deactivate_Function is access
     procedure (P : CLAP_Plugin_Access)
     with Convention => C;
   --  Deactivate the plugin.
   --
   --  [main-thread & active_state]

   type Start_Processing_Function is access
     function (P : CLAP_Plugin_Access) return Bool
     with Convention => C;
   --  Call start processing before processing.
   --  Returns true on success.
   --  [audio-thread & active & !processing]

   type Stop_Processing_Function is access
     procedure (P : CLAP_Plugin_Access)
     with Convention => C;
   --  Call stop processing before sending the plugin to sleep.
   --  [audio-thread & active_state & processing_state]

   type Reset_Function is access
     procedure (P : CLAP_Plugin_Access)
     with Convention => C;
   --  - Clears all buffers, performs a full reset of the processing state
   --    (filters, oscillators, enveloppes, lfo, ...) and kills all voices.
   --  - The parameter's value remain unchanged.
   --  - Clap_Process.Steady_Time may jump backward.
   --
   --  [audio-thread & active_state]

   type Process_Function is access
     function (Pl : CLAP_Plugin_Access;
               Pr : CfA.Processes.CLAP_Process_Access)
               return CfA.Processes.CLAP_Process_Status
     with Convention => C;
   --  process audio, events, ...
   --  All the pointers coming from CLAP_Process and its nested attributes,
   --  are valid until Process returns.
   --  [audio-thread & active_state & processing_state]

   type Get_Extension_Function is access
     function (P  : CLAP_Plugin_Access;
               ID : Chars_Ptr)
               return System.Address
     with Convention => C;
   --  Query an extension.
   --  The returned pointer is owned by the plugin.
   --  It is forbidden to call it before Plugin.Init.
   --  You can call it within Plugin.Init call, and after.
   --  [thread-safe]

   type On_Main_Thread_Function is access
     procedure (P : CLAP_Plugin_Access)
     with Convention => C;
   --  Called by the host on the main thread in response to a previous call to:
   --    Host.Request_Callback (Host);
   --  [main-thread]

   type CLAP_Plugin is
      record
         Descriptor       : CLAP_Plugin_Descriptor_Access;
         Plugin_Data      : Void_Ptr := Null_Void_Ptr; -- reserved pointer for the plugin

         Init             : Init_Function;
         Destroy          : Destroy_Function;
         Activate         : Activate_Function;
         Deactivate       : Deactivate_Function;
         Start_Processing : Start_Processing_Function;
         Stop_Processing  : Stop_Processing_Function;
         Reset            : Reset_Function;
         Process          : Process_Function;
         Get_Extension    : Get_Extension_Function;
         On_Main_Thread   : On_Main_Thread_Function;
      end record
     with Convention => C;

end CfA.Plugins;
