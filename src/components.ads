with Ada.Containers.Vectors;
with Math; use Math;
with Motors;

package Components is

   type Component;
   type Component_Access is access all Component'Class;

   package Component_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Component_Access);

   type Component is abstract tagged record
      Name       : String (1 .. 32);
      Name_Len   : Natural := 0;
      Position   : Float := 0.0; -- Position relative to parent
      Children   : Component_Vectors.Vector;
   end record;

   -- Abstract methods that must be overridden
   function Get_Mass (This : Component) return Float is abstract;
   function Get_CG (This : Component) return Float is abstract;

   -- Recursive calculation methods
   function Get_Total_Mass (This : Component) return Float;
   function Get_Total_CG (This : Component) return Float;

   -- Modifiers
   procedure Add_Child (This : in out Component; Child : Component_Access);

   -- Concrete Components
   type Mass_Object is new Component with record
      Mass : Float;
      CG   : Float;
   end record;

   overriding function Get_Mass (This : Mass_Object) return Float;
   overriding function Get_CG (This : Mass_Object) return Float;

   type Body_Tube is new Component with record
      Length         : Float;
      Outer_Diameter : Float;
      Inner_Diameter : Float;
      Density        : Float;
   end record;

   overriding function Get_Mass (This : Body_Tube) return Float;
   overriding function Get_CG (This : Body_Tube) return Float;

   type Nose_Cone is new Component with record
      Length         : Float;
      Base_Diameter  : Float;
      Density        : Float;
   end record;

   overriding function Get_Mass (This : Nose_Cone) return Float;
   overriding function Get_CG (This : Nose_Cone) return Float;

   type Engine_Mount is new Component with record
      Length         : Float;
      Outer_Diameter : Float;
      Inner_Diameter : Float;
      Density        : Float;
      Has_Motor      : Boolean := False;
      Motor          : Motors.Motor_Type;
      Simulation_Time: Float := 0.0; -- To track time for mass reduction during burn
   end record;

   overriding function Get_Mass (This : Engine_Mount) return Float;
   overriding function Get_CG (This : Engine_Mount) return Float;

end Components;
