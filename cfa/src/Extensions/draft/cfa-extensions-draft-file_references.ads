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
--  This extension provides a way for the host to know about files which are
--  used by the plugin, like a wavetable, a sample, ...
--
--  The host can then:
--  - collect and save
--  - search for missing files by using:
--    - filename
--    - hash
--    - file size
--  - be aware that some external file references are marked as dirty and need
--    to be saved.
--
--  Regarding the hashing algorithm, as of 2022 BLAKE3 seems to be the best
--  choice in regards to performances and robustness while also providing a very
--  small pure C library with permissive licensing.
--  For more info see https:--github.com/BLAKE3-team/BLAKE3
--
--  This extension only exposes one hashing algorithm on purpose.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.File_References is

   CLAP_Ext_File_Reference : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.file-reference.draft/0");

--  This describes a file currently used by the plugin
   type CLAP_File_Reference is
      record
         Resource_ID : CLAP_ID;

         Belongs_To_Plugin_Collection : Bool := False;
         --  Flag indicating that the plugin may be able to (re-)install a collection that provides
         --  this resource. DAWs can provide a user option to ignore or include this resource during
         --  "collect and save".

         Path_Capacity : Interfaces.C.size_t := 0;
         --  [in] the number of bytes reserved in path

         Path_Size     : Interfaces.C.size_t := 0;
         --  [out] the actual length of the path, can be bigger than
         --        Path_Capacity

         Path          : Char_Ptr := Null_Ptr;
         --  [in,out] absolute path to the file on the disk, must be null terminated, and
         --           may be truncated if the capacity is less than the size
      end record
     with Convention => C;

   type CLAP_File_Reference_Access is access CLAP_File_Reference
     with Convention => C;

   type Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return UInt32_t
     with Convention => C;
   --  Returns the number of file reference this plugin has
   --  [main-thread]

   type Get_Function is access
     function (Plugin         : Plugins.CLAP_Plugin_Access;
               Index          : UInt32_t;
               File_Reference : CLAP_File_Reference_Access)
               return Bool
     with Convention => C;
   --  Gets the file reference at index
   --  returns True on success
   --  [main-thread]

   type Get_Blake3_Digest_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               Resource_ID : CLAP_ID;
               Digest      : UInt8_Access)
               return Bool
     with Convention => C;
   --  This method can be called even if the file is missing.
   --  So the plugin is encouraged to store the digest in its state.
   --
   --  digest is an array of 32 bytes.
   --
   --  [main-thread]

   type Get_File_Size_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               Resource_ID : CLAP_ID;
               Size        : UInt64_Access)
               return Bool
     with Convention => C;
   --  This method can be called even if the file is missing.
   --  So the plugin is encouraged to store the file's size in its state.
   --
   --  [main-thread]

   type Update_Path_Function is access
     function (Plugin      : Plugins.CLAP_Plugin_Access;
               Resource_ID : CLAP_ID;
               Path        : Char_Ptr)
               return Bool
     with Convention => C;
   --  Updates the path to a file reference
   --  [main-thread]

   type Save_Resources_Funcion is access
     function (Plugin : Plugins.CLAP_Plugin_Access) return Bool
     with Convention => C;
   --  Request all pending changes to be flushed to disk (e.g. for destructive
   --  sample editor plugins), needed during "collect and save".
   --  [main-thread]

   type CLAP_Plugin_File_Reference is
      record
         Count             : Count_Function := null;
         Get               : Get_Function := null;
         Get_Blake3_Digest : Get_Blake3_Digest_Function := null;
         Get_File_Size     : Get_File_Size_Function := null;
         Update_Path       : Update_Path_Function := null;
         Save_Resources    : Save_Resources_Funcion := null;
      end record
     with Convention => C;

   type CLAP_Plugin_File_Reference_Access is access CLAP_Plugin_File_Reference
     with Convention => C;

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the file references have changed, the host should
   --  schedule a full rescan.
   --  [main-thread]

   type Set_Dirty_Funcion is access
     procedure (Host        : Hosts.CLAP_Host_Access;
                Resource_ID : CLAP_ID)
     with Convention => C;
   --  Informs the host that file contents have changed, a call to Save_Resources is needed.
   --  [main-thread]

   type CLAP_Host_File_Reference is
      record
         Changed : Changed_Function := null;
         Set_Dirty : Set_Dirty_Funcion := null;
      end record
     with Convention => C;

   type CLAP_Host_File_Reference_Access is access all CLAP_Host_File_Reference
     with Convention => C;

end CfA.Extensions.Draft.File_References;
