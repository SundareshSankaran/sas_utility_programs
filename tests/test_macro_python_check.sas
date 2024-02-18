
/* -----------------------------------------------------------------------------------------* 
   Test of macro to check whether Python is available in a compute session.

   Given a SAS Compute session with Python installed, when the _env_check_python macro is run with a specified error 
   flag, then a global macro variable is set along with an informational note.
   
*------------------------------------------------------------------------------------------ */

%global error_flag;
%global error_desc;

filename getsasf URL "https://raw.githubusercontent.com/SundareshSankaran/sas_utility_programs/main/code/Check_For_Python/macro_python_check.sas";
%include getsasf;
filename getsasf clear;


%_env_check_python("error_flag","error_desc");

%put &error_flag.;
%put &error_desc.;

%put &PROC_PYPATH.;
