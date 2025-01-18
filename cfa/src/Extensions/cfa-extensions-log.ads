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

with CfA.Hosts;

package CfA.Extensions.Log is

   CLAP_Ext_Log : constant Chars_Ptr :=
                    Interfaces.C.Strings.New_String ("clap.log");

   type CLAP_Log_Severity is
     (
      CLAP_Log_Debug,
      CLAP_Log_Info,
      CLAP_Log_Warning,
      CLAP_Log_Error,
      CLAP_Log_Fatal,

      --  These severities should be used to report misbehaviour.
      --  The plugin one can be used by a layer between the plugin and the host.
      CLAP_Log_Host_Misbehaving,
      CLAP_Log_Plugin_Misbehaving
     ) with Convention => C, Size => 32;

   type Log_Function is access
     procedure (Host     : Hosts.CLAP_Host_Access;
                Severity : CLAP_Log_Severity;
                Msg      : Chars_Ptr)
     with Convention => C;
   --  Log a message through the host.
   --  [thread-safe]

   type CLAP_Host_Log is
      record
         Log : Log_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Log_Access is access all CLAP_Host_Log with Convention => C;

end CfA.Extensions.Log;
