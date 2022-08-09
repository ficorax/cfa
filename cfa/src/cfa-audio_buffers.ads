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

package CfA.Audio_Buffers is

   --  Sample code for reading a stereo buffer:
   --
   --  Is_Left_Constant : Bool := Buffer.Constant_Mask (0);
   --  Is_Right_Constant : Bool := Buffer.Constant_Mask (1);
   --
   --  for  I in 0 .. N -1 loop
   --     L : CLAP_Float := Data_32 (0, (if Is_Left_Constant then 0 else I);
   --     R : CLAP_Float := Data_32 (0, (if Is_Right_Constant then 0 else I)
   --  end loop;
   --
   --  Note: checking the constant mask is optional, and this implies that
   --  the buffer must be filled with the constant value.
   --  Rationale: if a buffer reader doesn't check the constant mask, then it may
   --  process garbage samples and in result, garbage samples may be transmitted
   --  to the audio interface with all the bad consequences it can have.
   --
   --  The constant mask is a hint.

   type Mask_Array is array (0 .. 63) of Boolean
     with Pack, Size => 64;

   type CLAP_Audio_Buffer is
      record
         Data_32 : Void_Ptr := System.Null_Address;  --  float  **data32;
         Data_64 : Void_Ptr := System.Null_Address;  --  double **data64;

         Channel_Count : UInt32_t := 0;

         Latency       : UInt32_t := 0;
         --  latency from/to the audio interface

         Constant_Mask : Mask_Array := (others => False);
      end record
     with Convention => C;

   type CLAP_Audio_Buffer_Access is access CLAP_Audio_Buffer;

   type CLAP_Audio_Buffer_Array is
     array (UInt32_t range <>) of aliased CLAP_Audio_Buffer
   with Convention => C;

   type CLAP_Audio_Buffer_Array_Access is
     access CLAP_Audio_Buffer_Array;

end CfA.Audio_Buffers;
