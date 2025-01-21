--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2023 Marek Kuziel
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
--  Resource Directory
--
--  This extension provides a way for the plugin to store its resources as file in a directory
--  provided by the host and recover them later on.
--
--  The plugin **must** store relative path in its state toward resource directories.
--
--  Resource sharing:
--  - shared directory is shared among all plugin instances, hence mostly appropriate for read-only
--  content
--    -> suitable for read-only content
--  - exclusive directory is exclusive to the plugin instance
--    -> if the plugin, then its exclusive directory must be duplicated too
--    -> suitable for read-write content
--
--  Keeping the shared directory clean:
--  - to avoid clashes in the shared directory, plugins are encouraged to organize their files in
--    sub-folders, for example create one subdirectory using the vendor name
--  - don't use symbolic links or hard links which points outside of the directory
--
--  Resource life-time:
--  - exclusive folder content is managed by the plugin instance
--  - exclusive folder content is deleted when the plugin instance is removed from the project
--  - shared folder content isn't managed by the host, until all plugins using the shared directory
--    are removed from the project
--
--  Note for the host
--  - try to use the filesystem's copy-on-write feature when possible for reducing exclusive folder
--    space usage on duplication
--  - host can "garbage collect" the files in the shared folder using:
--      Clap_Plugin_Resource_Directory.Get_Files_Count
--      Clap_Plugin_Resource_Directory.Get_File_Path
--    but be **very** careful before deleting any resources

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Draft.Resource_Directory is

   CLAP_Ext_Resource_Directory : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.resource-directory.draft/1");

   -------------------------------------------------------------------------------------------------

   type Set_Directory_Function is access
     procedure (Plugin    : Plugins.CLAP_Plugin_Access;
                Path      : CLAP_Chars_Ptr;
                Is_Shared : Bool)
     with Convention => C;
   --  Sets the directory in which the plugin can save its resources.
   --  The directory remains valid until it is overriden or the plugin is destroyed.
   --  If Path is null or blank, it clears the directory location.
   --  path must be absolute.
   --  [main-thread]

   type Collect_Function is access
     procedure (Plugin        : Plugins.CLAP_Plugin_Access;
                All_Resources : Bool)
     with Convention => C;
   --  Asks the plugin to put its resources into the resources directory.
   --  It is not necessary to collect files which belongs to the plugin's
   --  factory content unless the param all is true.
   --  [main-thread]

   type Get_Files_Count_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access)
               return UInt32_t
     with Convention => C;
   --  Returns the number of files used by the plugin in the shared resource folder.
   --  [main-thread]

   type Get_File_Path_Function is access
     function (Plugin    : Plugins.CLAP_Plugin_Access;
               Index     : UInt32_t;
               Path      : Interfaces.C.Strings.chars_ptr;
               Path_Size : UInt32_t)
               return UInt32_t
     with Convention => C;
   --  Retrieves relative file path to the resources directory.
   --  @param Path writable memory to store the path
   --  @param Path_Size number of available bytes in path
   --  Returns the number of bytes in the path, or -1 on error
   --  [main-thread]

   type CLAP_Plugin_Resource_Directory is
      record
         Set_Directory   : Set_Directory_Function;
         Collect         : Collect_Function;
         Get_Files_Count : Get_Files_Count_Function;
         Get_File_Path   : Get_File_Path_Function;
      end record
     with Convention => C;

   type CLAP_Plugin_Resource_Directory_Access is access all CLAP_Plugin_Resource_Directory
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type Request_Directory_Function is access
     function (Host      : Hosts.CLAP_Host_Access;
               Is_Shared : Bool)
               return Bool
     with Convention => C;
   --  Request the host to setup a resource directory with the specified sharing.
   --  Returns True if the host will perform the request.
   --  [main-thread]

   type Release_Directory_Function is access
     procedure (Host      : Hosts.CLAP_Host_Access;
                Is_Shared : Bool)
     with Convention => C;
   --  Tell the host that the resource directory of the specified sharing is no longer required.
   --  If Is_Shared = False, then the host may delete the directory content.
   --  [main-thread]

   type CLAP_Host_Resource_Directory is
      record
         Request_Directory : Request_Directory_Function;
         Release_Directory : Release_Directory_Function;
      end record
     with Convention => C;

   type CLAP_Host_Resource_Directory_Access is access all CLAP_Host_Resource_Directory
     with Convention => C;

end CfA.Extensions.Draft.Resource_Directory;
