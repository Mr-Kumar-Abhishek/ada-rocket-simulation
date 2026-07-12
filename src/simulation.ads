with Math; use Math;
with Components; use Components;
with Aerodynamics; use Aerodynamics;

package Simulation is

   type State is record
      Position : Vector_3D;
      Velocity : Vector_3D;
      Time     : Float;
   end record;

   -- Simple Euler numerical integration step for demonstration
   procedure Step (Current : in out State;
                   Rocket  : in Component'Class;
                   Thrust  : in Float;
                   Dt      : in Float);

end Simulation;
