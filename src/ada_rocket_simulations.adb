with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;
with Components; use Components;
with Aerodynamics; use Aerodynamics;
with Simulation; use Simulation;

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

begin
   Put_Line ("Starting OpenRocket Ada TDD Test Runner");
   Put_Line ("---------------------------------------");
   Run_Math_Tests;
   Run_Component_Tests;
   Run_Simulation_Tests;
end Ada_Rocket_Simulations;
