with Ada.Text_IO;
with Data_Logger; use Data_Logger;

package body Simulation is

   procedure Deploy_Parachutes (This : in out Component'Class; Altitude : Float; Descending : Boolean) is
   begin
      if This in Parachute then
         if Descending and then Altitude <= Parachute(This).Deploy_Altitude and then not Parachute(This).Is_Deployed then
            Parachute(This).Is_Deployed := True;
            Ada.Text_IO.Put_Line ("Parachute Deployed at Altitude: " & Float'Image(Altitude));
         end if;
      end if;

      for Child of This.Children loop
         Deploy_Parachutes (Child.all, Altitude, Descending);
      end loop;
   end Deploy_Parachutes;

   procedure Step (Current : in out State;
                   Rocket  : in out Component'Class;
                   Thrust  : in Float;
                   Dt      : in Float)
   is
      Mass : constant Float := Rocket.Get_Total_Mass;
      Accel : Vector_3D := (0.0, 0.0, 0.0);
      Gravity : constant Float := -9.81;
      
      Air_Density : constant Float := 1.225;
      Cd_A        : Float := Aerodynamics.Get_Total_CDA (Rocket);
      Drag_Force  : Float := 0.0;
      Descending  : Boolean := Current.Velocity.Y < 0.0;
   begin
      -- Base minimal drag to avoid 0 drag
      if Cd_A = 0.0 then
         Cd_A := 0.005;
      end if;

      Deploy_Parachutes (Rocket, Current.Position.Y, Descending);

      if Mass > 0.0 then
         -- Calculate drag force (opposing velocity)
         if Current.Velocity.Y > 0.0 then
            Drag_Force := -0.5 * Air_Density * (Current.Velocity.Y ** 2) * Cd_A;
         elsif Current.Velocity.Y < 0.0 then
            Drag_Force := 0.5 * Air_Density * (Current.Velocity.Y ** 2) * Cd_A;
         end if;

         -- Upward acceleration = (Thrust + Drag) / Mass + Gravity
         Accel.Y := ((Thrust + Drag_Force) / Mass) + Gravity;
      end if;

      -- Euler integration
      Current.Velocity := Current.Velocity + (Dt * Accel);
      Current.Position := Current.Position + (Dt * Current.Velocity);
      Current.Time     := Current.Time + Dt;
   end Step;

   procedure Run_Flight (Rocket      : in out Component'Class;
                         Motor       : in Motor_Type;
                         Dt          : in Float;
                         Output_File : in String;
                         Apogee      : out Float;
                         Flight_Time : out Float)
   is
      Flight_State : State := (Position => (0.0, 0.0, 0.0), Velocity => (0.0, 0.0, 0.0), Time => 0.0);
      File         : Ada.Text_IO.File_Type;
      Current_Thrust : Float;
      Current_Mass   : Float;
      Max_Height     : Float := 0.0;
   begin
      Init_Log (File, Output_File);

      -- Run until we hit the ground
      loop
         Current_Thrust := Motors.Get_Thrust (Motor, Flight_State.Time);
         Current_Mass   := Rocket.Get_Total_Mass; -- Includes initial motor mass for now

         Log_State (File, Flight_State, Current_Thrust, Current_Mass);
         
         if Flight_State.Position.Y > Max_Height then
            Max_Height := Flight_State.Position.Y;
         end if;

         -- Stop if we hit the ground after launching (we give it 0.5s to clear the pad)
         exit when Flight_State.Position.Y <= 0.0 and then Flight_State.Time > 0.5;
         
         -- Hard stop at 120 seconds to prevent infinite loop
         exit when Flight_State.Time > 120.0;

         Step (Flight_State, Rocket, Current_Thrust, Dt);
      end loop;

      Close_Log (File);
      
      Apogee := Max_Height;
      Flight_Time := Flight_State.Time;
   end Run_Flight;

end Simulation;
