with Components; use Components;

package Parser is

   --  Load a single top-level component
   --  (e.g. Nose_Cone or Body_Tube) from a raw XML file
   --  Note: In a full implementation, this would return a Component tree.
   procedure Load_Rocket
     (File_Name : String;
      Rocket    : out Component_Access);

end Parser;
