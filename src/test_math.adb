with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;

procedure Test_Math is
   V1 : constant Vector_3D := (1.0, 2.0, 3.0);
   V2 : constant Vector_3D := (4.0, 5.0, 6.0);
   V3 : Vector_3D;
begin
   Put_Line ("Running Math Tests...");

   -- Test Addition
   V3 := V1 + V2;
   pragma Assert (V3.X = 5.0 and V3.Y = 7.0 and V3.Z = 9.0, "Vector Addition failed");

   -- Test Dot Product
   pragma Assert (Dot_Product (V1, V2) = 32.0, "Dot Product failed");

   Put_Line ("All Math Tests Passed!");
end Test_Math;
