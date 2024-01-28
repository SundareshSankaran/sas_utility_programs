 # Check for Python
 
 Macro to check whether Python is available to the compute session where this program runs.
   Identification done through the PROC_PYPATH environment variable. If Python is found, a macro 
   variable is created with the path.  If not, an error message is output and an error flag 
   specified by user is flagged with a 1 (to indicate an error).  Flag can be used in downstream
   code if specified as a global variable.

   Input:
   1. errorFlagName: Provide this with quotes when executing the macro. Name of an error flag macro 
                     variable. Specify this variable as global so that it can be used downstream.

   Output:
   1. PROC_PYPATH : A global variable which contains the path where Python can be found.
   2. Informational or error message as applicable written to log.
   3. errorFlagName macro variable modified if necessary.

   Sundaresh Sankaran, 26JAN2024