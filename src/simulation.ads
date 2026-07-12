with Math; use Math;
with Components; use Components;
with Aerodynamics; use Aerodynamics;

with Motors; use Motors;

package Simulation is

   type State is record
      Position : Vector_3D;
      Velocity : Vector_3D;
      Time     : Float;
   end record;

   -- Simple Euler numerical integration step
   procedure Step (Current : in out State;
                   Rocket  : in out Component'Class;
                   Thrust  : in Float;
                   Dt      : in Float);

   -- Runs a full flight simulation loop until rocket returns to ground
   procedure Run_Flight (Rocket      : in out Component'Class;
                         Motor       : in Motor_Type;
                         Dt          : in Float;
                         Output_File : in String;
                         Apogee      : out Float;
                         Flight_Time : out Float);

end Simulation;
