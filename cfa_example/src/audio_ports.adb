with Interfaces.C;

package body Audio_Ports is

   use type Interfaces.C.size_t;

   ---------------------------------
   --  Example_Audio_Ports_Count  --
   ---------------------------------

   function Example_Audio_Ports_Count
     (Plugin   : CLAP_Plugin_Access;
      Is_Input : Bool)
      return UInt32_t
   is
      pragma Unreferenced (Plugin, Is_Input);
   begin
      --  We just declare 1 audio input and 1 audio output
      return 1;
   end Example_Audio_Ports_Count;

   -------------------------------
   --  Example_Audio_Ports_Get  --
   -------------------------------

   function Example_Audio_Ports_Get
     (Plugin   : CLAP_Plugin_Access;
      Index    : UInt32_t;
      Is_Input : Bool;
      Info     : CLAP_Audio_Port_Info_Access)
      return Bool
   is
      pragma Unreferenced (Plugin, Is_Input);

      Port_Name : constant Interfaces.C.char_array
        := Interfaces.C."&" ("My Port Name", Interfaces.C.nul);
   begin
      if Index > 0 then
         return Bool'(False);
      end if;

      Info.ID := 0;
      Info.Name (Info.Name'First .. Info.Name'First + Port_Name'Length - 1)
                 := Port_Name;
      Info.Channel_Count := 2;
      Info.Flags (Is_Main) := True;
      Info.Port_Type := CLAP_Port_Stereo;
      Info.In_Place_Pair := CLAP_Invalid_ID;
      return Bool'(True);
   end Example_Audio_Ports_Get;

end Audio_Ports;
