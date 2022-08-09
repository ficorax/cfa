with System;
with System.Address_To_Access_Conversions;

with CfA.Events; use CfA.Events;

with Types;

package body Process is

   use Types;

   -------------------------------------------------------------------------------------------------

   procedure My_Plugin_Process_Event (Plug   : Example_Plugin_Access;
                                      Header : CLAP_Event_Header_Access);

   -------------------------------------------------------------------------------------------------

   -----------------------
   --  Example_Process  --
   -----------------------

   function Example_Process
     (Plugin  : CLAP_Plugin_Access;
      Process : CLAP_Process_Access)
      return CLAP_Process_Status
   is
      Plug          : aliased Example_Plugin with Address => Plugin.Plugin_Data, Import;

      Nframes       : constant UInt32_t := Process.Frames_Count;
      Nev           : constant UInt32_t := Process.In_Events.Size (Process.In_Events);
      Ev_Index      : UInt32_t := 0;
      Next_Ev_Frame : UInt32_t := (if Nev > 0 then 0 else Nframes);

      type Buffer is array (0 .. Nframes - 1) of CLAP_Float
        with Convention => C;

      type Buffer_Access is access all Buffer;

      type Local_Buffer is array (0 .. 1) of Buffer_Access
        with Convention => C;

      package AB_Converter is
        new System.Address_To_Access_Conversions (Local_Buffer);

      In_Buffer    : constant AB_Converter.Object_Pointer :=
                       AB_Converter.To_Pointer (Get_Audio_Input_32 (Process, 0));

      Out_Buffer   : constant AB_Converter.Object_Pointer :=
                       AB_Converter.To_Pointer (Get_Audio_Output_32 (Process, 0));

      procedure Process_Range (Process : CLAP_Process_Access;
                               Offset  : UInt32_t;
                               Count   : UInt32_t);

      procedure Process_Range (Process : CLAP_Process_Access;
                               Offset  : UInt32_t;
                               Count   : UInt32_t)
      is
         pragma Unreferenced (Process);
      begin
         --  process every samples until the next event
         for K in Offset .. Count - 1 loop

            declare
               --  fetch input samples
               In_L : constant CLAP_Float := In_Buffer (0) (K);
               In_R : constant CLAP_Float := In_Buffer (1) (K);

               --  TODO: process samples, here we simply swap left and right
               --  channels

               Out_L : constant CLAP_Float := In_R;
               Out_R : constant CLAP_Float := In_L;
            begin
               --  store output samples
               Out_Buffer (0)(K) := Out_L;
               Out_Buffer (1)(K) := Out_R;
            end;
         end loop;
      end Process_Range;

   begin
      declare
         I : UInt32_t := 0;
         Num_Frames_To_Process : UInt32_t := 0;
      begin
         loop
            exit when I >= Nframes;

            --  handle every events that happrens at the frame "I"
            In_Loop :
            while Ev_Index < Nev and Next_Ev_Frame = I loop
               declare
                  Hdr : constant CLAP_Event_Header_Access :=
                          Process.In_Events.Get (Process.In_Events, Ev_Index);
               begin
                  if Hdr.Time /= I then
                     Next_Ev_Frame := Hdr.Time;
                     exit In_Loop;
                  end if;

                  My_Plugin_Process_Event (Plug'Unchecked_Access, Hdr);
                  Ev_Index := Ev_Index + 1;

                  if Ev_Index = Nev then
                     --  we reached the end of the event list
                     Next_Ev_Frame := Nframes;
                     exit In_Loop;
                  end if;
               end;
            end loop In_Loop;

            Num_Frames_To_Process := Process.Frames_Count - I;

            Process_Range (Process, I, Num_Frames_To_Process);

            I := I + 1;

         end loop;

      end;
      return CLAP_Process_Continue;
   end Example_Process;

   -------------------------------
   --  My_Plugin_Process_Event  --
   -------------------------------

   pragma Warnings (Off);
   procedure My_Plugin_Process_Event (Plug   : Example_Plugin_Access;
                                      Header : CLAP_Event_Header_Access)
   is
      pragma Unreferenced (Plug);
   begin
      if Header.Space_ID = CLAP_Core_Event_Space_ID then
         case Header.Event_Type is
            when Note_On =>
               declare
                  Event : CLAP_Event_Note
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle note on
               end;

            when Note_Off =>
               declare
                  Event : CLAP_Event_Note
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle note off
               end;

            when Note_Choke =>
               declare
                  Event : CLAP_Event_Note
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle note choke
               end;

            when Note_End =>
               declare
                  Event : CLAP_Event_Note
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle note end
               end;

            when Note_Expression =>
               declare
                  Event : CLAP_Event_Note_Expression
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle note expression
               end;

            when Param_Value =>
               declare
                  Event : CLAP_Event_Param_Value
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle parameter change
               end;

            when Param_Mod =>
               declare
                  Event : CLAP_Event_Param_Mod
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle parameter modulation
               end;

            when Transport =>
               declare
                  Event : CLAP_Event_Transport
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle transport event
               end;

            when MIDI =>
               declare
                  Event : CLAP_Event_MIDI
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle MIDI event
               end;

            when MIDI_SysEX =>
               declare
                  Event : CLAP_Event_MIDI_SysEX
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle MIDI SysEx event
               end;

            when MIDI2 =>
               declare
                  Event : CLAP_Event_MIDI2
                    with Address => Header'Address, Import, Volatile;
               begin
                  null;
                  --  TODO: handle MIDI2 event
               end;

            when others =>
               null;
         end case;
      end if;

      null;

   end My_Plugin_Process_Event;
   pragma Warnings (On);

   --------------------------------
   --  Example_Start_Processing  --
   --------------------------------

   function Example_Start_Processing (Plugin : CLAP_Plugin_Access)
                                        return Bool
   is
      pragma Unreferenced (Plugin);
   begin
      return Bool'(True);
   end Example_Start_Processing;

   -------------------------------
   --  Example_Stop_Processing  --
   -------------------------------

   procedure Example_Stop_Processing (Plugin : CLAP_Plugin_Access) is null;

end Process;
