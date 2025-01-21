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

with CfA.Streams;
with CfA.Universal_Plugin_ID;
with CfA.Version;

package CfA.Draft.Plugin_State_Converter is

   type CLAP_Plugin_State_Converter_Descriptor is
      record
         Version       : CfA.Version.CLAP_Version;

         Src_Plugin_Id : CfA.Universal_Plugin_ID.CLAP_Universal_Plugin_ID;
         Dst_Plugin_Id : CfA.Universal_Plugin_ID.CLAP_Universal_Plugin_ID;

         Id            : CLAP_Chars_Ptr;    --  eg: "com.u-he.diva-converter", mandatory
         Name          : CLAP_Chars_Ptr;    --  eg: "Diva Converter", mandatory
         Vendor        : CLAP_Chars_Ptr;    --  eg: "u-he"
         Version_Char  : CLAP_Chars_Ptr;    --  eg: 1.1.5
         Description   : CLAP_Chars_Ptr;    --  eg: "Official state converter for u-he Diva."
      end record
     with Convention => C;

   type CLAP_Plugin_State_Converter_Descriptor_Access is
     access all CLAP_Plugin_State_Converter_Descriptor;

   --  This interface provides a mechanism for the host to convert a plugin state and its automation
   --  points to a new plugin.
   --
   --  This is useful to convert from one plugin ABI to another one.
   --  This is also useful to offer an upgrade path: from EQ version 1 to EQ version 2.
   --  This can also be used to convert the state of a plugin that isn't maintained anymore into
   --  another plugin that would be similar.

   type CLAP_Plugin_State_Converter;

   type CLAP_Plugin_State_Converter_Access is access all CLAP_Plugin_State_Converter;

   type Destroy_Function is access
     procedure (Converter : CLAP_Plugin_State_Converter_Access)
   with Convention => C;
   --  Destroy the converter.

   type Convert_State_Function is access
     function (Converter         : CLAP_Plugin_State_Converter_Access;
               Src               : CfA.Streams.CLAP_Input_Stream_Access;
               Dst               : CfA.Streams.CLAP_Output_Stream_Access;
               Error_Buffer      : CLAP_Chars_Ptr;
               Error_Buffer_Size : Interfaces.C.size_t) return Bool
   with Convention => C;
   --  Converts the input state to a state usable by the destination plugin.
   --
   --  error_buffer is a place holder of error_buffer_size bytes for storing a null-terminated
   --  error message in case of failure, which can be displayed to the user.
   --
   --  Returns true on success.
   --  [thread-safe]

   type Convert_Normalized_Value_Function is access
     function (Converter            : CLAP_Plugin_State_Converter_Access;
               Src_Param_Id         : CLAP_ID;
               Src_Normalized_Value : Interfaces.C.double;
               Dst_Param_Id         : out CLAP_ID;
               Dst_Normalized_Value : out Interfaces.C.double) return Bool
   with Convention => C;
   --  Converts a normalized value.
   --  Returns true on success.
   --  [thread-safe]

   type Convert_Plain_Value_Function is access
     function (Converter       : CLAP_Plugin_State_Converter_Access;
               Src_Param_Id    : CLAP_ID;
               Src_Plain_Value : Interfaces.C.double;
               Dst_Param_Id    : out CLAP_ID;
               Dst_Plain_Value : out Interfaces.C.double) return Bool
     with Convention => C;
   --  Converts a plain value.
   --  Returns true on success.
   --  [thread-safe]

   type CLAP_Plugin_State_Converter is
      record
         Desc                     : CLAP_Plugin_State_Converter_Descriptor_Access;
         Converter_Data           : Void_Ptr;

         Destroy                  : Destroy_Function;
         Convert_State            : Convert_State_Function;
         Convert_Normalized_Value : Convert_Normalized_Value_Function;
         Convert_Plain_Value      : Convert_Plain_Value_Function;
      end record
   with Convention => C;

   ----------------------------------------------------------------------------

   CLAP_Plugin_State_Converter_Factory_Id : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.plugin-state-converter-factory/1");
   --  Factory identifier

   type CLAP_Plugin_State_Converter_Factory;

   type CLAP_Plugin_State_Converter_Factory_Access is
     access all CLAP_Plugin_State_Converter_Factory;

   type Count_Function is access
     function (Factory : CLAP_Plugin_State_Converter_Factory_Access) return UInt32_t
     with Convention => C;
   --  Get the number of converters.
   --  [thread-safe]

   type Get_Descriptor_Function is access
     function (Factory : CLAP_Plugin_State_Converter_Factory_Access;
               Index   : UInt32_t) return CLAP_Plugin_State_Converter_Descriptor_Access
     with Convention => C;
   --  Retrieves a plugin state converter descriptor by its index.
   --  Returns null in case of error.
   --  The descriptor must not be freed.
   --  [thread-safe]

   type Create_Function is access
     function (Factory      : CLAP_Plugin_State_Converter_Factory_Access;
               Converter_ID : CLAP_Chars_Ptr) return CLAP_Plugin_State_Converter_Access
     with Convention => C;
   --  Create a plugin state converter by its converter_id.
   --  The returned pointer must be freed by calling converter->destroy(converter);
   --  Returns null in case of error.
   --  [thread-safe]

   --  List all the plugin state converters available in the current DSO.
   type Clap_Plugin_State_Converter_Factory is
      record
         Count          : Count_Function;
         Get_Descriptor : Get_Descriptor_Function;
         Create         : Create_Function;
      end record
   with Convention => C;

end CfA.Draft.Plugin_State_Converter;
