package body Motors is

   function Get_Thrust (Motor : Motor_Type; Time : Float) return Float is
      P1, P2 : Thrust_Data_Point;
      Ratio  : Float;
   begin
      if Time < 0.0 or else Time > Motor.Burn_Time or else Motor.Num_Points = 0 then
         return 0.0;
      end if;

      -- If time is exactly or past the last point
      if Time >= Motor.Thrust_Curve (Motor.Num_Points).Time then
         return Motor.Thrust_Curve (Motor.Num_Points).Thrust;
      end if;

      -- Find the two points to interpolate between
      for I in 1 .. Motor.Num_Points - 1 loop
         if Time >= Motor.Thrust_Curve (I).Time and then Time < Motor.Thrust_Curve (I + 1).Time then
            P1 := Motor.Thrust_Curve (I);
            P2 := Motor.Thrust_Curve (I + 1);
            
            -- Linear interpolation
            Ratio := (Time - P1.Time) / (P2.Time - P1.Time);
            return P1.Thrust + Ratio * (P2.Thrust - P1.Thrust);
         end if;
      end loop;

      return 0.0;
   end Get_Thrust;

   function Get_Mass (Motor : Motor_Type; Time : Float) return Float is
      Burn_Fraction : Float;
   begin
      if Time < 0.0 then
         return Motor.Total_Mass;
      elsif Time > Motor.Burn_Time then
         return Motor.Total_Mass - Motor.Prop_Mass;
      else
         Burn_Fraction := Time / Motor.Burn_Time;
         return Motor.Total_Mass - (Motor.Prop_Mass * Burn_Fraction);
      end if;
   end Get_Mass;

end Motors;
