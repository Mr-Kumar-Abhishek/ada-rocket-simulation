package body Components is

   function Get_Total_Mass (This : Component) return Float is
      Total : Float := This.Get_Mass;
   begin
      for Child of This.Children loop
         Total := Total + Child.Get_Total_Mass;
      end loop;
      return Total;
   end Get_Total_Mass;

   function Get_Total_CG (This : Component) return Float is
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

   procedure Add_Child (This : in out Component; Child : Component_Access) is
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

end Components;
