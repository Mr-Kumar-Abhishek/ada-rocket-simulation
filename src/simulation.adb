package body Simulation is

   procedure Step (Current : in out State;
                   Rocket  : in Component'Class;
                   Thrust  : in Float;
                   Dt      : in Float)
   is
      Mass : constant Float := Rocket.Get_Total_Mass;
      Accel : Vector_3D := (0.0, 0.0, 0.0);
      Gravity : constant Float := -9.81;
   begin
      if Mass > 0.0 then
         -- Upward acceleration = (Thrust / Mass) + Gravity
         Accel.Y := (Thrust / Mass) + Gravity;
         
         -- Drag could be added here based on Get_Total_CN but keeping it simple for 1D vertical
      end if;

      -- Euler integration
      Current.Velocity := Current.Velocity + (Dt * Accel);
      Current.Position := Current.Position + (Dt * Current.Velocity);
      Current.Time     := Current.Time + Dt;
   end Step;

end Simulation;
