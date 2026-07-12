with Motors; use Motors;

package Motors_Parser is

   -- Parses a standard RASP (.eng) motor file and populates a Motor_Type
   procedure Load_Motor (File_Name : String; Motor : out Motor_Type);

end Motors_Parser;
