with Ada.Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Data_Logger; use Data_Logger;
with Math; use Math;
with Aerodynamics;

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
      Mass        : constant Float := Rocket.Get_Total_Mass;
      MOI         : constant Float := Rocket.Get_Total_MOI;
      CG          : constant Float := Rocket.Get_Total_CG;
      Max_Dia     : constant Float := Rocket.Get_Max_Diameter;
      CP          : constant Float := Aerodynamics.Get_Total_CP (Rocket, Max_Dia);
      CNa         : constant Float := Aerodynamics.Get_Total_CN (Rocket, Max_Dia);
      Cd_A        : Float := Aerodynamics.Get_Total_CDA (Rocket);

      Gravity     : constant Float := -9.81;
      Air_Density : constant Float := 1.225;
      Wind        : constant Vector_3D := (5.0, 0.0, 0.0); -- 5 m/s crosswind

      Local_Y     : constant Vector_3D := (0.0, 1.0, 0.0); -- Rocket longitudinal axis
      Rocket_Dir  : constant Vector_3D := Rotate (Local_Y, Current.Orientation);

      Air_Vel     : constant Vector_3D := Current.Velocity - Wind;
      Air_Speed   : constant Float := Magnitude (Air_Vel);
      
      Alpha       : Float := 0.0;
      Force_Tot   : Vector_3D := (0.0, Mass * Gravity, 0.0);
      Moment_Tot  : Vector_3D := (0.0, 0.0, 0.0);
      
      Drag_Force  : Vector_3D := (0.0, 0.0, 0.0);
      Normal_Force: Vector_3D := (0.0, 0.0, 0.0);
      
      Q_dot       : Quaternion;
      W_Quat      : Quaternion;
   begin
      if Cd_A = 0.0 then
         Cd_A := 0.005;
      end if;

      Deploy_Parachutes (Rocket, Current.Position.Y, Current.Velocity.Y < 0.0);

      if Mass > 0.0 then
         -- 1. Thrust
         Force_Tot := Force_Tot + (Thrust * Rocket_Dir);
         
         if Air_Speed > 0.1 then
            -- 2. Aerodynamics (Drag & Normal Force)
            -- Angle of attack (radians)
            declare
               Dot_Val : Float := Dot_Product (Air_Vel, Rocket_Dir) / Air_Speed;
            begin
               if Dot_Val > 1.0 then Dot_Val := 1.0; end if;
               if Dot_Val < -1.0 then Dot_Val := -1.0; end if;
               Alpha := Arccos (Dot_Val);
            end;
            
            -- Drag Force (opposes air velocity)
            Drag_Force := (-0.5 * Air_Density * (Air_Speed**2) * Cd_A) * Normalize(Air_Vel);
            Force_Tot := Force_Tot + Drag_Force;
            
            -- Normal Force & Restoring Moment (Weathercocking)
            if Alpha > 0.001 and Alpha < 3.14 then
               declare
                  -- Direction of restoring moment (perpendicular to both)
                  Moment_Dir : constant Vector_3D := Normalize (Cross_Product (Rocket_Dir, Air_Vel));
                  
                  -- A_ref
                  A_ref : constant Float := 3.14159 * ((Max_Dia / 2.0)**2);
                  
                  -- Mag = 0.5 * Rho * V^2 * A_ref * CNa * Alpha
                  N_Mag : constant Float := 0.5 * Air_Density * (Air_Speed**2) * A_ref * CNa * Alpha;
                  
                  -- Moment = Normal Force * Distance (CP - CG)
                  M_Mag : constant Float := N_Mag * (CP - CG);
                  
                  -- Damping moment (heuristic: resists angular velocity)
                  Damping : constant Vector_3D := -0.1 * MOI * Current.Angular_Velocity;
               begin
                  -- The moment rotates the rocket's nose towards the relative wind.
                  -- Cross(Rocket_Dir, Air_Vel) gives the correct axis to rotate around.
                  Moment_Tot := (M_Mag * Moment_Dir) + Damping;
               end;
            end if;
         end if;
         
         -- Prevent wild tumbling if CP/CG is extreme or math blows up
         if Magnitude (Moment_Tot) > 1000.0 then
            Moment_Tot := 1000.0 * Normalize(Moment_Tot);
         end if;
      end if;

      -- 3. Integration
      -- Linear
      Current.Velocity := Current.Velocity + ((Force_Tot / Mass) * Dt);
      Current.Position := Current.Position + (Current.Velocity * Dt);
      
      -- Angular
      Current.Angular_Velocity := Current.Angular_Velocity + ((Moment_Tot / MOI) * Dt);
      
      -- Quaternion Integration: Q_new = Q + 0.5 * Q * W * dt
      W_Quat := (W => 0.0, X => Current.Angular_Velocity.X, Y => Current.Angular_Velocity.Y, Z => Current.Angular_Velocity.Z);
      Q_dot  := Current.Orientation * W_Quat;
      Q_dot  := Q_dot * 0.5;
      
      Current.Orientation.W := Current.Orientation.W + Q_dot.W * Dt;
      Current.Orientation.X := Current.Orientation.X + Q_dot.X * Dt;
      Current.Orientation.Y := Current.Orientation.Y + Q_dot.Y * Dt;
      Current.Orientation.Z := Current.Orientation.Z + Q_dot.Z * Dt;
      
      Current.Orientation := Normalize (Current.Orientation);
      Current.Time := Current.Time + Dt;
   end Step;

   procedure Run_Flight (Rocket      : in out Component'Class;
                         Motor       : in Motor_Type;
                         Dt          : in Float;
                         Output_File : in String;
                         Apogee      : out Float;
                         Flight_Time : out Float)
   is
      Flight_State : State := (Position         => (0.0, 0.0, 0.0),
                               Velocity         => (0.0, 0.0, 0.0),
                               Orientation      => Identity_Quaternion,
                               Angular_Velocity => (0.0, 0.0, 0.0),
                               Time             => 0.0);
      File         : Ada.Text_IO.File_Type;
      Current_Thrust : Float;
      Current_Mass   : Float;
      Max_Height     : Float := 0.0;
   begin
      Init_Log (File, Output_File);

      loop
         Current_Thrust := Motors.Get_Thrust (Motor, Flight_State.Time);
         Current_Mass   := Rocket.Get_Total_Mass;

         Log_State (File, Flight_State, Current_Thrust, Current_Mass);
         
         if Flight_State.Position.Y > Max_Height then
            Max_Height := Flight_State.Position.Y;
         end if;

         -- Stop if we hit the ground after launching
         exit when Flight_State.Position.Y <= 0.0 and then Flight_State.Time > 0.5;
         
         -- Hard stop at 120 seconds
         exit when Flight_State.Time > 120.0;

         Step (Flight_State, Rocket, Current_Thrust, Dt);
         
         -- For the first 0.5 seconds on the launch rod, zero out X/Z velocity and rotation
         if Flight_State.Time <= 0.5 then
             Flight_State.Velocity.X := 0.0;
             Flight_State.Velocity.Z := 0.0;
             Flight_State.Position.X := 0.0;
             Flight_State.Position.Z := 0.0;
             Flight_State.Angular_Velocity := (0.0, 0.0, 0.0);
             Flight_State.Orientation := Identity_Quaternion;
         end if;
      end loop;

      Close_Log (File);
      
      Apogee := Max_Height;
      Flight_Time := Flight_State.Time;
   end Run_Flight;

end Simulation;
