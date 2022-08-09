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
--  This extension let your plugin hook itself into the host
--  select/poll/epoll/kqueue reactor.
--  This is useful to handle asynchronous I/O on the main thread.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.POSIX_Fd_Support is

   CLAP_Ext_Posix_Fd_Support : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.posix-fd-support");

   --  IO events flags, they can be used to form a mask which describes:
   --  - which events you are interested in (register_fd/modify_fd)
   --  - which events happened (on_fd)
   type Posix_Fd_Flags_Index is
     (
      Read,
      Write,
      Error
     ) with Convention => C;

   pragma Warnings (Off);
   type CLAP_Posix_Fd_Flags is array (Posix_Fd_Flags_Index) of Bool
     with Convention => C,  Pack, Size => 32;
   pragma Warnings (On);

   type On_Fd_Funcion is access
     procedure (Plugin : Plugins.CLAP_Plugin_Access;
                Fd     : Integer;
                Flags  : CLAP_Posix_Fd_Flags)
     with Convention => C;
   --  This callback is "level-triggered".
   --  It means that a writable fd will continuously produce "on_fd()" events;
   --  don't forget using modify_fd() to remove the write notification once
   --  you're done writting.
   --
   --  [main-thread]

   type CLAP_Plugin_Posix_Fd_Support is
      record
         On_Fd : On_Fd_Funcion := null;
      end record
   with Convention => C;

   type CLAP_Plugin_Posix_Fd_Support_Access is access CLAP_Plugin_Posix_Fd_Support
     with Convention => C;

   type Register_Fd_Function is access
     function (Host  : Hosts.CLAP_Host_Access;
               Fd    : Integer;
               Flags : CLAP_Posix_Fd_Flags)
               return Bool
     with Convention => C;
   --  [main-thread]

   type Modify_Fd_Function is access
     function (Host  : Hosts.CLAP_Host_Access;
               Fd    : Integer;
               Flags : CLAP_Posix_Fd_Flags)
               return Bool
     with Convention => C;
   --  [main-thread]

   type Unregister_Fd_Funcion is access
     function (Host : Hosts.CLAP_Host_Access;
               Fd   : Integer)
               return Bool
     with Convention => C;
   --  [main-thread]

   type CLAP_Host_Posix_Fd_Support is
      record
         Register_Fd   : Register_Fd_Function := null;
         Modify_Fd     : Modify_Fd_Function := null;
         Unregister_Fd : Unregister_Fd_Funcion := null;
      end record
     with Convention => C;

   type CLAP_Host_Posix_Fd_Support_Access is access all CLAP_Host_Posix_Fd_Support
     with Convention => C;

end CfA.Extensions.POSIX_Fd_Support;
