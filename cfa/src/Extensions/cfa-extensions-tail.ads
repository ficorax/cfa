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
with CfA.Plugins;

package CfA.Extensions.Tail is

   CLAP_Ext_Tail : constant CLAP_Chars_Ptr :=
                     Interfaces.C.Strings.New_String ("clap.tail");

   -------------------------------------------------------------------------------------------------

   type Get_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  Returns tail length in samples.
   --  Any value greater or equal to INT32_MAX implies infinite tail.
   --  [main-thread,audio-thread]

   type CLAP_Plugin_Tail is
      record
         Get : Get_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Tail_Access is access CLAP_Plugin_Tail
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Tell the host that the tail has changed.
   --  [audio-thread]

   type CLAP_Host_Tail is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Tail_Access is access CLAP_Host_Tail
     with Convention => C;

end CfA.Extensions.Tail;
