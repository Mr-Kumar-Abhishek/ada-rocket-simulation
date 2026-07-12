with Ada.Text_IO; use Ada.Text_IO;

package body Motors_Parser is

   procedure Load_Motor (File_Name : String; Motor : out Motor_Type) is
      File         : File_Type;
      Line         : String (1 .. 256);
      Last         : Natural;
      Header_Found : Boolean := False;
      
      -- Helper to extract tokens separated by spaces
      function Next_Token (Text : String; Start_Idx : in out Positive) return String is
         Token_Start : Positive := Start_Idx;
         Token_End   : Natural;
      begin
         -- Skip leading spaces or tabs
         while Token_Start <= Text'Last and then (Text(Token_Start) = ' ' or else Text(Token_Start) = ASCII.HT) loop
            Token_Start := Token_Start + 1;
         end loop;
         
         if Token_Start > Text'Last then
            return "";
         end if;
         
         -- Find end of token
         Token_End := Token_Start;
         while Token_End <= Text'Last and then Text(Token_End) /= ' ' and then Text(Token_End) /= ASCII.HT loop
            Token_End := Token_End + 1;
         end loop;
         
         Start_Idx := Token_End;
         return Text (Token_Start .. Token_End - 1);
      end Next_Token;

   begin
      -- Initialize motor to empty
      Motor.Name := (others => ' ');
      Motor.Name_Len := 0;
      Motor.Num_Points := 0;
      Motor.Burn_Time := 0.0;
      Motor.Total_Mass := 0.0;
      Motor.Prop_Mass := 0.0;
      Motor.Diameter := 0.0;
      Motor.Length := 0.0;

      Open (File, In_File, File_Name);

      while not End_Of_File (File) loop
         Get_Line (File, Line, Last);
         declare
            Current_Line : constant String := Line (1 .. Last);
            Start_Idx : Positive := 1;
         begin
            -- Skip comments or empty lines
            if Last = 0 or else Current_Line (1) = ';' then
               null;
            elsif not Header_Found then
               -- Parse Header
               -- Name Dia(mm) Len(mm) Delays PropMass(kg) TotMass(kg) Mfg
               declare
                  T1 : constant String := Next_Token (Current_Line, Start_Idx); -- Name
                  T2 : constant String := Next_Token (Current_Line, Start_Idx); -- Dia
                  T3 : constant String := Next_Token (Current_Line, Start_Idx); -- Len
                  T4 : constant String := Next_Token (Current_Line, Start_Idx); -- Delays (Ignored)
                  T5 : constant String := Next_Token (Current_Line, Start_Idx); -- PropMass
                  T6 : constant String := Next_Token (Current_Line, Start_Idx); -- TotMass
               begin
                  Motor.Name_Len := Natural'Min (16, T1'Length);
                  Motor.Name (1 .. Motor.Name_Len) := T1 (T1'First .. T1'First + Motor.Name_Len - 1);
                  
                  -- Convert mm to meters for dimensions
                  if T2'Length > 0 then Motor.Diameter := Float'Value (T2) / 1000.0; end if;
                  if T3'Length > 0 then Motor.Length := Float'Value (T3) / 1000.0; end if;
                  if T5'Length > 0 then Motor.Prop_Mass := Float'Value (T5); end if;
                  if T6'Length > 0 then Motor.Total_Mass := Float'Value (T6); end if;
               end;
               Header_Found := True;
            else
               -- Parse Data Points (Time Thrust)
               declare
                  T1 : constant String := Next_Token (Current_Line, Start_Idx); -- Time
                  T2 : constant String := Next_Token (Current_Line, Start_Idx); -- Thrust
               begin
                  if T1'Length > 0 and then T2'Length > 0 then
                     if Motor.Num_Points < Max_Thrust_Points then
                        Motor.Num_Points := Motor.Num_Points + 1;
                        Motor.Thrust_Curve (Motor.Num_Points).Time := Float'Value (T1);
                        Motor.Thrust_Curve (Motor.Num_Points).Thrust := Float'Value (T2);
                        Motor.Burn_Time := Motor.Thrust_Curve (Motor.Num_Points).Time;
                     end if;
                  end if;
               end;
            end if;
         end;
      end loop;

      Close (File);
   exception
      when others =>
         -- If the file doesn't exist or is invalid, just close and return empty
         if Is_Open (File) then
            Close (File);
         end if;
   end Load_Motor;

end Motors_Parser;
