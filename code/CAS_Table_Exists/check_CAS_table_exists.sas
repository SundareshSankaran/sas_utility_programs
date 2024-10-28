/*-----------------------------------------------------------------------------------------*
   Macro to check if an in-memory table exists.

   Input:
   1. tableName: name of the in-memory table
   2. tableLib: caslib backing the in-memory table
   3. sessionExists: an indicator (1) whether an active CAS session exists.  If not(0),
                     it will be created.
                     
   Output:
   1. tableExists: populated with 0 if does not exist, 1 if exists with local scope, 
                   2 if exists with global scope

*------------------------------------------------------------------------------------------*/   
%macro _cas_table_exists(tableName, tableLib, sessionExists, tableExists);

   %if &sessionExists. = 0 %then %do;
      cas _temp_ss_ ;
      caslib _ALL_ assign;
   %end;

   proc cas;
      table.tableExists result = rc /
         name="&tableName.",
         caslib="&tableLib."
      ;
      call symputx("&tableExists.",rc.exists);
   quit;

   %if &sessionExists. = 0 %then %do;
      cas _temp_ss_ terminate;
   %end;
    
%mend _cas_table_exists;