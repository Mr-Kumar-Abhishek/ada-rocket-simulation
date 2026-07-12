with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Math is

   function "+" (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (Left.X + Right.X, Left.Y + Right.Y, Left.Z + Right.Z);
   end "+";

   function "-" (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (Left.X - Right.X, Left.Y - Right.Y, Left.Z - Right.Z);
   end "-";

   function "*" (Left : Float; Right : Vector_3D) return Vector_3D is
   begin
      return (Left * Right.X, Left * Right.Y, Left * Right.Z);
   end "*";

   function "*" (Left : Vector_3D; Right : Float) return Vector_3D is
   begin
      return (Left.X * Right, Left.Y * Right, Left.Z * Right);
   end "*";

   function "/" (Left : Vector_3D; Right : Float) return Vector_3D is
   begin
      if Right = 0.0 then
         return (0.0, 0.0, 0.0);
      end if;
      return (Left.X / Right, Left.Y / Right, Left.Z / Right);
   end "/";

   function Dot_Product (Left, Right : Vector_3D) return Float is
   begin
      return Left.X * Right.X + Left.Y * Right.Y + Left.Z * Right.Z;
   end Dot_Product;

   function Cross_Product (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (X => Left.Y * Right.Z - Left.Z * Right.Y,
              Y => Left.Z * Right.X - Left.X * Right.Z,
              Z => Left.X * Right.Y - Left.Y * Right.X);
   end Cross_Product;

   function Magnitude (V : Vector_3D) return Float is
   begin
      return Sqrt (V.X**2 + V.Y**2 + V.Z**2);
   end Magnitude;

   function Normalize (V : Vector_3D) return Vector_3D is
      Mag : constant Float := Magnitude (V);
   begin
      if Mag > 0.0 then
         return V / Mag;
      else
         return (0.0, 0.0, 0.0);
      end if;
   end Normalize;

   -- Quaternion operations

   function "+" (Left, Right : Quaternion) return Quaternion is
   begin
      return (W => Left.W + Right.W,
              X => Left.X + Right.X,
              Y => Left.Y + Right.Y,
              Z => Left.Z + Right.Z);
   end "+";

   function "*" (Q1, Q2 : Quaternion) return Quaternion is
   begin
      return (W => Q1.W * Q2.W - Q1.X * Q2.X - Q1.Y * Q2.Y - Q1.Z * Q2.Z,
              X => Q1.W * Q2.X + Q1.X * Q2.W + Q1.Y * Q2.Z - Q1.Z * Q2.Y,
              Y => Q1.W * Q2.Y - Q1.X * Q2.Z + Q1.Y * Q2.W + Q1.Z * Q2.X,
              Z => Q1.W * Q2.Z + Q1.X * Q2.Y - Q1.Y * Q2.X + Q1.Z * Q2.W);
   end "*";

   function "*" (Q : Quaternion; F : Float) return Quaternion is
   begin
      return (W => Q.W * F, X => Q.X * F, Y => Q.Y * F, Z => Q.Z * F);
   end "*";

   function Normalize (Q : Quaternion) return Quaternion is
      Mag : constant Float := Sqrt (Q.W**2 + Q.X**2 + Q.Y**2 + Q.Z**2);
   begin
      if Mag > 0.0 then
         return (W => Q.W / Mag, X => Q.X / Mag, Y => Q.Y / Mag, Z => Q.Z / Mag);
      else
         return Identity_Quaternion;
      end if;
   end Normalize;

   function Rotate (V : Vector_3D; Q : Quaternion) return Vector_3D is
      Q_Vec  : constant Vector_3D := (X => Q.X, Y => Q.Y, Z => Q.Z);
      T      : constant Vector_3D := 2.0 * Cross_Product (Q_Vec, V);
   begin
      return V + (Q.W * T) + Cross_Product (Q_Vec, T);
   end Rotate;

   function Identity_Quaternion return Quaternion is
   begin
      return (W => 1.0, X => 0.0, Y => 0.0, Z => 0.0);
   end Identity_Quaternion;

end Math;
