package body Aerodynamics is

   -- Barrowman Equations (Simplified for Subsonic)

   function Get_CN (This : Component'Class) return Float is
   begin
      if This in Nose_Cone then
         return 2.0; -- Standard for a conical/ogive nose cone
      elsif This in Body_Tube then
         return 0.0; -- Bare body tube has roughly zero normal force in Barrowman
      else
         return 0.0;
      end if;
   end Get_CN;

   function Get_CP (This : Component'Class) return Float is
   begin
      if This in Nose_Cone then
         declare
            NC : constant Nose_Cone := Nose_Cone (This);
         begin
            return NC.Length * 0.466; -- Rough CP for a cone (actually 0.66 for cone, 0.466 for ogive, using 0.466 here)
         end;
      elsif This in Body_Tube then
         declare
            BT : constant Body_Tube := Body_Tube (This);
         begin
            return BT.Length / 2.0;
         end;
      else
         return 0.0;
      end if;
   end Get_CP;

   function Get_Total_CN (This : Component'Class) return Float is
      Total_CN : Float := Get_CN (This);
   begin
      for Child of This.Children loop
         Total_CN := Total_CN + Get_Total_CN (Child.all);
      end loop;
      return Total_CN;
   end Get_Total_CN;

   function Get_Total_CP (This : Component'Class) return Float is
      Total_CN : Float := Get_Total_CN (This);
      Moment   : Float := Get_CN (This) * Get_CP (This);
   begin
      if Total_CN = 0.0 then
         return 0.0;
      end if;

      for Child of This.Children loop
         Moment := Moment + Get_Total_CN (Child.all) * (Child.Position + Get_Total_CP (Child.all));
      end loop;

      return Moment / Total_CN;
   end Get_Total_CP;

   function Get_Stability_Margin (This : Component'Class; Max_Diameter : Float) return Float is
      CP : Float := Get_Total_CP (This);
      CG : Float := Get_Total_CG (This);
   begin
      if Max_Diameter <= 0.0 then
         return 0.0;
      end if;
      return (CP - CG) / Max_Diameter;
   end Get_Stability_Margin;

end Aerodynamics;
