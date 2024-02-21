/* ------------------------------------------------------------------------------------------------* 
   Macros (set of three) to check whether a path to Python is available to a compute or batch
   session where this program runs.  The following steps are taken to identify this:

   - First, determine whether it's a batch or compute session (can be skipped if you know the same)

   and then,

   i.   Check for a value in the PROC_PYPATH environment variable.
   ii.  Check if the directory referred within the path actually exists.
   iii. Finally, check a number of LOCKDOWN options for any restrictions to using Python.

   In the event of all checks passing, a PROC_PYPATH macro variable (this is different from 
   the system option) is created with the path.  If not, an error message is output and an  
   error flag specified by user is flagged with a 1 (to indicate an error).  Flag can be used 
   in downstream code if specified as a global variable.

   Note: This is still not a foolproof way to check if a **valid** Python environment is available,
   for certain reasons.  One, there is no check to see if the Python executable is operational.
   Also, even if a valid path to Python exists within the compute session, additional permissions
   specified for some SAS Cloud Analytics Services (CAS) routines and settings (as defined in an 
   external language settings file) may result in Python not being accessible for a user or group.

   A preference: I like to avoid having to explicitly raise an ERROR (i.e. %put ERROR:) within 
   a macro.  In a world with alternatives and workarounds, I'd rather just raise a note 
   indicating the status and the calling / execution code decides what to do.  Your preference
   may vary, so feel free to modify the code if you'd like to.

   Input:
   1. errorFlagName: Provide this within quotes when executing the macro. Name of an error flag macro 
                     variable. Specify this variable as global so that it can be used downstream.
   2. errorFlagDesc: A reference to a macro variable, provided within quotes when calling the macro,  
                     which holds any description of the check that has occurred. Specify this 
                     variable as global so that it can be used downstream.

   Output:
   1. PROC_PYPATH : A global variable containing the path where Python can be found. Note that this is 
                    different from the PROC_PYPATH compute session system option /environment variable.
   2. errorFlagDesc: Informational or error message as applicable written to a specified macro variable.
   3. errorFlagName: Populated specified macro variable with 1 (in case of errors) or 0.

   Sundaresh Sankaran, 20FEB2024
*----------------------------------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------------------------------* 
   This macro carries out the check in a Compute server.  If you already know you are running this 
   code in a Compute server session, you can call the %_env_check_python_compute macro directly.
*----------------------------------------------------------------------------------------------- */


%macro _env_check_python_compute(errorFlagName, errorFlagDesc);

   data _null_;
      /* ----------------------------------------------------------------------------------------------* 
         Obtain system options and store them inside macro variables.
      *----------------------------------------------------------------------------------------------- */
      proc_pypath = sysget('PROC_PYPATH');
      viya_lockdown_user_methods = sysget('VIYA_LOCKDOWN_USER_METHODS');
      compute_enable = sysget('COMPUTESERVER_LOCKDOWN_ENABLE');
      does_file_at_pypath_exist=fileexist(proc_pypath);

      /* ----------------------------------------------------------------------------------------------* 
         Let's start from the end
         Check if PROC_PYPATH exists
      *----------------------------------------------------------------------------------------------- */

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
            /* -----------------------------------------------------------------------------------------* 
               Check if COMPUTESERVER_LOCKDOWN_ENABLE = 0, indicating a permissive (and potentially 
               insecure) environment.
            *------------------------------------------------------------------------------------------ */
            if compute_enable = '1' then do;
               /* --------------------------------------------------------------------------------------* 
                  Check if PYTHON and SOCKET appear in viya_lockdown_user_methods.
                  There's an additional PYTHON_EMBED option which is included as a strict check (enabling 
                  Python to run in a submit block).
               *--------------------------------------------------------------------------------------- */
               if index(lowcase(viya_lockdown_user_methods),"python") > 0 and index(lowcase(viya_lockdown_user_methods),"socket") > 0 and index(lowcase(viya_lockdown_user_methods),"python_embed") > 0 then do;
                  call symput("PROC_PYPATH", proc_pypath);
                  call symputx(&errorFlagName.,0);
                  call symput(&errorFlagDesc., "A path to Python is available in this compute session and Python use is part of Viya enabled methods.") ;
               end;
               else do;
                  call symputx(&errorFlagName.,1);
                  call symput(&errorFlagDesc., "Required access methods to run Python don't seem to form part of the user methods allowed in Viya. Please take steps to enable PYTHON, PYTHON_EMBED and SOCKET");             
               end;
            end;
            else do;
               call symput("PROC_PYPATH", proc_pypath);
               call symputx(&errorFlagName.,0);
               call symput(&errorFlagDesc., "A path to Python is available in this compute session and COMPUTESERVER_LOCKDOWN_ENABLE is disabled. While you can run Python, note that setting COMPUTESERVER_LOCKDOWN_ENABLE to 0 is not recommended.");
            end;
         end;
      end;
   run;
