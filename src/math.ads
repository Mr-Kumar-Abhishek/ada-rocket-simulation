package Math is
   type Vector_3D is record
      X : Float := 0.0;
      Y : Float := 0.0;
      Z : Float := 0.0;
   end record;

   type Quaternion is record
      W : Float := 1.0;
      X : Float := 0.0;
      Y : Float := 0.0;
      Z : Float := 0.0;
   end record;

   function "+" (Left, Right : Vector_3D) return Vector_3D;
   function "-" (Left, Right : Vector_3D) return Vector_3D;
   function "-" (Right : Vector_3D) return Vector_3D;
   function "*" (Left : Float; Right : Vector_3D) return Vector_3D;
   function "*" (Left : Vector_3D; Right : Float) return Vector_3D;
   function "/" (Left : Vector_3D; Right : Float) return Vector_3D;
   function Dot_Product (Left, Right : Vector_3D) return Float;
   function Cross_Product (Left, Right : Vector_3D) return Vector_3D;
   function Magnitude (V : Vector_3D) return Float;
   function Normalize (V : Vector_3D) return Vector_3D;

   -- Quaternion operations
   function "+" (Left, Right : Quaternion) return Quaternion;
   function "*" (Q1, Q2 : Quaternion) return Quaternion;
   function "*" (Q : Quaternion; F : Float) return Quaternion;
   function Normalize (Q : Quaternion) return Quaternion;
   
   -- Rotate a vector by a quaternion (V_rotated = Q * V * Q^-1)
   function Rotate (V : Vector_3D; Q : Quaternion) return Vector_3D;
   
   function Identity_Quaternion return Quaternion;
end Math;
