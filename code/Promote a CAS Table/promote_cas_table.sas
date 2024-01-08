/* -----------------------------------------------------------------------------------------* 
   Macro to promote a CAS table.

   Inputs:
   1. casLib: A valid caslib.
   2. casTable: A name of a CAS table.

   Output:
   - Successful promotion of a CAS table to global scope
     
*------------------------------------------------------------------------------------------ */

%macro _promote_cas_table(casLib, casTable, targetCaslib, targetTable);
   
   proc cas;

      function doesTableExist(_casLib, _casTable);
         table.tableExists result=tableExistsResultTable status=rc / 
            caslib = _casLib, 
            table  = _casTable;
         tableExists = dictionary(tableExistsResultTable, "exists");
         print tableExists;
         return tableExists;
      end;

      function dropTableIfExists(casLib,casTable);
         print "Entering dropTableIfExists";
         print casLib;
         tableExists = doesTableExist(casLib, casTable);
         if tableExists != 0 then do;
            print "Dropping table: "||casLib||"."||casTable;
            table.dropTable status=rc / caslib=casLib, table=casTable, quiet=True;
            if rc.statusCode != 0 then do;
               exit();
            end;
            dropTableIfExists(casLib, casTable);
         end;
      end;

      function promoteTable(casLib, casTable, targetCaslib, targetTable);         
         table.promote /
            target       = targetTable,
            targetcaslib = targetCaslib,
            name         = casTable,
            caslib       = casLib
          ; 
      end;

      dropTableIfExists("&targetCaslib.", "&targetTable.");
      promoteTable("&casLib.","&casTable.", "&targetCaslib.", "&targetTable.");

   quit;

%mend _promote_cas_table;