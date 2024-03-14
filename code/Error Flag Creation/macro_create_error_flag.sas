/* -----------------------------------------------------------------------------------------* 
   Macro to create an error flag for capture during code execution.

   Input:
      1. errorFlagName: The name of the error flag you wish to create. Ensure you provide a 
         unique value to this parameter since it will be declared as a global variable.
      2. errorFlagDesc: The name of an error flag description variable to hold the error 
         description.

    Output:
      1. &errorFlagName : A global variable which takes the name provided to errorFlagName.
      2. &errorFlagDesc : A global variable which takes the name provided to errorFlagDesc.

*------------------------------------------------------------------------------------------ */



%macro _create_error_flag(errorFlagName, errorFlagDesc);

   %global &errorFlagName.;
   %global &errorFlagDesc.;
   %let &errorFlagName.=0;
   %let &errorFlagDesc. = No errors reported so far;

%mend _create_error_flag;
