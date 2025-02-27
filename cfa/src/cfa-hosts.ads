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

with CfA.Version;

package CfA.Hosts is

   type CLAP_Host;
   type CLAP_Host_Access is access all CLAP_Host;

   type Get_Extension_Function is access
     function (Host         : CLAP_Host_Access;
               Extension_ID : CLAP_Chars_Ptr)
               return Void_Ptr
   with Convention => C;
   --  Query an extension.
   --  The returned pointer is owned by the host.
   --  It is forbidden to call it before Plugin.Init.
   --  You can call it within Plugin.Init call, and after.
    --  [thread-safe]

   type Request_Restart_Function is access
     procedure (Host : CLAP_Host_Access)
   with Convention => C;
   --  host to deactivate and then reactivate the plugin.
   --  The operation may be delayed by the host.
   --  [thread-safe]

   type Request_Process_Function is access
     procedure (Host : CLAP_Host_Access)
   with Convention => C;
   --  Request the host to activate and start processing the plugin.
   --  This is useful if you have external IO and need to wake up the plugin from "sleep".
   --  [thread-safe]

   type Request_Callback_Function is access
     procedure (Host : CLAP_Host_Access)
   with Convention => C;
   --  Request the host to schedule a call to Plugin.On_Main_Thread (Plugin) on the main thread.
   --  This callback should be called as soon as practicable, usually in the host application's next
   --  available main thread time slice. Typically callbacks occur within 33ms / 30hz.
   --  Despite this guidance, plugins should not make assumptions about the exactness of timing for
   --  a main thread callback, but hosts should endeavour to be prompt. For example, in high load
   --  situations the environment may starve the gui/main thread in favor of audio processing,
   --  leading to substantially longer latencies for the callback than the indicative times given
   --  here.
   --  [thread-safe]

   type CLAP_Host is
      record
         Version          : CfA.Version.CLAP_Version  := CfA.Version.CLAP_Version_Init;

         Host_Data        : Void_Ptr                  := Null_Void_Ptr;
         --  reserved pointer for the host

         --  name and version are mandatory.
         Name             : CLAP_Chars_Ptr                  := CLAP_Null_Ptr;
         -- eg: "Bitwig Studio"

         Vendor           : CLAP_Chars_Ptr                  := CLAP_Null_Ptr;
         -- eg: "Bitwig GmbH"

         URL              : CLAP_Chars_Ptr                  := CLAP_Null_Ptr;
         -- eg: "https://bitwig.com"

         Host_Version     : CLAP_Chars_Ptr                  := CLAP_Null_Ptr;
         --  eg           : "4.3", see CfA.Plugins for advice on how to format the version

         Get_Extension    : Get_Extension_Function    := null;
         Request_Restart  : Request_Restart_Function  := null;
         Request_Process  : Request_Process_Function  := null;
         Request_Callback : Request_Callback_Function := null;
      end record
     with Convention => C;

end CfA.Hosts;
