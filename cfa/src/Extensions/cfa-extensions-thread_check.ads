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

package CfA.Extensions.Thread_Check is

   CLAP_Ext_Thread_Check : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.thread-check");

   --  This interface is useful to do runtime checks and make
   --  sure that the functions are called on the correct threads.
   --  It is highly recommended to implement this extension

   type Is_Main_Thread_Function is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Returns true if "this" thread is the main thread.
   --  [thread-safe]

   type Is_Audio_Thread_Funcion is access
     function (Host : Hosts.CLAP_Host_Access) return Bool
     with Convention => C;
   --  Returns true if "this" thread is one of the audio threads.
   --  [thread-safe]

   type CLAP_Host_Thread_Check is
      record
         Is_Main_Thread  : Is_Main_Thread_Function := null;
         Is_Audio_Thread : Is_Audio_Thread_Funcion := null;
      end record
     with Convention => C;

   type CLAP_Host_Thread_Check_Access is access all CLAP_Host_Thread_Check
     with Convention => C;

end CfA.Extensions.Thread_Check;
