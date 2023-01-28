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

with System;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;

package CfA is

   --  CLAP-specific types

   type Int8_t is new Interfaces.Integer_8;
   type Int16_t is new Interfaces.Integer_16;
   type Int32_t is new Interfaces.Integer_32;
   type Int64_t is new Interfaces.Integer_64;

   type UInt8_t is new Interfaces.Unsigned_8;
   type UInt16_t is new Interfaces.Unsigned_16;
   type UInt32_t is new Interfaces.Unsigned_32;
   type UInt64_t is new Interfaces.Unsigned_64;

   type Bool is new Boolean
     with Convention => C;

   type UInt8_Array is array (Natural range <>) of UInt8_t
     with Convention => C;

   type UInt8_Access is access UInt8_t
     with Convention => C;

   type UInt32_Array is array (Natural range <>) of UInt32_t
     with Convention => C;

   type UInt64_Access is access UInt64_t
     with Convention => C;

   type CLAP_Float is new Interfaces.C.C_float;
   type CLAP_Double is new Interfaces.C.double;

   subtype Char_Ptr is Interfaces.C.Strings.chars_ptr;

   Null_Ptr : constant Char_Ptr := Interfaces.C.Strings.Null_Ptr;

   type CLAP_ID is new UInt32_t;

   type CLAP_ID_Array is array (Interfaces.C.size_t range <>) of CLAP_ID
     with Convention => C;

   subtype Void_Ptr is System.Address;

   CLAP_Invalid_ID : constant CLAP_ID := CLAP_ID'Last;

   CLAP_Name_Size : constant := 256;
   --  String capacity for names that can be displayed to the user.

   CLAP_Path_Size : constant := 1024;
   --  String capacity for describing a path, like a parameter in a module
   --  hierarchy or path within a set of nested track groups.
   --
   --  This is not suited for describing a file path on the disk, as NTFS allows
   --  up to 32K long paths.

end CfA;
