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

----------------------------------------------------------------------------------------------------
--  This extension lets the plugin submit transport requests to the host.
--  The host has no obligation to execute these requests, so the interface may
--  be partially working.

with CfA.Fixed_Point;
with CfA.Hosts;

package CfA.Extensions.Draft.Transport_Control is

   CLAP_Ext_Transport_Control : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.transport-control.draft/0");

   type Request_Start_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Jumps back to the start point and starts the transport
   --  [main-thread]

   type Request_Stop_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Stops the transport, and jumps to the start point
   --  [main-thread]

   type Request_Continue_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  If not playing, starts the transport from its current position
   --  [main-thread]

   type Request_Pause_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  If playing, stops the transport at the current position
   --  [main-thread]

   type Request_Toggle_Play_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Equivalent to what "space bar" does with most DAWs
   --  [main-thread]

   type Request_Jump_Function is access
     procedure (Host     : Hosts.CLAP_Host_Access;
                Position : CfA.Fixed_Point.CLAP_Beattime)
     with Convention => C;
   --  Jumps the transport to the given position.
   --  Does not start the transport.
   --  [main-thread]

   type Request_Loop_Region_Function is access
     procedure (Host    : Hosts.CLAP_Host_Access;
                Start   : CfA.Fixed_Point.CLAP_Beattime;
                Length  : CfA.Fixed_Point.CLAP_Beattime)
     with Convention => C;
   --  Sets the loop region
   --  [main-thread]

   type Request_Toggle_Loop_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Toggles looping
   --  [main-thread]

   type Request_Enable_Loop_Function is access
     procedure (Host       : Hosts.CLAP_Host_Access;
                Is_Enabled : Bool)
     with Convention => C;
   --  Enables/Disables looping
   --  [main-thread]

   type Request_Record_Function is access
     procedure (Host         : Hosts.CLAP_Host_Access;
                Is_Recording : Bool)
     with Convention => C;
   --  Enables/Disables recording
   --  [main-thread]

   type Request_Toggle_Record_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Toggles recording
   --  [main-thread]

   type CLAP_Host_Transport_Control is
      record
         Request_Start         : Request_Start_Function := null;
         Request_Stop          : Request_Stop_Function := null;
         Request_Continue      : Request_Continue_Function := null;
         Request_Pause         : Request_Pause_Function := null;
         Request_Toggle_Play   : Request_Toggle_Play_Function := null;
         Request_Jump          : Request_Jump_Function := null;
         Request_Loop_Region   : Request_Loop_Region_Function := null;
         Request_Toggle_Loop   : Request_Toggle_Loop_Function := null;
         Request_Enable_Loop   : Request_Enable_Loop_Function := null;
         Request_Record        : Request_Record_Function := null;
         Request_Toggle_Record : Request_Toggle_Record_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Transport_Control_Access is access CLAP_Host_Transport_Control
     with Convention => C;

end CfA.Extensions.Draft.Transport_Control;
