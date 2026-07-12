with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

package body Parser is

   --  A very basic XML scanner for the MVP
   procedure Load_Rocket
     (File_Name : String;
      Rocket    : out Component_Access)
   is
      File : File_Type;
      Line : String (1 .. 1024);
      Last : Natural;

      Parsing_Nose_Cone : Boolean := False;
      Parsing_Body_Tube : Boolean := False;
      Parsing_Parachute : Boolean := False;
      Parsing_Fin_Set   : Boolean := False;

      Current_Component : Component_Access := null;

      --  Helper to extract a float value from a tag line
      function Extract_Float
        (Text : String;
         Tag  : String) return Float
      is
         Start_Idx : Natural := Index (Text, "<" & Tag & ">");
         End_Idx   : Natural := Index (Text, "</" & Tag & ">");
      begin
         if Start_Idx > 0 and then End_Idx > Start_Idx then
            Start_Idx := Start_Idx + Tag'Length + 2;
            return Float'Value (Text (Start_Idx .. End_Idx - 1));
         end if;
         return 0.0;
      end Extract_Float;

   begin
      Rocket := null;
      Open (File, In_File, File_Name);

      while not End_Of_File (File) loop
         Get_Line (File, Line, Last);
         declare
            Current_Line : constant String := Line (1 .. Last);
         begin
            --  Check for component tags
            if Index (Current_Line, "<NoseCone>") > 0 then
               Parsing_Nose_Cone := True;
               Parsing_Body_Tube := False;
               Parsing_Parachute := False;
               Parsing_Fin_Set   := False;
               Current_Component := new Nose_Cone;
               Current_Component.Name := "Nose Cone                       ";
               Nose_Cone(Current_Component.all).Density := 200.0;
            elsif Index (Current_Line, "<BodyTube>") > 0 then
               Parsing_Body_Tube := True;
               Parsing_Nose_Cone := False;
               Parsing_Parachute := False;
               Parsing_Fin_Set   := False;
               Current_Component := new Body_Tube;
               Current_Component.Name := "Body Tube                       ";
               Body_Tube(Current_Component.all).Density := 1000.0;
            elsif Index (Current_Line, "<Parachute>") > 0 then
               Parsing_Parachute := True;
               Parsing_Body_Tube := False;
               Parsing_Nose_Cone := False;
               Parsing_Fin_Set   := False;
               Current_Component := new Parachute;
               Current_Component.Name := "Parachute                       ";
            elsif Index (Current_Line, "<FinSet>") > 0 then
               Parsing_Fin_Set   := True;
               Parsing_Parachute := False;
               Parsing_Body_Tube := False;
               Parsing_Nose_Cone := False;
               Current_Component := new Fin_Set;
               Current_Component.Name := "Fins                            ";
            end if;

            --  Extract properties if inside a component
            if Parsing_Nose_Cone and then Current_Component /= null then
               if Index (Current_Line, "<Length>") > 0 then
                  Nose_Cone(Current_Component.all).Length := Extract_Float (Current_Line, "Length");
               elsif Index (Current_Line, "<BaseDiameter>") > 0 then
                  Nose_Cone(Current_Component.all).Base_Diameter :=
                    Extract_Float (Current_Line, "BaseDiameter");
               end if;
            elsif Parsing_Body_Tube and then Current_Component /= null then
               if Index (Current_Line, "<Length>") > 0 then
                  Body_Tube(Current_Component.all).Length := Extract_Float (Current_Line, "Length");
               elsif Index (Current_Line, "<OuterDiameter>") > 0 then
                  Body_Tube(Current_Component.all).Outer_Diameter :=
                    Extract_Float (Current_Line, "OuterDiameter");
               elsif Index (Current_Line, "<InnerDiameter>") > 0 then
                  Body_Tube(Current_Component.all).Inner_Diameter :=
                    Extract_Float (Current_Line, "InnerDiameter");
               end if;
            elsif Parsing_Parachute and then Current_Component /= null then
               if Index (Current_Line, "<Diameter>") > 0 then
                  Parachute(Current_Component.all).Diameter := Extract_Float (Current_Line, "Diameter");
               elsif Index (Current_Line, "<DeployAltitude>") > 0 then
                  Parachute(Current_Component.all).Deploy_Altitude := Extract_Float (Current_Line, "DeployAltitude");
               end if;
            elsif Parsing_Fin_Set and then Current_Component /= null then
               if Index (Current_Line, "<FinCount>") > 0 then
                  Fin_Set(Current_Component.all).Number_Of_Fins := Positive (Extract_Float (Current_Line, "FinCount"));
               elsif Index (Current_Line, "<RootChord>") > 0 then
                  Fin_Set(Current_Component.all).Root_Chord := Extract_Float (Current_Line, "RootChord");
               elsif Index (Current_Line, "<TipChord>") > 0 then
                  Fin_Set(Current_Component.all).Tip_Chord := Extract_Float (Current_Line, "TipChord");
               elsif Index (Current_Line, "<Sweep>") > 0 then
                  Fin_Set(Current_Component.all).Sweep_Length := Extract_Float (Current_Line, "Sweep");
               elsif Index (Current_Line, "<Span>") > 0 then
                  Fin_Set(Current_Component.all).Span := Extract_Float (Current_Line, "Span");
               elsif Index (Current_Line, "<Thickness>") > 0 then
                  Fin_Set(Current_Component.all).Thickness := Extract_Float (Current_Line, "Thickness");
               end if;
            end if;
         end;
      end loop;

      Close (File);
      Rocket := Current_Component;
   end Load_Rocket;

end Parser;
