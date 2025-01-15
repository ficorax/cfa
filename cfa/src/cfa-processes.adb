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

with System.Address_To_Access_Conversions;

with CfA.Audio_Buffers;

package body CfA.Processes is

   --------------------------
   --  Get_Audio_Input_32  --
   --------------------------

   function Get_Audio_Input_32 (Process : CLAP_Process_Access;
                                Index   : UInt32_t)
                                return Void_Ptr
   is
      type Local_Audio_Buffer is
        new Audio_Buffers.CLAP_Audio_Buffer_Array (0 .. Process.all.Audio_Inputs_Count - 1)
        with Convention => C;

      package Convert_Audio_Buffer_Array is
        new System.Address_To_Access_Conversions (Local_Audio_Buffer);

      Audio_Port_Array :  constant Convert_Audio_Buffer_Array.Object_Pointer :=
                           Convert_Audio_Buffer_Array.To_Pointer (Process.all.Audio_Inputs);
   begin
      return Audio_Port_Array.all (Index).Data_32;
   end Get_Audio_Input_32;

   --------------------------
   --  Get_Audio_Input_64  --
   --------------------------

   function Get_Audio_Input_64 (Process : CLAP_Process_Access;
                                Index   : UInt32_t)
                                return Void_Ptr
   is
      type Local_Audio_Buffer is
        new Audio_Buffers.CLAP_Audio_Buffer_Array (0 .. Process.all.Audio_Inputs_Count - 1)
        with Convention => C;

      package Convert_Audio_Buffer_Array is
        new System.Address_To_Access_Conversions (Local_Audio_Buffer);

      Audio_Port_Array :  constant Convert_Audio_Buffer_Array.Object_Pointer :=
                           Convert_Audio_Buffer_Array.To_Pointer (Process.all.Audio_Inputs);
   begin
      return Audio_Port_Array.all (Index).Data_64;
   end Get_Audio_Input_64;

   ---------------------------
   --  Get_Audio_Output_32  --
   ---------------------------

   function Get_Audio_Output_32 (Process : CLAP_Process_Access;
                                 Index   : UInt32_t)
                                 return Void_Ptr
   is
      type Local_Audio_Buffer is
        new Audio_Buffers.CLAP_Audio_Buffer_Array (0 .. Process.all.Audio_Outputs_Count - 1)
        with Convention => C;

      package Convert_Audio_Buffer_Array is
        new System.Address_To_Access_Conversions (Local_Audio_Buffer);

      Audio_Port_Array :  constant Convert_Audio_Buffer_Array.Object_Pointer :=
                           Convert_Audio_Buffer_Array.To_Pointer (Process.all.Audio_Outputs);
   begin
      return Audio_Port_Array.all (Index).Data_32;
   end Get_Audio_Output_32;

   ---------------------------
   --  Get_Audio_Output_64  --
   ---------------------------

   function Get_Audio_Output_64 (Process : CLAP_Process_Access;
                                 Index   : UInt32_t)
                                 return Void_Ptr
   is
      type Local_Audio_Buffer is
        new Audio_Buffers.CLAP_Audio_Buffer_Array (0 .. Process.all.Audio_Outputs_Count - 1)
        with Convention => C;

      package Convert_Audio_Buffer_Array is
        new System.Address_To_Access_Conversions (Local_Audio_Buffer);

      Audio_Port_Array :  constant Convert_Audio_Buffer_Array.Object_Pointer :=
                           Convert_Audio_Buffer_Array.To_Pointer (Process.all.Audio_Inputs);
   begin
      return Audio_Port_Array.all (Index).Data_64;
   end Get_Audio_Output_64;

end CfA.Processes;
