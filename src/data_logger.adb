with Ada.Float_Text_IO;

package body Data_Logger is

   procedure Init_Log (File : in out File_Type; File_Name : String) is
   begin
      Create (File, Out_File, File_Name);
      Put_Line (File, "Time(s),Pos_X(m),Pos_Y(m),Pos_Z(m),Vel_X(m/s),Vel_Y(m/s),Vel_Z(m/s),Thrust(N),Mass(kg)");
   end Init_Log;

   procedure Log_State (File : in File_Type; Current : State; Thrust, Mass : Float) is
      
      procedure Put_Float (Value : Float) is
      begin
         Ada.Float_Text_IO.Put (File => File, Item => Value, Fore => 1, Aft => 4, Exp => 0);
      end Put_Float;

   begin
      Put_Float (Current.Time); Put (File, ",");
      Put_Float (Current.Position.X); Put (File, ",");
      Put_Float (Current.Position.Y); Put (File, ",");
      Put_Float (Current.Position.Z); Put (File, ",");
      Put_Float (Current.Velocity.X); Put (File, ",");
      Put_Float (Current.Velocity.Y); Put (File, ",");
      Put_Float (Current.Velocity.Z); Put (File, ",");
      Put_Float (Thrust); Put (File, ",");
      Put_Float (Mass);
      New_Line (File);
   end Log_State;

   procedure Close_Log (File : in out File_Type) is
   begin
      if Is_Open (File) then
         Close (File);
      end if;
   end Close_Log;

end Data_Logger;
