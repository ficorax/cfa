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
--  Preset Discovery API.
--
--  Preset Discovery enables a plug-in host to identify where presets are found, what
--  extensions they have, which plug-ins they apply to, and other metadata associated with the
--  presets so that they can be indexed and searched for quickly within the plug-in host's browser.
--
--  This has a number of advantages for the user:
--  - it allows them to browse for presets from one central location in a consistent way
--  - the user can browse for presets without having to commit to a particular plug-in first
--
--  The API works as follow to index presets and presets metadata:
--  1. CLAP_Plugin_Entry.Get_Factory (CLAP_Preset_Discovery_Factory_ID)
--  2. CLAP_Preset_Discovery_Factory.Create(...)
--  3. CLAP_Preset_Discovery_Provider.Init (only necessary the first time, declarations
--  can be cached)
--       `-> CLAP_Preset_Discovery_Indexer.Declare_Filetype
--       `-> CLAP_Preset_Discovery_Indexer.Declare_Location
--       `-> CLAP_Preset_Discovery_Indexer.Declare_Soundpack (optional)
--       `-> CLAP_Preset_Discovery_Indexer.Set_Invalidation_Watch_File (optional)
--  4. crawl the given locations and monitor file system changes
--       `-> CLAP_Preset_Discovery_Indexer.Get_Metadata for each presets files
--
--  Then to load a preset, use Extensions.Draft.Preset_Load
--  TODO: create a dedicated repo for other plugin abi preset-load extension.
--
--  The design of this API deliberately does not define a fixed set tags or categories. It is the
--  plug-in host's job to try to intelligently map the raw list of features that are found for a
--  preset and to process this list to generate something that makes sense for the host's tagging
--  and categorization system. The reason for this is to reduce the work for a plug-in developer
--  to add Preset Discovery support for their existing preset file format and not have to be
--  concerned with all the different hosts and how they want to receive the metadata.
--
--  VERY IMPORTANT:
--  - the whole indexing process has to be **fast**
--     - CLAP_Preset_Provider->get_Metadata has to be fast and avoid unnecessary operations
--  - the whole indexing process must not be interactive
--     - don't show dialogs, windows, ...

with CfA.Version;

package CfA.Factories.Draft.Preset_Discovery is

   --  Use it to retrieve const CLAP_Preset_Discovery_Factory from
   --  CLAP_Plugin_Entry.Get_Factory

   CLAP_Preset_Discovery_Factory_ID : constant Char_Ptr
     := Interfaces.C.Strings.New_String ("clap.preset-discovery-factory/draft-1");

   type CLAP_Preset_Discovery_Index is
     (
      CLAP_Preset_Discovery_Is_Factory_Content,
      --  This is for Factories or sound-pack presets.

      CLAP_Preset_Discovery_Is_User_Content,
      --  This is for user presets.

      CLAP_Preset_Discovery_Is_Demo_Content,
      --  This location is meant for demo presets, those are preset which may trigger
      --  some limitation in the plugin because they require additionnal features which the user
      --  needs to purchase or the content itself needs to be bought and is only available in
      --  demo mode.

      CLAP_Preset_Discovery_Is_Favorite
      --  This preset is a user's favorite
     );

   pragma Warnings (Off);
   type CLAP_Preset_Discovery_Flags is array (CLAP_Preset_Discovery_Index) of Boolean
     with Pack, Size => UInt32_t'Size;
   pragma Warnings (On);

   --  TODO: move CLAP_Timestamp, CLAP_Timestamp_Unknown and CLAP_Plugin_ID to parent files once we
   --  settle with preset discovery

   type CLAP_Timestamp is new UInt64_t;
   --  This type defines a timestamp: the number of seconds since UNIX EPOCH.
   --  See C's time_t time(time_t *).

   CLAP_Timestamp_Unknown : constant CLAP_Timestamp := 0;
   --  Value for unknown timestamp.

   --  Pair of plugin ABI and plugin identifier
   type CLAP_Plugin_ID is
      record
         ABI : Char_Ptr;
         --  The plugin ABI name, in lowercase.
         --  eg: "clap"

         ID  : Char_Ptr;
         --  The plugin ID, for example "com.u-he.Diva".
         --  If the ABI rely upon binary plugin ids, then they shall be hex encoded (lower case).
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Preset_Discovery_Metadata_Receiver;
   type CLAP_Preset_Discovery_Metadata_Receiver_Access is
     access all CLAP_Preset_Discovery_Metadata_Receiver
       with Convention => C;

   type On_Error_Function is access
     procedure (Receiver      : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Os_Error      : Int32_t;
                Error_Message : Char_Ptr)
     with Convention => C;
   --  If there is an error reading metadata from a file this should be called with an error
   --  message.
   --  Os_Error: the operating system error, if applicable. If not applicable set it to a non-error
   --  value, eg: 0 on unix and Windows.

   type Begin_Preset_Function is access
     function (Receiver : CLAP_Preset_Discovery_Metadata_Receiver_Access;
               Name     : Char_Ptr;
               Load_Key : Char_Ptr)
               return Bool
     with Convention => C;
   --  This must be called for every preset in the file and before any preset metadata is
   --  sent with the calls below.
   --
   --  If the preset file is a preset container then name and load_key are mandatory,
   --  otherwise they must be null.
   --
   --  The Load_Key is a machine friendly string used to load the preset inside the container via a
   --  the preset-load plug-in extension. The load_key can also just be the subpath if that's what
   --  the plugin wants but it could also be some other unique id like a database primary key or a
   --  binary offset. It's use is entirely up to the plug-in.
   --
   --  If the function returns False, the the provider must stop calling back into the receiver.

   type Add_Plugin_ID_Funciotn is access
     procedure (Receiver  : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Plugin_ID : CLAP_Plugin_ID)
     with Convention => C;
   --  Adds a plug-in id that this preset can be used with.

   type Set_Soundpack_ID_Function is access
     procedure (Receiver     : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Soundpack_ID : Interfaces.C.Strings.chars_ptr)
     with Convention => C;
   --  Sets the sound pack to which the preset belongs to.

   type Set_Flags_Function is access
     procedure (Receiver : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Flags    : CLAP_Preset_Discovery_Flags)
     with Convention => C;
   --  Sets the flags, see CLAP_Preset_Discovery_Flags.
   --  If unset, they are then inherited from the location.

   type Add_Creator_Function is access
     procedure (Receiver : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Creator  : Interfaces.C.Strings.chars_ptr)
     with Convention => C;
   --  Adds a creator name for the preset.

   type Set_Description_Function is access
     procedure (Receiver    : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Description : Interfaces.C.Strings.chars_ptr)
     with Convention => C;
   --  Sets a description of the preset.

   type Set_Timestamps_Function is access
     procedure (Receiver          : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Creation_Time     : CLAP_Timestamp;
                Modification_Time : CLAP_Timestamp)
     with Convention => C;
   --  Sets the creation time and last modification time of the preset.
   --  If one of the times isn't known, set it to CLAP_Timestamp_Unknown.
   --  If this function is not called, then the indexer may look at the file's creation and
   --  modification time.

   type Add_Feature_Function is access
     procedure (Receiver : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Feature  : Interfaces.C.Strings.chars_ptr);
   --  Adds a feature to the preset.
   --
   --  The feature string is arbitrary, it is the indexer's job to understand it and remap it to its
   --  internal categorization and tagging system.
   --
   --  However, the strings from Plugin_Features should be understood by the indexer and one of the
   --  plugin category could be provided to determine if the preset will result into
   --  an audio-effect, instrument, ...
   --
   --  Examples:
   --  kick, drum, tom, snare, clap, cymbal, bass, lead, metalic, hardsync, crossmod, acid,
   --  distorted, drone, pad, dirty, etc...

   type Add_Extra_Info_Function is access
     procedure (Receiver : CLAP_Preset_Discovery_Metadata_Receiver_Access;
                Key      : Interfaces.C.Strings.chars_ptr;
                Value    : Interfaces.C.Strings.chars_ptr);
   --  Adds extra information to the metadata.

   --  Receiver that receives the metadata for a single preset file.
   --  The host would define the various callbacks in this interface and the preset parser function
   --  would then call them.
   --
   --  This interface isn't thread-safe.
   type CLAP_Preset_Discovery_Metadata_Receiver is
      record
         Receiver_Data    : Void_Ptr;
         --  reserved pointer for the metadata receiver

         On_Error         : On_Error_Function;
         Begin_Preset     : Begin_Preset_Function;
         Add_Plugin_Id    : Add_Plugin_ID_Funciotn;
         Set_Soundpack_Id : Set_Soundpack_ID_Function;
         Set_Flags        : Set_Flags_Function;
         Add_Creator      : Add_Creator_Function;
         Set_Description  : Set_Description_Function;
         Set_Timestamps   : Set_Timestamps_Function;
         Add_Feature      : Add_Feature_Function;
         Add_Extra_Info   : Add_Extra_Info_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Preset_Discovery_Filetype is
      record
         Name           : Interfaces.C.Strings.chars_ptr;
         Description    : Interfaces.C.Strings.chars_ptr;

         File_Extension : Interfaces.C.Strings.chars_ptr;
         --  `.' isn't included in the string.
         --  If empty or null then every file should be matched.
      end record
     with Convention => C;

   type CLAP_Preset_Discovery_Filetype_Access is access all CLAP_Preset_Discovery_Filetype
     with Convention => C;

   --  Defines a place in which to search for presets
   type CLAP_Preset_Discovery_Location is
      record
         Flags : CLAP_Preset_Discovery_Flags;
         --  see CLAP_Preset_Discovery_Flags

         Name  : Interfaces.C.Strings.chars_ptr;
         --  name of this location

         URI   : Interfaces.C.Strings.chars_ptr;
         --  URI:
         --  - file:--  for pointing to a file or directory; directories are scanned recursively
         --    eg: file:--/home/abique/.u-he/Diva/Presets/Diva (on Linux)
         --    eg: file:--/C:/Users/abique/Documents/u-he/Diva.data/Presets/ (on Windows)
         --
         --  - plugin:--  for presets which are bundled within the plugin DSO.
         --    In that case, the uri must be exactly `plugin:--` and nothing more.
      end record
     with Convention => C;

   type CLAP_Preset_Discovery_Location_Access is access all CLAP_Preset_Discovery_Location
     with Convention => C;

   --  Describes an installed sound pack.
   type CLAP_Preset_Discovery_Soundpack is
      record
         Flags             : CLAP_Preset_Discovery_Flags;
         --  see CLAP_Preset_Discovery_Flags (64-bit!!! TODO)

         ID                : Interfaces.C.Strings.chars_ptr;
         --  sound pack identifier

         Name              : Interfaces.C.Strings.chars_ptr;
         --  name of this sound pack

         Description       : Interfaces.C.Strings.chars_ptr;
         --  reasonably short description of the sound pack

         Homepage_URL      : Interfaces.C.Strings.chars_ptr;
         --  url to the pack's homepage

         Vendor            : Interfaces.C.Strings.chars_ptr;
         --  sound pack's vendor

         Image_URI         : Interfaces.C.Strings.chars_ptr;
         --  may be an image on disk or from an http server

         Release_Timestamp : CLAP_Timestamp;
         --  release date, CLAP_Timestamp_Unknown if unavailable
      end record
     with Convention => C;

   type CLAP_Preset_Discovery_Soundpack_Access is access all CLAP_Preset_Discovery_Soundpack
     with Convention => C;

   --  Describes a preset provider
   type CLAP_Preset_Discovery_Provider_Descriptor is
      record
         Version : CfA.Version.CLAP_Version;
         --  initialized to default

         ID      : Interfaces.C.Strings.chars_ptr;
         --  see Plugins for advice on how to choose a good identifier

         Name    : Interfaces.C.Strings.chars_ptr;
         --  eg: "Diva's preset provider"

         Vendor  : Interfaces.C.Strings.chars_ptr;
         --  eg: u-he
      end record
     with Convention => C;

   type CLAP_Preset_Discovery_Provider_Descriptor_Access is
     access all CLAP_Preset_Discovery_Provider_Descriptor
       with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Preset_Discovery_Provider;
   type CLAP_Preset_Discovery_Provider_Access is access all CLAP_Preset_Discovery_Provider
     with Convention => C;

   type Init_Function is access
     function (Provider : CLAP_Preset_Discovery_Provider_Access)
               return Bool
     with Convention => C;
   --  Initialize the preset provider.
   --  It should declare all its locations, filetypes and sound packs.
   --  Returns False if initialization failed.

   type Destroy_Function is access
     procedure (Provider : CLAP_Preset_Discovery_Provider_Access)
     with Convention => C;
   --  Destroys the preset provider

   type Get_Metadata_Function is access
     function (Provider          : CLAP_Preset_Discovery_Provider_Access;
               URI               : Interfaces.C.Strings.chars_ptr;
               Metadata_Receiver : CLAP_Preset_Discovery_Metadata_Receiver)
               return Bool
     with Convention => C;
   --  reads metadata from the given file and passes them to the metadata receiver

   type Get_Provider_Extension_Function is access
     function (Provider     : CLAP_Preset_Discovery_Provider_Access;
               Extension_ID : Interfaces.C.Strings.chars_ptr)
               return Void_Ptr
     with convention => C;
   --  Query an extension.
   --  The returned pointer is owned by the provider.
   --  It is forbidden to call it before Provider.Init.
   --  You can call it within Provider.Init call, and after.

   --  This interface isn't thread-safe.
   type CLAP_Preset_Discovery_Provider is
      record
         Desc : CLAP_Preset_Discovery_Provider_Descriptor;

         Provider_Data : Void_Ptr;
         --  reserved pointer for the provider

         Init          : Init_Function;
         Destroy       : Destroy_Function;
         Get_Metadata  : Get_Metadata_Function;
         Get_Extension : Get_Provider_Extension_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Preset_Discovery_Indexer;
   type CLAP_Preset_Discovery_Indexer_Access is access all CLAP_Preset_Discovery_Indexer
     with Convention => C;

   type Declare_Filetype_Function is access
     function (Indexer  : CLAP_Preset_Discovery_Indexer_Access;
               Filetype : CLAP_Preset_Discovery_Filetype)
               return Bool
     with Convention => C;
   --  Declares a preset filetype.
   --  Don't callback into the provider during this call.
   --  Returns false if the filetype is invalid.

   type Declare_Location_Function is access
     function (Indexer  : CLAP_Preset_Discovery_Indexer_Access;
               Location : CLAP_Preset_Discovery_Location)
               return Bool
     with Convention => C;
   --  Declares a preset location.
   --  Don't callback into the provider during this call.
   --  Returns False if the location is invalid.

   type Declare_Soundpack_Function is access
     function (Indexer   : CLAP_Preset_Discovery_Indexer_Access;
               Soundpack : CLAP_Preset_Discovery_Soundpack)
               return Bool
     with Convention => C;
   --  Declares a sound pack.
   --  Don't callback into the provider during this call.
   --  Returns False if the sound pack is invalid.

   type Get_Indexer_Extension_Function is access
     function (Indexer      : CLAP_Preset_Discovery_Indexer_Access;
               Extension_ID : Interfaces.C.Strings.chars_ptr)
               return Void_Ptr
     with Convention => C;
   --  Query an extension.
   --  The returned pointer is owned by the indexer.
   --  It is forbidden to call it before provider->init().
   --  You can call it within provider->init() call, and after.

