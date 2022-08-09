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

package CfA.Streams is

   type CLAP_Input_Stream;
   type CLAP_Input_Stream_Access is access CLAP_Input_Stream
     with Convention => C;

   type Read_Function is access
     function (Stream : CLAP_Input_Stream_Access;
               Buffer : Void_Ptr := System.Null_Address;
               Size   : UInt64_t)
               return Int64_t
     with Convention => C;
   --  returns the number of bytes read; 0 indicates end of file and -1 a read error

   type CLAP_Input_Stream is
      record
         Context : Void_Ptr := System.Null_Address;
         --  reserved pointer for the stream

         Read : Read_Function := null;
      end record
     with Convention => C;

   type CLAP_Output_Stream;
   type CLAP_Output_Stream_Access is access CLAP_Output_Stream
     with Convention => C;

   type Write_Function is access
     function (Stream : CLAP_Input_Stream_Access;
               Buffer : Void_Ptr := System.Null_Address;
               Size   : UInt64_t)
               return Int64_t
     with Convention => C;
   --  returns the number of bytes written; -1 on write error

   type CLAP_Output_Stream is
      record
         Context : Void_Ptr := System.Null_Address;
         --  reserved pointer for the stream

         Write : Write_Function := null;
      end record
     with Convention => C;

end CfA.Streams;
