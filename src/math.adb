package body Math is

   function "+" (Left, Right : Vector_3D) return Vector_3D is
   begin
      return (X => Left.X + Right.X,
              Y => Left.Y + Right.Y,
              Z => Left.Z + Right.Z);
   end "+";

   function Dot_Product (Left, Right : Vector_3D) return Float is
   begin
      return (Left.X * Right.X) + (Left.Y * Right.Y) + (Left.Z * Right.Z);
   end Dot_Product;

end Math;
