with Ada.Text_IO; use Ada.Text_IO;
with Simulation; use Simulation;

package Data_Logger is

   -- Initializes the CSV file and writes the header row
   procedure Init_Log (File : in out File_Type; File_Name : String);

   -- Writes a single simulation state as a row in the CSV
   procedure Log_State (File : in File_Type; Current : State; Thrust, Mass : Float);

   -- Closes the CSV file
   procedure Close_Log (File : in out File_Type);

end Data_Logger;
