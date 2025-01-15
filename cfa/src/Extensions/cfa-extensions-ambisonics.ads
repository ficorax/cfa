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
--  This extension can be used to specify the channel mapping used by
--  the plugin.

with CfA.Hosts;
with CfA.Plugins;

package CfA.Extensions.Ambisonics is

   CLAP_Ext_Ambisonic : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.ambisonic/3");
   --  This extension can be used to specify the channel mapping used by the plugin.

   CLAP_Ext_Ambisonic_Compat : constant Chars_Ptr
     := Interfaces.C.Strings.New_String ("clap.ambisonic.draft/3");
   --  The latest draft is 100% compatible.
   --  This compat ID may be removed in 2026.

   CLAP_Port_Ambisonic : constant Chars_Ptr :=
                           Interfaces.C.Strings.New_String ("ambisonic");

   type CLAP_Ambisonic_Channel_Ordering is
   (
    CLAP_Ambisonic_Ordering_FuMa,
    --  FuMa channel ordering

    CLAP_Ambisonic_Ordering_ACN
   --  ACN channel ordering
   ) with Convention => C, Size => 32;

   type CLAP_Ambisonic_Normalization is
     (
      CLAP_Ambisonic_Normalization_MaxN,
      CLAP_Ambisonic_Normalization_SN3D,
      CLAP_Ambisonic_Normalization_N3D,
      CLAP_Ambisonic_Normalization_SN2D,
      CLAP_Ambisonic_Normalization_N2D
     ) with Convention => C, Size => 32;

   type CLAP_Ambisonic_Config is
      record
         Ordering      : CLAP_Ambisonic_Channel_Ordering;
         Normalization : CLAP_Ambisonic_Normalization;
      end record
     with Convention => C;

   type CLAP_Ambisonic_Config_Access is access CLAP_Ambisonic_Config
     with Convention => C;

   -----------------------------------------------------------------------------

   type Is_Config_Supported_Function is access
     function (Plugin : Plugins.CLAP_Plugin_Access;
               Config : CLAP_Ambisonic_Config_Access) return Bool
     with Convention => C;
   --  Returns true if the given configuration is supported.
   --  [main-thread]

   type Get_Config_Function is access
     function (Plugin     : Plugins.CLAP_Plugin_Access;
               Is_Input   : Bool;
               Port_Index : UInt32_t;
               Config     : CLAP_Ambisonic_Config_Access) return Bool
     with Convention => C;
   --  Returns true on success
   --
   --  Config_Id: the configuration id, see Clap_Plugin_Audio_Ports_Config.
   --  If config_id is Clap_Invalid_ID, then this function queries the current port info.
   --  [main-thread]

   type CLAP_Plugin_Ambisonic is
      record
         Is_Config_Supported : Is_Config_Supported_Function := null;
         Get_Config          : Get_Config_Function := null;
      end record
     with Convention => C;

   type CLAP_Plugin_Ambisonic_Access is access CLAP_Plugin_Ambisonic
     with Convention => C;

   -----------------------------------------------------------------------------

   type Changed_Function is access
     procedure (Host : Hosts.CLAP_Host_Access)
     with Convention => C;
   --  Informs the host that the info has changed.
   --  The info can only change when the plugin is de-activated.
   --  [main-thread]

   type CLAP_Host_Ambisonic is
      record
         Changed : Changed_Function := null;
      end record
     with Convention => C;

   type CLAP_Host_Ambisonic_Access is access CLAP_Host_Ambisonic
     with Convention => C;

end CfA.Extensions.Ambisonics;
