package body Math is

   function "+" (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (X => Left.X + Right.X,
              Y => Left.Y + Right.Y,
              Z => Left.Z + Right.Z);
   end "+";

   function "*" (Left : Float; Right : Vector_3D) return Vector_3D is
   begin
      return (X => Left * Right.X,
              Y => Left * Right.Y,
              Z => Left * Right.Z);
   end "*";

   function "*" (Left : Vector_3D; Right : Float) return Vector_3D is
   begin
      return (X => Left.X * Right,
              Y => Left.Y * Right,
              Z => Left.Z * Right);
   end "*";

   function Dot_Product (Left, Right : Vector_3D) return Float is
   begin
      return (Left.X * Right.X) + (Left.Y * Right.Y) + (Left.Z * Right.Z);
   end Dot_Product;

   function Cross_Product (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (X => (Left.Y * Right.Z) - (Left.Z * Right.Y),
              Y => (Left.Z * Right.X) - (Left.X * Right.Z),
              Z => (Left.X * Right.Y) - (Left.Y * Right.X));
   end Cross_Product;

end Math;
