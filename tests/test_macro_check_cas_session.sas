
/* -----------------------------------------------------------------------------------------* 
   Test of macro to check for an active CAS session.

   Given a currently active CAS session in SAS Studio, when the macro is run with a specified error 
   flag, then a global macro variable is set along with an informational note.
   
*------------------------------------------------------------------------------------------ */
cas ss;

%global error_flag;

%let error_flag=0;

filename getsasf URL "https://raw.githubusercontent.com/SundareshSankaran/sas_utility_programs/main/code/Check_Active_CAS_session/macro_check_active_cas_connection.sas";
%include getsasf;
filename getsasf clear;


%_env_cas_checkSession("error_flag");

%put &error_flag.;

%put &_current_uuid_.;

cas ss terminate;