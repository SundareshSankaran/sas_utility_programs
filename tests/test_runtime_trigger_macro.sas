
/* -----------------------------------------------------------------------------------------* 
   Test of macro to create a global macro for facilitating a runtime trigger.

   Given a _create_runtime_trigger macro, when the macro is called 
   with &triggerName., then a global macro variable of name &triggerName. is initialized 
   with a value of 1
*------------------------------------------------------------------------------------------ */

filename getsasf URL "https://raw.githubusercontent.com/SundareshSankaran/sas_utility_programs/main/code/Create_Run_Time_Trigger/macro_create_runtime_trigger.sas";
%include getsasf;
filename getsasf clear;

%_create_runtime_trigger(_new_runtime_t);

%put NOTE: Value of _new_runtime_t is &_new_runtime_t.;

%let _new_runtime_t = 1;

%put NOTE: Value of _new_runtime_t is &_new_runtime_t.;

