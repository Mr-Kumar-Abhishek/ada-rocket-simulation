with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;
with Components; use Components;
with Aerodynamics; use Aerodynamics;
with Simulation; use Simulation;
with Motors; use Motors;

procedure Ada_Rocket_Simulations is

   procedure Run_Math_Tests is
      V1 : constant Vector_3D := (1.0, 2.0, 3.0);
      V2 : constant Vector_3D := (4.0, 5.0, 6.0);
      V3 : Vector_3D;
   begin
      Put_Line ("Running Math Tests...");

      V3 := V1 + V2;
      pragma Assert (V3.X = 5.0 and V3.Y = 7.0 and V3.Z = 9.0, "Vector Addition failed");

      pragma Assert (Dot_Product (V1, V2) = 32.0, "Dot Product failed");

      V3 := 2.0 * V1;
      pragma Assert (V3.X = 2.0 and V3.Y = 4.0 and V3.Z = 6.0, "Scalar Multiplication failed");

      V3 := Cross_Product (V1, V2);
      pragma Assert (V3.X = -3.0 and V3.Y = 6.0 and V3.Z = -3.0, "Cross Product failed");

      Put_Line ("All Math Tests Passed!");
   end Run_Math_Tests;

   procedure Run_Component_Tests is
      Payload : aliased Mass_Object;
      Tube    : aliased Body_Tube;
      Nose    : aliased Nose_Cone;
   begin
      Put_Line ("Running Component Tests...");

      -- Initialize Payload
      Payload.Mass := 1.0;
      Payload.CG := 0.1;
      Payload.Position := 0.0;

      -- Initialize Tube
      Tube.Length := 1.0;
      Tube.Outer_Diameter := 0.1;
      Tube.Inner_Diameter := 0.09;
      Tube.Density := 1000.0; -- kg/m^3
      Tube.Position := 0.2;

      -- Initialize Nose Cone
      Nose.Length := 0.5;
      Nose.Base_Diameter := 0.1;
      Nose.Density := 500.0;
      Nose.Position := 0.0;

      -- Add Components
      Tube.Add_Child (Payload'Access);
      Nose.Add_Child (Tube'Access);

      -- Check Tube mass calculation
      pragma Assert (Tube.Get_Mass > 0.0, "Tube mass should be positive");
      
      -- Total Mass
      pragma Assert (Nose.Get_Total_Mass = Nose.Get_Mass + Tube.Get_Mass + Payload.Mass, "Total Mass calculation failed");

      -- Aerodynamics
      pragma Assert (Get_CN (Nose) = 2.0, "Nose Cone CN failed");
      pragma Assert (Get_CN (Tube) = 0.0, "Body Tube CN failed");
      
      -- Total CP calculation
      pragma Assert (Get_Total_CP (Nose) >= 0.0, "Total CP failed");

      -- Stability Margin
      pragma Assert (Get_Stability_Margin (Nose, Tube.Outer_Diameter) >= 0.0, "Stability Margin failed");

      Put_Line ("All Component & Aerodynamics Tests Passed!");
   end Run_Component_Tests;

   procedure Run_Simulation_Tests is
      Payload : aliased Mass_Object;
      Tube    : aliased Body_Tube;
      Flight_State : State := (Position => (0.0, 0.0, 0.0), Velocity => (0.0, 0.0, 0.0), Time => 0.0);
   begin
      Put_Line ("Running Simulation Tests...");
      
      Payload.Mass := 1.0;
      Tube.Length := 1.0;
      Tube.Outer_Diameter := 0.1;
      Tube.Inner_Diameter := 0.09;
      Tube.Density := 1000.0;
      Tube.Add_Child (Payload'Access);

      -- Step 1 second with enough thrust to hover
      -- Mass ~ 2.49 kg. Hover thrust = 2.49 * 9.81 = ~24.4 N
      Step (Flight_State, Tube, 24.4, 1.0);
      
      -- It shouldn't have fallen very far (Y velocity near 0)
      pragma Assert (abs (Flight_State.Velocity.Y) < 10.0, "Hover test failed");

      Put_Line ("All Simulation Tests Passed!");
   end Run_Simulation_Tests;

   procedure Run_Motor_Tests is
      Estes_C6 : Motor_Type;
      Thrust   : Float;
   begin
      Put_Line ("Running Motor Tests...");
      Estes_C6.Name := "Estes C6-5      ";
      Estes_C6.Name_Len := 10;
      Estes_C6.Burn_Time := 1.6;
      Estes_C6.Total_Mass := 0.025;
      Estes_C6.Prop_Mass := 0.012;
      Estes_C6.Num_Points := 3;
      Estes_C6.Thrust_Curve (1) := (Time => 0.0, Thrust => 0.0);
      Estes_C6.Thrust_Curve (2) := (Time => 0.2, Thrust => 14.0);
      Estes_C6.Thrust_Curve (3) := (Time => 1.6, Thrust => 4.0);
      
      -- Test Thrust Interpolation
      Thrust := Get_Thrust (Estes_C6, 0.1);
      pragma Assert (Thrust = 7.0, "Thrust interpolation failed at 0.1s");
      
      -- Test Mass
      pragma Assert (Get_Mass (Estes_C6, 0.8) = 0.019, "Mass interpolation failed at 0.8s");
      
      Put_Line ("All Motor Tests Passed!");
   end Run_Motor_Tests;

   procedure Run_Full_Flight_Test is
      Mount : aliased Engine_Mount;
      Nose  : aliased Nose_Cone;
      Estes_C6 : Motor_Type;
      Apogee : Float;
      Flight_Time : Float;
   begin
      Put_Line ("Running Full Flight Simulation Test...");
      
      -- Setup Motor
      Estes_C6.Name := "Estes C6-5      ";
      Estes_C6.Name_Len := 10;
      Estes_C6.Burn_Time := 1.6;
      Estes_C6.Total_Mass := 0.025;
      Estes_C6.Prop_Mass := 0.012;
      Estes_C6.Num_Points := 3;
      Estes_C6.Thrust_Curve (1) := (Time => 0.0, Thrust => 0.0);
      Estes_C6.Thrust_Curve (2) := (Time => 0.2, Thrust => 14.0);
      Estes_C6.Thrust_Curve (3) := (Time => 1.6, Thrust => 4.0);

      -- Setup Rocket
      Mount.Length := 0.5;
      Mount.Outer_Diameter := 0.03;
      Mount.Inner_Diameter := 0.025;
      Mount.Density := 500.0;
      Mount.Has_Motor := True;
      Mount.Motor := Estes_C6;

      Nose.Length := 0.2;
      Nose.Base_Diameter := 0.03;
      Nose.Density := 200.0;
      
      Nose.Add_Child (Mount'Access);

      -- Run flight and log to CSV
      Run_Flight (Rocket => Nose, Motor => Estes_C6, Dt => 0.01, Output_File => "flight_data.csv", Apogee => Apogee, Flight_Time => Flight_Time);

      pragma Assert (Apogee > 0.0, "Flight apogee must be strictly positive");
      pragma Assert (Flight_Time > 1.6, "Flight time should outlast motor burn time");

      Put_Line ("Full Flight Simulation finished. Data logged to flight_data.csv");
   end Run_Full_Flight_Test;

begin
   Put_Line ("Starting OpenRocket Ada TDD Test Runner");
   Put_Line ("---------------------------------------");
   Run_Math_Tests;
   Run_Component_Tests;
   Run_Simulation_Tests;
   Run_Motor_Tests;
   Run_Full_Flight_Test;
end Ada_Rocket_Simulations;
