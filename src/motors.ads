package Motors is

   -- A single data point on the thrust curve
   type Thrust_Data_Point is record
      Time   : Float;
      Thrust : Float; -- in Newtons
   end record;

   -- Array of thrust data points representing the motor's curve
   type Thrust_Curve_Type is array (Positive range <>) of Thrust_Data_Point;

   -- We'll limit the max curve points to simplify memory allocation for now
   Max_Thrust_Points : constant := 100;

   subtype Bounded_Thrust_Curve is Thrust_Curve_Type (1 .. Max_Thrust_Points);

   type Motor_Type is record
      Name          : String (1 .. 16);
      Name_Len      : Natural := 0;
      Diameter      : Float;
      Length        : Float;
      Total_Mass    : Float; -- Mass before ignition (kg)
      Prop_Mass     : Float; -- Mass of propellant (kg)
      Burn_Time     : Float; -- Total burn time
      Num_Points    : Natural := 0;
      Thrust_Curve  : Bounded_Thrust_Curve;
   end record;

   -- Interpolate thrust for a given time
   function Get_Thrust (Motor : Motor_Type; Time : Float) return Float;

   -- Get the mass of the motor at a given time (simple linear interpolation of propellant mass)
   function Get_Mass (Motor : Motor_Type; Time : Float) return Float;

end Motors;
