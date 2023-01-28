package CfA.Fixed_Point is

   --  We use fixed point representation of beat time and seconds time
   --  Usage:
   --    X : double := ...; -- in beats
   --    Y : CLAP_Beattime := Round (CLAP_Beattime_Factor * x);

   --  This will never change
   CLAP_Beattime_Factor : constant UInt64_t := Shift_Left (1, 31);
   CLAP_SecTime_Factor  : constant UInt64_t := Shift_Left (1, 31);

   subtype CLAP_Beattime is UInt64_t;
   subtype CLAP_Sectime  is UInt64_t;

end CfA.Fixed_Point;
