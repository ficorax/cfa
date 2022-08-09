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

package CfA.Version is

   type CLAP_Version is
      record
         --  This is the major ABI and API design
         --  Version 0.X.Y Correspond To The Development Stage, API and ABI Are not Stable
         --  Version 1.X.Y correspont to the release stage, API and ABI are stable

         Major    : UInt32_t := 1;
         Minor    : UInt32_t := 1;
         Revision : UInt32_t := 1;
      end record
   with Convention => C;

   function CLAP_Version_Is_Compatible (V : CLAP_Version) return Bool is
     (Bool (V.Major >= 1));

   CLAP_Version_Init : constant CLAP_Version := (1, 1, 1);

end CfA.Version;
