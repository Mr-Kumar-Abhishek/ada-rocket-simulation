package Math is
   type Vector_3D is record
      X : Float;
      Y : Float;
      Z : Float;
   end record;

   function "+" (Left, Right : Vector_3D) return Vector_3D;
   function "*" (Left : Float; Right : Vector_3D) return Vector_3D;
   function "*" (Left : Vector_3D; Right : Float) return Vector_3D;
   function Dot_Product (Left, Right : Vector_3D) return Float;
   function Cross_Product (Left, Right : Vector_3D) return Vector_3D;
end Math;
