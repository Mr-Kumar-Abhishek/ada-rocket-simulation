package body Components is

   function Get_Total_Mass (This : Component'Class) return Float is
      Total : Float := This.Get_Mass;
   begin
      for Child of This.Children loop
         Total := Total + Child.Get_Total_Mass;
      end loop;
      return Total;
   end Get_Total_Mass;

   function Get_Total_CG (This : Component'Class) return Float is
      Total_Mass : Float := Get_Total_Mass (This);
      Moment     : Float := This.Get_Mass * This.Get_CG;
   begin
      if Total_Mass = 0.0 then
         return 0.0;
      end if;

      for Child of This.Children loop
         -- Moment of child = Mass * (Parent_Position + Child_CG)
         Moment := Moment + Child.Get_Total_Mass * (Child.Position + Child.Get_Total_CG);
      end loop;

      return Moment / Total_Mass;
   end Get_Total_CG;

   procedure Add_Child (This : in out Component'Class; Child : Component_Access) is
   begin
      This.Children.Append (Child);
   end Add_Child;

   -- Mass_Object
   overriding function Get_Mass (This : Mass_Object) return Float is
   begin
      return This.Mass;
   end Get_Mass;

   overriding function Get_CG (This : Mass_Object) return Float is
   begin
      return This.CG;
   end Get_CG;

   -- Body_Tube (Hollow cylinder approximation)
   overriding function Get_Mass (This : Body_Tube) return Float is
      Pi : constant Float := 3.14159265;
      Volume : Float;
   begin
      Volume := Pi * ((This.Outer_Diameter / 2.0)**2 - (This.Inner_Diameter / 2.0)**2) * This.Length;
      return Volume * This.Density;
   end Get_Mass;

   overriding function Get_CG (This : Body_Tube) return Float is
   begin
      return This.Length / 2.0; -- Center of the tube
   end Get_CG;

   -- Nose_Cone (Solid conical approximation for simplicity)
   overriding function Get_Mass (This : Nose_Cone) return Float is
      Pi : constant Float := 3.14159265;
      Volume : Float;
   begin
      Volume := Pi * (This.Base_Diameter / 2.0)**2 * This.Length / 3.0;
      return Volume * This.Density;
   end Get_Mass;

   overriding function Get_CG (This : Nose_Cone) return Float is
   begin
      return This.Length * 0.75; -- CG of a solid cone from the tip
   end Get_CG;

   -- Engine_Mount
   overriding function Get_Mass (This : Engine_Mount) return Float is
      Pi : constant Float := 3.14159265;
      Volume : Float;
      Structural_Mass : Float;
      Total_Mass : Float;
   begin
      Volume := Pi * ((This.Outer_Diameter / 2.0)**2 - (This.Inner_Diameter / 2.0)**2) * This.Length;
      Structural_Mass := Volume * This.Density;
      Total_Mass := Structural_Mass;
      
      if This.Has_Motor then
         Total_Mass := Total_Mass + Motors.Get_Mass (This.Motor, This.Simulation_Time);
      end if;
      
      return Total_Mass;
   end Get_Mass;

   overriding function Get_CG (This : Engine_Mount) return Float is
      Structural_Mass : Float;
      Pi : constant Float := 3.14159265;
      Volume : Float;
      Motor_Mass : Float := 0.0;
      Total_Mass : Float;
   begin
      Volume := Pi * ((This.Outer_Diameter / 2.0)**2 - (This.Inner_Diameter / 2.0)**2) * This.Length;
      Structural_Mass := Volume * This.Density;
      
      if This.Has_Motor then
         Motor_Mass := Motors.Get_Mass (This.Motor, This.Simulation_Time);
      end if;
      
      Total_Mass := Structural_Mass + Motor_Mass;
      
      if Total_Mass = 0.0 then
         return 0.0;
      end if;
      
      -- Assuming both the mount structure and the motor have their individual CGs at Length / 2.0
      return ((Structural_Mass * (This.Length / 2.0)) + (Motor_Mass * (This.Length / 2.0))) / Total_Mass;
   end Get_CG;

end Components;
