--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2022 Marek Kuziel
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
with CfA.Plugins;

package CfA.Extensions.Timer_Support is

   CLAP_Ext_Timer_Support : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.timer-support");

   type On_Timer_Function is access
     procedure (Plugin   : Plugins.CLAP_Plugin_Access;
                Timer_ID : CLAP_ID)
     with Convention => C;
   --  [main-thread]

   type CLAP_Plugin_Timer_Support is
      record
         On_Timer : On_Timer_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Timer_Support_Access is access CLAP_Plugin_Timer_Support
     with Convention => C;

   type Register_Timer_Function is access
     function (Host      : Hosts.CLAP_Host_Access;
               Period_Ms : UInt32_t;
               Timer_ID  : out CLAP_ID)
               return Bool
     with Convention => C;
   --  Registers a periodic timer.
   --  The host may adjust the period if it is under a certain threshold.
   --  30 Hz should be allowed.
   --  [main-thread]

   type Unregister_Timer_Function is access
     function (Host     : Hosts.CLAP_Host_Access;
               Timer_ID : CLAP_ID)
               return Bool
     with Convention => C;
   --  [main-thread]

   type CLAP_Host_Timer_Support is
      record
         Register_Timer   : Register_Timer_Function := null;
         Unregister_Timer : Unregister_Timer_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Timer_Support_Access is access all CLAP_Host_Timer_Support
     with Convention => C;

end CfA.Extensions.Timer_Support;
