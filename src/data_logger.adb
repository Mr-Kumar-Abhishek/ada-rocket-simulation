with Ada.Text_IO; use Ada.Text_IO;

package body Data_Logger is

   procedure Init_Log (File : in out File_Type; File_Name : String) is
   begin
      Create (File, Out_File, File_Name);
      -- Write CSV Header
      Put_Line (File, "Time(s),Position_X(m),Position_Y(m),Position_Z(m),Velocity_Y(m/s),Thrust(N),Mass(kg),Orientation_W,Orientation_X,Orientation_Y,Orientation_Z");
   end Init_Log;

   procedure Log_State (File : in File_Type; Current : State; Thrust, Mass : Float) is
   begin
      Put_Line (File,
         Float'Image(Current.Time) & "," &
         Float'Image(Current.Position.X) & "," &
         Float'Image(Current.Position.Y) & "," &
         Float'Image(Current.Position.Z) & "," &
         Float'Image(Current.Velocity.Y) & "," &
         Float'Image(Thrust) & "," &
         Float'Image(Mass) & "," &
         Float'Image(Current.Orientation.W) & "," &
         Float'Image(Current.Orientation.X) & "," &
         Float'Image(Current.Orientation.Y) & "," &
         Float'Image(Current.Orientation.Z));
   end Log_State;

   procedure Close_Log (File : in out File_Type) is
   begin
      if Is_Open (File) then
         Close (File);
      end if;
   end Close_Log;

end Data_Logger;
