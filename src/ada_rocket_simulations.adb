with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;
with Components; use Components;

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

      -- Add Payload to Tube
      Tube.Add_Child (Payload'Access);

      -- Check Tube mass calculation
      pragma Assert (Tube.Get_Mass > 0.0, "Tube mass should be positive");
      
      -- Total Mass = Tube.Mass + Payload.Mass
      pragma Assert (Tube.Get_Total_Mass = Tube.Get_Mass + 1.0, "Total Mass calculation failed");

      -- Total CG
      declare
         Expected_CG : Float;
      begin
         Expected_CG := ((Tube.Get_Mass * 0.5) + (1.0 * (0.0 + 0.1))) / (Tube.Get_Mass + 1.0);
         pragma Assert (abs (Tube.Get_Total_CG - Expected_CG) < 0.001, "Total CG calculation failed");
      end;

      Put_Line ("All Component Tests Passed!");
   end Run_Component_Tests;

begin
   Put_Line ("Starting OpenRocket Ada TDD Test Runner");
   Put_Line ("---------------------------------------");
   Run_Math_Tests;
   Run_Component_Tests;
end Ada_Rocket_Simulations;