%mend _env_check_python_compute;

/* ----------------------------------------------------------------------------------------------* 
   This macro carries out the check in a Batch server.  If you already know you are running this 
   code in a Batch server session, you can call the %_env_check_python_batch macro directly.
*----------------------------------------------------------------------------------------------- */

%macro _env_check_python_batch(errorFlagName, errorFlagDesc);

   %put NOTE: Entering Batch server Python check;

   data _null_;
      /* ----------------------------------------------------------------------------------------------* 
         Obtain system options and store them inside macro variables.
      *----------------------------------------------------------------------------------------------- */
      proc_pypath = sysget('PROC_PYPATH');
      viya_lockdown_user_methods = sysget('VIYA_LOCKDOWN_USER_METHODS');
      batch_enable = sysget('BATCHSERVER_LOCKDOWN_ENABLE');
      does_file_at_pypath_exist=fileexist(proc_pypath);

      /* ----------------------------------------------------------------------------------------------* 
         Let's start from the end
         Check if PROC_PYPATH exists
      *----------------------------------------------------------------------------------------------- */

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
            /* -----------------------------------------------------------------------------------------* 
               Check if BATCHSERVER_LOCKDOWN_ENABLE = 0, indicating a permissive (and potentially 
               insecure) environment.
            *------------------------------------------------------------------------------------------ */
            if batch_enable = '1' then do;
               /* --------------------------------------------------------------------------------------* 
                  Check if PYTHON and SOCKET appear in viya_lockdown_user_methods.
                  There's an additional PYTHON_EMBED option which is included as a strict check (enabling 
                  Python to run in a submit block).
               *--------------------------------------------------------------------------------------- */
               if index(lowcase(viya_lockdown_user_methods),"python") > 0 and index(lowcase(viya_lockdown_user_methods),"socket") > 0 and index(lowcase(viya_lockdown_user_methods),"python_embed") > 0 then do;
                  call symput("PROC_PYPATH", proc_pypath);
                  call symputx(&errorFlagName.,0);
                  call symput(&errorFlagDesc., "A path to Python is available in this batch session and Python use is part of Viya enabled methods.") ;
               end;
               else do;
                  call symputx(&errorFlagName.,1);
                  call symput(&errorFlagDesc., "Required access methods to run Python don't seem to form part of the user methods allowed in Viya. Please take steps to enable PYTHON, PYTHON_EMBED and SOCKET");             
               end;
            end;
            else do;
               call symput("PROC_PYPATH", proc_pypath);
               call symputx(&errorFlagName.,0);
               call symput(&errorFlagDesc., "A path to Python is available in this batch session and BATCHSERVER_LOCKDOWN_ENABLE is disabled. While you can run Python, note that setting BATCHSERVER_LOCKDOWN_ENABLE to 0 is not recommended.");
            end;
         end;
      end;
   run;
%mend _env_check_python_batch;

/* ----------------------------------------------------------------------------------------------* 
   The %_env_check_python macro can be considered the main macro which first identifies the type of
   SAS session (Compute or Batch) and calls the appropriate macro to check for Python.
*----------------------------------------------------------------------------------------------- */

%macro _env_check_python(errorFlagName, errorFlagDesc);
    
   %global PROC_PYPATH;

   %if %index(%lowcase(&SYSPROCESSMODE),compute) > 0 %then %do;

      %put NOTE: This session is running in a Compute server;
      %_env_check_python_compute(&errorFlagName, &errorFlagDesc);

   %end;
   %else %if %index(%lowcase(&SYSPROCESSMODE),batch) > 0 %then %do;

      %put NOTE: This session is running in a Batch server;
      %_env_check_python_batch(&errorFlagName, &errorFlagDesc);

   %end;


 %mend _env_check_python;
 
