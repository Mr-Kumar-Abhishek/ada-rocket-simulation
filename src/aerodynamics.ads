with Components; use Components;

package Aerodynamics is

   -- Barrowman Equations (Simplified for Subsonic)
   function Get_CN (This : Component'Class) return Float;
   function Get_CP (This : Component'Class) return Float;

   function Get_Total_CN (This : Component'Class) return Float;
   function Get_Total_CP (This : Component'Class) return Float;

   -- Stability Margin (in calibers)
   -- CP and CG are measured from the nose tip. Max_Diameter is the maximum body diameter.
   function Get_Stability_Margin (This : Component'Class; Max_Diameter : Float) return Float;

end Aerodynamics;
