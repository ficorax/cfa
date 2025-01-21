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

package CfA.Extensions.Event_Registry is

   use Interfaces.C.Strings;

   CLAP_Ext_Event_Registry : constant CLAP_Chars_Ptr :=
                               New_String ("clap.event-registry");

   type Query_Function is access
     function (Host       : Hosts.CLAP_Host_Access;
               Space_Name : CLAP_Chars_Ptr;
               Space_ID   : out UInt16_t)
               return Bool
     with Convention => C;
   --  Queries an event space id.
   --  The space id 0 is reserved for CLAP's core events.
   --  See CLAP_Core_Event_Space_ID.
   --
   --  Return False and sets Space_ID to UINT16_MAX if the space name is unknown
   --  to the host.
   --  [main-thread]

   type CLAP_Host_Event_Registry is
      record
         Query : Query_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Event_Registry_Access is access CLAP_Host_Event_Registry
     with Convention => C;

end CfA.Extensions.Event_Registry;
