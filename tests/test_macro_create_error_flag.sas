
/* -----------------------------------------------------------------------------------------* 
   Test of macro to create an error flag for capture during code execution.

   Given the _create_error_flag macro, when a name is provided as a literal, then a global  
   SAS macro variable is created with the same name and its value set to 0.
*------------------------------------------------------------------------------------------ */

filename getsasf URL "https://raw.githubusercontent.com/SundareshSankaran/sas_utility_programs/main/code/Error%20Flag%20Creation/macro_create_error_flag.sas";
%include getsasf;
filename getsasf clear;

%_create_error_flag(_new_error_flag);

%put NOTE: Value of _new_error_flag is &_new_error_flag.;

%let _new_error_flag = 1;

%put NOTE: Value of _new_error_flag is &_new_error_flag.;

