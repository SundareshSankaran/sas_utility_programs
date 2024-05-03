/*-----------------------------------------------------------------------------------------*
   Macro to check if a given libref belongs to a SAS or CAS engine.

   Input:
   1. sasCasLibref: a libref to be checked. Do not quote.
   2. tableEngine: a flag to hold the table Engine value.
   3. errorFlagName: a flag to populate an error code with
   4. errorFlagDesc: a flag to describe the error if one occurs.
                     
   Output:
   1. tableEngine: populated with SAS or CAS
   2. errorFlagName: populated with 1 if an error and 0 if not
   3. errorFlagDesc: populated in case of an error
*------------------------------------------------------------------------------------------*/

%macro sas_or_cas(sasCasLibref, tableEngine, errorFlagName, errorFlagDesc);

    cas ss;
    caslib _ALL_ assign;

    proc sql noprint;
        select distinct Engine into:tableEngine from dictionary.libnames where libname = upcase("sashelp");
    quit;

    %if %sysfunc(compress("&tableEngine.")) = "V9" %THEN %DO;
        data _null_;
            call symput("tableEngine","SAS");
            call symputx("errorFlag",0);
            call symput("errorFlagDesc","")
        run;
    %end;
    %else %if %sysfunc(compress("&tableEngine.")) = "CAS" %THEN %DO;
        data _null_;
            call symputx("errorFlag",0);
            call symput("errorFlagDesc","")
        run;
    %END;
    %else %do;
        data _null_;
            call symputx("errorFlag",1);
            call symput("errorFlagDesc","Unable to associate libref with either SAS or CAS. Check the input libref provided.")
        run;
    %end;

    cas ss terminate;

%mend sas_or_cas;
