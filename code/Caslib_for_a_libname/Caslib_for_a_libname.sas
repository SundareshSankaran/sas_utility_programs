/*-----------------------------------------------------------------------------------------*
   Caslib for a Libname macro
   
   This macro creates a global macro variable called _usr_nameCaslib
   that contains the caslib name (aka. caslib-reference-name) associated with the libname
   and assumes that the libname is using the CAS engine.
 
   As sysvalue has a length of 1024 chars, we use the trimmed option in proc sql
   to remove leading and trailing blanks in the caslib name.
   
   From macro provided by Wilbram Hazejager (wilbram.hazejager@sas.com)

   Inputs:
   - _usr_LibrefUsingCasEngine : A library reference provided by the user which is based 
                                 on a CAS engine.
   
   Outputs:
   - _usr_nameCaslib : Global macro variable containing the caslib name.
*------------------------------------------------------------------------------------------*/
 
%macro _usr_getNameCaslib(_usr_LibrefUsingCasEngine);
 
   %global _usr_nameCaslib;
   %let _usr_nameCaslib=;
 
   proc sql noprint;
      select sysvalue into :_usr_nameCaslib trimmed from dictionary.libnames
      where libname = upcase("&_usr_LibrefUsingCasEngine.") and upcase(sysname)="CASLIB";
   quit;

   /*--------------------------------------------------------------------------------------*
      Note that we output a NOTE instead of an ERROR for the below condition since the 
      execution context determines whether this is an error or just an informational note.
   *---------------------------------------------------------------------------------------*/
   %if "&_usr_nameCaslib." = "" %then %put NOTE: The caslib name for the &_usr_LibrefUsingCasEngine. is blank.;
 
%mend _usr_getNameCaslib;