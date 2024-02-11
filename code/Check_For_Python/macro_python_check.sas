/* -------------------------------------------------------------------------------------------* 
   Macro to check whether a path to Python is available to the compute session where this 
   program runs.  The following steps are taken to identify this:
   i.   Check for a value in the PROC_PYPATH environment variable.
   ii.  Check if the directory referred within the path actually exists.
   iii. Finally, check a number of LOCKDOWN options for any restrictions to using Python.

   In the event of all checks passing, a PROC_PYPATH macro variable (this is different from 
   the system option) is created with the path.  If not, an error message is output and an  
   error flag specified by user is flagged with a 1 (to indicate an error).  Flag can be used 
   in downstream code if specified as a global variable.

   A preference: I like to avoid having to explicitly raise an ERROR (i.e. %put ERROR:) within 
   a macro.  In a world with many alternatives and workarounds, I'd rather just raise a note 
   indicating the status and the calling / execution code decides what to do.  Your preference
   may vary, so feel free to modify below if you'd like to.

   Input:
   1. errorFlagName: Provide this with quotes when executing the macro. Name of an error flag macro 
                     variable. Specify this variable as global so that it can be used downstream.
   2. errorFlagDesc: A reference to a macro variable, provided within quotes, which holds any 
                     description of the check that has occurred. Specify this variable as global 
                     so that it can be used downstream.

   Output:
   1. PROC_PYPATH : A global variable containing the path where Python can be found. Note that this is 
                    different from the PROC_PYPATH compute session system option /environment variable.
   2. errorFlagDesc: Informational or error message as applicable written to a specified macro variable.
   3. errorFlagName: Populated specified macro variable with 1 (in case of errors) or 0.

   Sundaresh Sankaran, 07FEB2024
*-------------------------------------------------------------------------------------------- */

%macro _env_check_python(errorFlagName);
    
    %global PROC_PYPATH;

    data _null_;
      proc_pypath = sysget('PROC_PYPATH');
      viya_lockdown_user_methods = sysget('VIYA_LOCKDOWN_USER_METHODS');
      compute_enable = sysget('COMPUTESERVER_LOCKDOWN_ENABLE');
      viya_lockdown_disable = sysget('VIYA_LOCKDOWN_USER_DISABLED_METHODS');
      does_file_at_pypath_exist=fileexist(proc_pypath);

      /* -------------------------------------------------------------------------------------------* 
         Let's start from the end
         Check if PROC_PYPATH exists
      *-------------------------------------------------------------------------------------------- */

       if proc_pypath = "" then do;
          call symputx(&errorFlagName.,1);
          call symput(&errorFlagDesc., "PROC_PYPATH environment variable not populated, indicating that Python may not have been configured.");
       end;
       else do;
          /* -------------------------------------------------------------------------------------------* 
             Check if PROC_PYPATH points to a valid file
          *-------------------------------------------------------------------------------------------- */
          if does_file_at_pypath_exist = 0 then do;
             call symputx(&errorFlagName.,1);
             call symput(&errorFlagDesc., "The file referred by PROC_PYPATH does not exist, indicating path to Python may have been configured incorrectly.");             
          end;
          else do;
             /* -------------------------------------------------------------------------------------* 
                Check if COMPUTESERVER_LOCKDOWN_ENABLE = 0 indicates a free for all
                or a permissive (and potentially insecure) environment.
             *-------------------------------------------------------------------------------------- */
             if compute_enable = 1 then do;
                /* -------------------------------------------------------------------------------------* 
                   Check if PYTHON and SOCKET appear in viya_lockdown_user_methods.
                   There's an additional PYTHON_EMBED option which is included as a strict check (enabling 
                   Python to run in a submit block.
                *-------------------------------------------------------------------------------------- */
                if index(lowcase(viya_lockdown_user_methods),"python") > 0 and index(lowcase(viya_lockdown_user_methods),"socket") > 0 and index(lowcase(viya_lockdown_user_methods),"python_embed") > 0 then do;
                   /* --------------------------------------------------------------------------------* 
                      Final check: if Python has been explicitly disabled as an access method in Viya
                   *-------------------------------------------------------------------------------- */
                   if index(lowcase(viya_lockdown_disable),"python") = 0 and index(lowcase(viya_lockdown_disable),"socket") = 0 then do;
                      %put NOTE: A path to Python is available in this compute session and Python use is not locked down. ;
                      call symput("PROC_PYPATH", proc_pypath);
                      call symputx(&errorFlagName.,0);
                   end;
                   else do;
                      call symputx(&errorFlagName.,1);
                      call symput(&errorFlagDesc., "Required access methods to run Python are part of VIYA_LOCKDOWN_USER_DISABLED_METHODS. Take steps to enable them.");             
                   end;
                end;
                else do;
                   call symputx(&errorFlagName.,1);
                   call symput(&errorFlagDesc., "Required access methods to run Python don't seem to form part of the user methods allowed in Viya. Please take steps to enable PYTHON, PYTHON_EMBED and SOCKET");             
                end;
             end;
             else do;
                call symputx(&errorFlagName.,0);
                call symput(&errorFlagDesc., "A path to Python is available in this compute session and LOCKDOWN is completely disabled.");
             end;
         end;
       end;
    run;

 %mend _env_check_python;
 
