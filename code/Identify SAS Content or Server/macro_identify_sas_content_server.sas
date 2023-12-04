/* -----------------------------------------------------------------------------------------* 
   Macro to identify whether a given location provided from a 
   SAS Studio Custom Step file or folder selector happens to be a SAS Content folder
   or a folder on the filesystem (SAS Server).
   
   Inputs:
      1. pathReference: A path as provided by the user to a SAS Studio Custom Step file or 
         folder selector control.
   
   Outputs:
      2. _path_identifier: A global macro variable, declared within the macro, which holds
         either sascontent or sasserver given the user's input.
*------------------------------------------------------------------------------------------ */
%macro _identify_content_or_server(pathReference);
   %global _path_identifier;
   data _null_;
      call symput("_path_identifier", scan(&pathReference.,1,":","MO"));
   run;
%mend _identify_content_or_server;