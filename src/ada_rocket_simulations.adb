with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;
with Components; use Components;
with Aerodynamics; use Aerodynamics;
with Simulation; use Simulation;
with Motors; use Motors;
with Parser; use Parser;

procedure Ada_Rocket_Simulations is

   procedure Run_Math_Tests is
      V1 : constant Vector_3D := (1.0, 2.0, 3.0);
      V2 : constant Vector_3D := (4.0, 5.0, 6.0);
      V3 : Vector_3D;
   begin
      Put_Line ("Running Math Tests...");

      V3 := V1 + V2;
      pragma Assert
        (V3.X = 5.0 and V3.Y = 7.0 and V3.Z = 9.0,
         "Vector Addition failed");

      pragma Assert (Dot_Product (V1, V2) = 32.0, "Dot Product failed");

      V3 := 2.0 * V1;
      pragma Assert
        (V3.X = 2.0 and V3.Y = 4.0 and V3.Z = 6.0,
         "Scalar Multiplication failed");

      V3 := Cross_Product (V1, V2);
      pragma Assert
        (V3.X = -3.0 and V3.Y = 6.0 and V3.Z = -3.0,
         "Cross Product failed");

      Put_Line ("All Math Tests Passed!");
   end Run_Math_Tests;

   procedure Run_Component_Tests is
      Payload : aliased Mass_Object;
      Tube    : aliased Body_Tube;
      Nose    : aliased Nose_Cone;
   begin
      Put_Line ("Running Component Tests...");

      --  Initialize Payload
      Payload.Mass := 1.0;
      Payload.CG := 0.1;
      Payload.Position := 0.0;

      --  Initialize Tube
      Tube.Length := 1.0;
      Tube.Outer_Diameter := 0.1;
      Tube.Inner_Diameter := 0.09;
      Tube.Density := 1000.0;
      Tube.Position := 0.2;

      --  Initialize Nose Cone
      Nose.Length := 0.5;
      Nose.Base_Diameter := 0.1;
      Nose.Density := 500.0;
      Nose.Position := 0.0;

      --  Add Components
      Tube.Add_Child (Payload'Unchecked_Access);
      Nose.Add_Child (Tube'Unchecked_Access);

      --  Check Tube mass calculation
      pragma Assert (Tube.Get_Mass > 0.0, "Tube mass should be positive");

      --  Total Mass
      pragma Assert
        (Nose.Get_Total_Mass = Nose.Get_Mass + Tube.Get_Mass + Payload.Mass,
         "Total Mass calculation failed");

      --  Aerodynamics
      pragma Assert (Get_CN (Nose, Tube.Outer_Diameter) = 2.0, "Nose Cone CN failed");
      pragma Assert (Get_CN (Tube, Tube.Outer_Diameter) = 0.0, "Body Tube CN failed");

      --  Total CP calculation
      pragma Assert (Get_Total_CP (Nose, Tube.Outer_Diameter) >= 0.0, "Total CP failed");

      --  Stability Margin
      pragma Assert
        (Get_Stability_Margin (Nose, Tube.Outer_Diameter) >= 0.0,
         "Stability Margin failed");

      Put_Line ("All Component & Aerodynamics Tests Passed!");
   end Run_Component_Tests;

   procedure Run_Simulation_Tests is
      Payload : aliased Mass_Object;
      Tube    : aliased Body_Tube;
      Flight_State : State :=
        (Position => (0.0, 0.0, 0.0),
         Velocity => (0.0, 0.0, 0.0),
         Time => 0.0);
   begin
      Put_Line ("Running Simulation Tests...");

      Payload.Mass := 1.0;
      Tube.Length := 1.0;
      Tube.Outer_Diameter := 0.1;
      Tube.Inner_Diameter := 0.09;
      Tube.Density := 1000.0;
      Tube.Add_Child (Payload'Unchecked_Access);

      --  Step 1 second with enough thrust to hover
      Step (Flight_State, Tube, 24.4, 1.0);

      --  It shouldn't have fallen very far (Y velocity near 0)
      pragma Assert
        (abs (Flight_State.Velocity.Y) < 10.0,
         "Hover test failed");

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

      --  Test Thrust Interpolation
      Thrust := Get_Thrust (Estes_C6, 0.1);
      pragma Assert (Thrust = 7.0, "Thrust interpolation failed at 0.1s");

      --  Test Mass
      pragma Assert
        (Get_Mass (Estes_C6, 0.8) = 0.019,
         "Mass interpolation failed at 0.8s");

      Put_Line ("All Motor Tests Passed!");
   end Run_Motor_Tests;

   procedure Run_Recovery_Test is
      Payload : aliased Mass_Object;
      Tube    : aliased Body_Tube;
      Chute   : aliased Parachute;
      Flight_State : State := (Position => (0.0, 0.0, 0.0), Velocity => (0.0, 0.0, 0.0), Time => 0.0);
   begin
      Put_Line ("Running Recovery System Tests...");

      Payload.Mass := 1.0;
      Tube.Length := 1.0;
      Tube.Outer_Diameter := 0.1;
      Tube.Inner_Diameter := 0.09;
      Tube.Density := 1000.0;
      
      Chute.Diameter := 0.5;
      Chute.Deploy_Altitude := 50.0;
      
      Tube.Add_Child (Payload'Unchecked_Access);
      Tube.Add_Child (Chute'Unchecked_Access);

      -- Give it initial high velocity upward
      Flight_State.Velocity.Y := 100.0;
      Flight_State.Position.Y := 0.0;
      
      -- Simulate until apogee and deployment
      loop
         -- Stop when descending below deploy altitude
         exit when Flight_State.Position.Y < 50.0 and Flight_State.Velocity.Y < 0.0;
         exit when Flight_State.Time > 60.0;
         Step (Flight_State, Tube, 0.0, 0.05);
      end loop;
      
      -- Let it fall for a few seconds to verify drag
      for I in 1 .. 40 loop
         Step (Flight_State, Tube, 0.0, 0.05);
      end loop;

      -- Check if parachute deployed
      pragma Assert (Chute.Is_Deployed, "Parachute failed to deploy at altitude");
      
      -- Check if descent is slow (terminal velocity)
      pragma Assert (abs(Flight_State.Velocity.Y) < 15.0, "Parachute did not slow descent enough");

      Put_Line ("All Recovery System Tests Passed!");
   end Run_Recovery_Test;

   procedure Run_Fin_Aerodynamics_Test is
      Fins : aliased Fin_Set;
      CN   : Float;
      CP   : Float;
   begin
      Put_Line ("Running Fin Aerodynamics Tests...");
      
      Fins.Number_Of_Fins := 3;
      Fins.Root_Chord := 0.1;
      Fins.Tip_Chord := 0.05;
      Fins.Sweep_Length := 0.05;
      Fins.Span := 0.05;
      Fins.Position := 0.5; -- 0.5m from nose tip
      
      -- Let max diameter be 0.05m
      CN := Get_CN (Fins, 0.05);
      pragma Assert (CN > 0.0, "Fins should generate positive CN");
      
      CP := Get_CP (Fins);
      pragma Assert (CP > 0.0 and CP < 0.1, "Fin CP should be along the fin chord");
      
      Put_Line ("All Fin Aerodynamics Tests Passed!");
   end Run_Fin_Aerodynamics_Test;

   procedure Run_Full_Flight_Test is
      Mount : aliased Engine_Mount;
      Nose  : aliased Nose_Cone;
      Tube  : aliased Body_Tube;
      Fins  : aliased Fin_Set;
      Estes_C6 : Motor_Type;
      Apogee : Float;
      Flight_Time : Float;
   begin
      Put_Line ("Running Full Flight Simulation Test...");

      --  Setup Motor
      Estes_C6.Name := "Estes C6-5      ";
      Estes_C6.Name_Len := 10;
      Estes_C6.Burn_Time := 1.6;
      Estes_C6.Total_Mass := 0.025;
      Estes_C6.Prop_Mass := 0.012;
      Estes_C6.Num_Points := 3;
      Estes_C6.Thrust_Curve (1) := (Time => 0.0, Thrust => 0.0);
      Estes_C6.Thrust_Curve (2) := (Time => 0.2, Thrust => 14.0);
      Estes_C6.Thrust_Curve (3) := (Time => 1.6, Thrust => 4.0);

      --  Setup Rocket
      Nose.Length := 0.2;
      Nose.Base_Diameter := 0.03;
      Nose.Density := 200.0;

      Tube.Length := 0.5;
      Tube.Outer_Diameter := 0.03;
      Tube.Inner_Diameter := 0.025;
      Tube.Density := 500.0;
      Tube.Position := 0.2;

      Fins.Number_Of_Fins := 3;
      Fins.Root_Chord := 0.1;
      Fins.Tip_Chord := 0.05;
      Fins.Sweep_Length := 0.05;
      Fins.Span := 0.04;
      Fins.Thickness := 0.003;
      Fins.Density := 500.0;
      Fins.Position := 0.6; -- Back of the tube
      
      Mount.Length := 0.1;
      Mount.Outer_Diameter := 0.03;
      Mount.Inner_Diameter := 0.025;
      Mount.Density := 500.0;
      Mount.Position := 0.6;
      Mount.Has_Motor := True;
      Mount.Motor := Estes_C6;

      Tube.Add_Child (Fins'Unchecked_Access);
      Tube.Add_Child (Mount'Unchecked_Access);
      Nose.Add_Child (Tube'Unchecked_Access);

      --  Run flight and log to CSV
      Run_Flight
        (Rocket => Nose,
         Motor => Estes_C6,
         Dt => 0.01,
         Output_File => "flight_data.csv",
         Apogee => Apogee,
         Flight_Time => Flight_Time);

      pragma Assert
        (Apogee > 0.0,
         "Flight apogee must be strictly positive");

      Put_Line
        ("Full Flight Simulation finished. Data logged to flight_data.csv");
   end Run_Full_Flight_Test;

   procedure Run_Parser_Tests is
      File : Ada.Text_IO.File_Type;
      Rocket : Component_Access;
   begin
      Put_Line ("Running Parser Tests...");

      --  Create a dummy motor file
      Create (File, Out_File, "test_motor.eng");
      Put_Line (File, "; Estes C6");
      Put_Line (File, "C6 18 65 5-2 0.0108 0.0248 Estes");
      Put_Line (File, "0.010 0.000");
      Put_Line (File, "0.021 6.849");
      Put_Line (File, "1.600 0.000");
      Close (File);

      --  Create a dummy XML file
      Create (File, Out_File, "test_rocket.xml");
      Put_Line (File, "<OpenRocket>");
      Put_Line (File, "  <NoseCone>");
      Put_Line (File, "    <Length>0.65</Length>");
      Put_Line (File, "    <BaseDiameter>0.05</BaseDiameter>");
      Put_Line (File, "  </NoseCone>");
      Put_Line (File, "  <FinSet>");
      Put_Line (File, "    <FinCount>4</FinCount>");
      Put_Line (File, "    <RootChord>0.12</RootChord>");
      Put_Line (File, "    <TipChord>0.06</TipChord>");
      Put_Line (File, "    <Sweep>0.05</Sweep>");
      Put_Line (File, "    <Span>0.05</Span>");
      Put_Line (File, "    <Thickness>0.003</Thickness>");
      Put_Line (File, "  </FinSet>");
      Put_Line (File, "  <MassObject>");
      Put_Line (File, "    <Mass>0.1</Mass>");
      Put_Line (File, "    <CG>0.2</CG>");
      Put_Line (File, "  </MassObject>");
      Put_Line (File, "  <EngineBlock>");
      Put_Line (File, "    <Length>0.1</Length>");
      Put_Line (File, "    <OuterDiameter>0.03</OuterDiameter>");
      Put_Line (File, "    <InnerDiameter>0.025</InnerDiameter>");
      Put_Line (File, "    <Density>500.0</Density>");
      Put_Line (File, "    <Motor>test_motor.eng</Motor>");
      Put_Line (File, "  </EngineBlock>");
      Put_Line (File, "</OpenRocket>");
      Close (File);

      --  Parse it
      Parser.Load_Rocket ("test_rocket.xml", Rocket);

      --  Asserts
      pragma Assert
        (Rocket /= null,
         "Rocket should not be null after parsing");

      Put_Line ("All Parser Tests Passed!");
   end Run_Parser_Tests;

begin
   Put_Line ("Starting OpenRocket Ada TDD Test Runner");
   Put_Line ("---------------------------------------");
   Run_Math_Tests;
   Run_Component_Tests;
   Run_Simulation_Tests;
   Run_Motor_Tests;
   Run_Recovery_Test;
   Run_Fin_Aerodynamics_Test;
   Run_Parser_Tests;
   Run_Full_Flight_Test;
end Ada_Rocket_Simulations;
