with Components; use Components;

package Aerodynamics is

   -- Barrowman Equations (Simplified for Subsonic)
   function Get_CN (This : Component'Class) return Float;
   function Get_CP (This : Component'Class) return Float;

   function Get_Total_CN (This : Component'Class) return Float;
   function Get_Total_CP (This : Component'Class) return Float;

end Aerodynamics;
