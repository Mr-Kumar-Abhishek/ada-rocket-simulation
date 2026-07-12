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
      Total_Moment : Float := This.Get_Mass * This.Get_CG;
      Total_Mass   : Float := This.Get_Mass;
   begin
      for Child of This.Children loop
         Total_Moment := Total_Moment + Child.Get_Total_Mass * (Child.Position + Child.Get_Total_CG);
         Total_Mass   := Total_Mass + Child.Get_Total_Mass;
      end loop;

      if Total_Mass = 0.0 then
         return 0.0;
      end if;

      return Total_Moment / Total_Mass;
   end Get_Total_CG;

   function Get_Total_MOI (This : Component'Class) return Float is
      -- Uses parallel axis theorem: I_total = Sum(I_local + m * d^2)
      Total_MOI : Float := 0.0;
      Global_CG : Float := This.Get_Total_CG;
      
      procedure Accumulate_MOI (Comp : Component'Class; Global_Offset : Float) is
         Comp_CG_Global : Float := Global_Offset + Comp.Get_CG;
         D : Float := Comp_CG_Global - Global_CG;
      begin
         Total_MOI := Total_MOI + Comp.Get_MOI + Comp.Get_Mass * (D * D);
         
         for Child of Comp.Children loop
            Accumulate_MOI (Child.all, Global_Offset + Child.Position);
         end loop;
      end Accumulate_MOI;
      
   begin
      Accumulate_MOI (This, 0.0);
      
      -- Ensure we don't return exactly zero to prevent div-by-zero later
      if Total_MOI < 0.0001 then
         return 0.0001;
      end if;
      return Total_MOI;
   end Get_Total_MOI;

   function Get_Max_Diameter (This : Component'Class) return Float is
      Max_Dia : Float := 0.0;
   begin
      if This in Body_Tube then
         Max_Dia := Body_Tube(This).Outer_Diameter;
      elsif This in Nose_Cone then
         Max_Dia := Nose_Cone(This).Base_Diameter;
      elsif This in Engine_Mount then
         Max_Dia := Engine_Mount(This).Outer_Diameter;
      end if;

      for Child of This.Children loop
         declare
            Child_Max : Float := Child.Get_Max_Diameter;
         begin
            if Child_Max > Max_Dia then
               Max_Dia := Child_Max;
            end if;
         end;
      end loop;

      return Max_Dia;
   end Get_Max_Diameter;

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

   overriding function Get_MOI (This : Mass_Object) return Float is
   begin
      return 0.0; -- Point mass has no local rotational inertia
   end Get_MOI;

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

   overriding function Get_MOI (This : Body_Tube) return Float is
   begin
      -- I = 1/12 * M * L^2 (treating as a thin rod for simplicity)
      return (1.0 / 12.0) * This.Get_Mass * (This.Length ** 2);
   end Get_MOI;

   -- Nose_Cone (Solid conical approximation for simplicity)
   overriding function Get_Mass (This : Nose_Cone) return Float is
      Pi : constant Float := 3.14159265;
      Volume : Float;
   begin
      Volume := (Pi / 3.0) * ((This.Base_Diameter / 2.0)**2) * This.Length;
      return Volume * This.Density;
   end Get_Mass;

   overriding function Get_CG (This : Nose_Cone) return Float is
   begin
      return This.Length * 0.75; -- Center of mass for a solid cone
   end Get_CG;

   overriding function Get_MOI (This : Nose_Cone) return Float is
   begin
      return (3.0 / 80.0) * This.Get_Mass * (This.Base_Diameter**2 + 4.0 * This.Length**2);
   end Get_MOI;

   -- Engine_Mount (Hollow cylinder + Optional motor)
   overriding function Get_Mass (This : Engine_Mount) return Float is
      Pi : constant Float := 3.14159265;
      Volume : Float;
      Motor_Mass : Float := 0.0;
   begin
      Volume := Pi * ((This.Outer_Diameter / 2.0)**2 - (This.Inner_Diameter / 2.0)**2) * This.Length;
      
      if This.Has_Motor then
         Motor_Mass := Motors.Get_Mass (This.Motor, This.Simulation_Time);
      end if;

      return (Volume * This.Density) + Motor_Mass;
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
      
      return ((Structural_Mass * (This.Length / 2.0)) + (Motor_Mass * (This.Length / 2.0))) / Total_Mass;
   end Get_CG;

   overriding function Get_MOI (This : Engine_Mount) return Float is
   begin
      return (1.0 / 12.0) * This.Get_Mass * (This.Length ** 2);
   end Get_MOI;

   -- Parachute
   overriding function Get_Mass (This : Parachute) return Float is
   begin
      -- Simplified: mass of parachute assumed negligible or included in Mass_Object for now
      return 0.05; 
   end Get_Mass;

   overriding function Get_CG (This : Parachute) return Float is
   begin
      return 0.0;
   end Get_CG;

   overriding function Get_MOI (This : Parachute) return Float is
   begin
      return 0.0;
   end Get_MOI;

   -- Fin_Set
   overriding function Get_Mass (This : Fin_Set) return Float is
      Area : Float;
   begin
      Area := 0.5 * (This.Root_Chord + This.Tip_Chord) * This.Span;
      return Area * This.Thickness * This.Density * Float (This.Number_Of_Fins);
   end Get_Mass;

   overriding function Get_CG (This : Fin_Set) return Float is
   begin
      -- Simplified CG calculation for fin geometry
      return This.Root_Chord / 2.0;
   end Get_CG;

   overriding function Get_MOI (This : Fin_Set) return Float is
   begin
      return This.Get_Mass * ((This.Root_Chord / 2.0)**2);
   end Get_MOI;

end Components;
