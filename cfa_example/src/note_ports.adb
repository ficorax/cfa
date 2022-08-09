with Interfaces.C;

package body Note_Ports is

   use type Interfaces.C.size_t;

   --------------------------------
   --  Example_Note_Ports_Count  --
   --------------------------------

   function Example_Note_Ports_Count
     (Plugin : CLAP_Plugin_Access;
      Is_Input : Bool)
      return UInt32_t
   is
      pragma Unreferenced (Plugin, Is_Input);
   begin
      return 1;
   end Example_Note_Ports_Count;

   ------------------------------
   --  Example_Note_Ports_Get  --
   ------------------------------

   function Example_Note_Ports_Get
     (Plugin   : CLAP_Plugin_Access;
      Index    : UInt32_t;
      Is_Input : Bool;
      Info     : CLAP_Note_Port_Info_Access)
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

      Info.Supported_Dialects (CLAP) := True;
      Info.Supported_Dialects (MIDI_MPE) := True;
      Info.Supported_Dialects (MIDI2) := True;

      Info.Preferred_Dialect (CLAP) := True;

      return Bool'(True);
   end Example_Note_Ports_Get;

end Note_Ports;
