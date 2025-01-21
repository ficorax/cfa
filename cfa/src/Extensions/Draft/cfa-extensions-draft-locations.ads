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

----------------------------------------------------------------------------------------------------
--  This extension allows a host to tell the plugin more about its position
--  within a project or session.

with CfA.Colors;
with CfA.Plugins;

package CfA.Extensions.Draft.Locations is

   use type Interfaces.C.size_t;

   CLAP_Ext_Location : constant CLAP_Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.location/1");

   type CLAP_Location_Kind is
     (
      CLAP_Plugin_Location_Project,
      --  Represents a document/project/session.

      CLAP_Plugin_Location_Track_Group,
      --  Represents a group of tracks.
      --  It can contain track groups, tracks, and devices (post processing).
      --  The first device within a track group has the index of
      --  the last track or track group within this group + 1.

      CLAP_Plugin_Location_Track,
      --  Represents a single track.
      --  It contains devices (serial).

      CLAP_Plugin_Location_Device,
      --  Represents a single device.
      --  It can contain other nested device chains.

      CLAP_Plugin_Location_Nested_Device_Chain
      --  Represents a nested device chain (serial).
      --  Its parent must be a device.
      --  It contains other devices.
     ) with Convention => C, Size => 32;

   for CLAP_Location_Kind use
     (
      CLAP_Plugin_Location_Project             => 1,
      CLAP_Plugin_Location_Track_Group         => 2,
      CLAP_Plugin_Location_Track               => 3,
      CLAP_Plugin_Location_Device              => 4,
      CLAP_Plugin_Location_Nested_Device_Chain => 5
     );

   type Clap_Plugin_Location_Element is
      record
         Kind : CLAP_Location_Kind;
         --  Kind of the element, must be one of the CLAP_Plugin_Location_* values.

         Index : UInt32_t;
         --  Index within the parent element.
         --  Set to 0 if irrelevant.

         Id   : Interfaces.C.char_array (0 .. CLAP_Path_Size - 1);
         --  Internal ID of the element.
         --  This is not intended for display to the user,
         --  but rather to give the host a potential quick way for lookups.

         Name : Interfaces.C.char_array (0 .. CLAP_Name_Size - 1);
         --  User friendly name of the element.

         Color : Colors.CLAP_Color;
         --  Color for this element, should be CLAP_Color_Transparent if no color is
         --  used for this element.
      end record
     with Convention => C;

   type Clap_Plugin_Location_Element_Access is access all Clap_Plugin_Location_Element
     with Convention => C;

   type Set_Location_Function is access
     procedure (Plugin       : Plugins.CLAP_Plugin_Access;
                Path         : Clap_Plugin_Location_Element_Access;
                Num_Elements : UInt32_t)
     with Convention => C;
   --  Called by the host when the location of the plugin instance changes.
   --
   --  The last item in this array always refers to the device itself, and as
   --  such is expected to be of kind CLAP_Plugin_Location_Device.
   --  [main-thread]

   type CLAP_Plugin_Location is
      record
         Set_Location : Set_Location_Function;
      end record
     with Convention => C;

   type CLAP_Plugin_Location_Access is access all CLAP_Plugin_Location
     with Convention => C;

end CfA.Extensions.Draft.Locations;