--  This interface isn't thread-safe
   type CLAP_Preset_Discovery_Indexer is
      record
         Version           : CfA.Version.CLAP_Version;
         --  initialized to default

         Name              : Interfaces.C.Strings.chars_ptr;
         --  eg: "Bitwig Studio"

         Vendor            : Interfaces.C.Strings.chars_ptr;
         --  eg: "Bitwig GmbH"

         URL               : Interfaces.C.Strings.chars_ptr;
         --  eg: "https:--bitwig.com"

         Version_Str       : Interfaces.C.Strings.chars_ptr;
         --  eg: "4.3", see Plugins for advice on how to format the version

         Indexer_Data      : Void_Ptr;
         --  reserved pointer for the indexer

         Declare_Filetype  : Declare_Filetype_Function;
         Declare_Location  : Declare_Location_Function;
         Declare_Soundpack : Declare_Soundpack_Function;
         Get_Extension     : Get_Indexer_Extension_Function;
      end record
     with Convention => C;

   -------------------------------------------------------------------------------------------------

   type CLAP_Preset_Discovery_Factory;
   type CLAP_Preset_Discovery_Factory_Access is access all CLAP_Preset_Discovery_Factory
     with Convention => C;

   type Count_Function is access
     function (Factory : CLAP_Preset_Discovery_Factory_Access)
               return UInt32_t
     with Convention => C;
   --  Get the number of preset providers available.
   --  [thread-safe]

   type Get_Descriptor_Function is access
     function (Factory : CLAP_Preset_Discovery_Factory_Access;
               Index   : UInt32_t)
               return CLAP_Preset_Discovery_Provider_Descriptor_Access
     with Convention => C;
   --  Retrieves a preset provider descriptor by its index.
   --  Returns null in case of error.
   --  The descriptor must not be freed.
   --  [thread-safe]

   type Create_Function is access
     function (Factory     : CLAP_Preset_Discovery_Factory_Access;
               Indexer     : CLAP_Preset_Discovery_Indexer;
               Provider_ID : Interfaces.C.Strings.chars_ptr)
               return CLAP_Preset_Discovery_Provider_Access
     with Convention => C;
   --  Create a preset provider by its id.
   --  The returned pointer must be freed by calling Preset_Provider.Destroy (Preset_Provider);
   --  The preset provider is not allowed to use the indexer callbacks in the create method.
   --  It is forbidden to call back into the indexer before the indexer calls Provider.Init.
   --  Returns null in case of error.
   --  [thread-safe]

   --  Every methods in this Factories must be thread-safe.
   --  It is encourraged to perform preset indexing in background threads, maybe even in background
   --  process.
   --
   --  The host may use clap_plugin_invalidation_factory to detect filesystem changes
   --  which may change the Factories's content.

   type CLAP_Preset_Discovery_Factory is
      record
         Count          : Count_Function;
         Get_Descriptor : Get_Descriptor_Function;
         Create         : Create_Function;
      end record
     with Convention => C;

end CfA.Factories.Draft.Preset_Discovery;
