with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Aerodynamics is

   -- Barrowman Equations (Simplified for Subsonic)

   function Get_CN (This : Component'Class; Max_Diameter : Float) return Float is
   begin
      if This in Nose_Cone then
         return 2.0; -- Standard for a conical/ogive nose cone
      elsif This in Body_Tube then
         return 0.0; -- Bare body tube has roughly zero normal force in Barrowman
      elsif This in Fin_Set then
         declare
            F : constant Fin_Set := Fin_Set (This);
            Term1 : Float;
            Term2 : Float;
            L_mid : Float;
         begin
            if Max_Diameter <= 0.0 then
               return 0.0;
            end if;

            -- Mid-chord sweep length
            L_mid := F.Sweep_Length + (F.Tip_Chord / 2.0) - (F.Root_Chord / 2.0);

            -- CN = (4 * n * (s/d)^2) / (1 + sqrt(1 + (2 * L_mid / (Cr + Ct))^2))
            Term1 := 4.0 * Float(F.Number_Of_Fins) * ((F.Span / Max_Diameter) ** 2);
            Term2 := 1.0 + Sqrt (1.0 + ((2.0 * L_mid) / (F.Root_Chord + F.Tip_Chord)) ** 2);
            return Term1 / Term2;
         end;
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
            return NC.Length * 0.466; -- Rough CP for a cone
         end;
      elsif This in Body_Tube then
         declare
            BT : constant Body_Tube := Body_Tube (This);
         begin
            return BT.Length / 2.0;
         end;
      elsif This in Fin_Set then
         declare
            F : constant Fin_Set := Fin_Set (This);
            Term1 : Float;
            Term2 : Float;
         begin
            -- CP from fin leading edge root
            Term1 := (F.Sweep_Length / 3.0) * ((F.Root_Chord + 2.0 * F.Tip_Chord) / (F.Root_Chord + F.Tip_Chord));
            Term2 := (1.0 / 6.0) * (F.Root_Chord + F.Tip_Chord - ((F.Root_Chord * F.Tip_Chord) / (F.Root_Chord + F.Tip_Chord)));
            return Term1 + Term2;
         end;
      else
         return 0.0;
      end if;
   end Get_CP;

   function Get_Total_CN (This : Component'Class; Max_Diameter : Float) return Float is
      Total_CN : Float := Get_CN (This, Max_Diameter);
   begin
      for Child of This.Children loop
         Total_CN := Total_CN + Get_Total_CN (Child.all, Max_Diameter);
      end loop;
      return Total_CN;
   end Get_Total_CN;

   function Get_Total_CP (This : Component'Class; Max_Diameter : Float) return Float is
      Total_CN : Float := Get_Total_CN (This, Max_Diameter);
      Moment   : Float := Get_CN (This, Max_Diameter) * Get_CP (This);
   begin
      if Total_CN = 0.0 then
         return 0.0;
      end if;

      for Child of This.Children loop
         Moment := Moment + Get_Total_CN (Child.all, Max_Diameter) * (Child.Position + Get_Total_CP (Child.all, Max_Diameter));
      end loop;

      return Moment / Total_CN;
   end Get_Total_CP;

   function Get_Total_CDA (This : Component'Class) return Float is
      Total_CDA : Float := 0.0;
   begin
      if This in Parachute then
         declare
            P : constant Parachute := Parachute (This);
         begin
            if P.Is_Deployed then
               Total_CDA := P.Drag_Coefficient * (3.14159 * (P.Diameter / 2.0)**2);
            end if;
         end;
      elsif This in Nose_Cone then
         declare
            NC : constant Nose_Cone := Nose_Cone (This);
         begin
            Total_CDA := 0.4 * (3.14159 * (NC.Base_Diameter / 2.0)**2);
         end;
      end if;

      for Child of This.Children loop
         Total_CDA := Total_CDA + Get_Total_CDA (Child.all);
      end loop;

      return Total_CDA;
   end Get_Total_CDA;

   function Get_Stability_Margin (This : Component'Class; Max_Diameter : Float) return Float is
      CP : Float := Get_Total_CP (This, Max_Diameter);
      CG : Float := Get_Total_CG (This);
   begin
      if Max_Diameter <= 0.0 then
         return 0.0;
      end if;
      return (CP - CG) / Max_Diameter;
   end Get_Stability_Margin;

end Aerodynamics;
