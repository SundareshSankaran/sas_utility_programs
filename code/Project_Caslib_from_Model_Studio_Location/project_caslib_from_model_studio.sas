/* -----------------------------------------------------------------------------------------* 
   Macro to split the Model Studio Project location and obtain the caslib portion for 
   downstream use.

   Input:
   1. projectLocation: A string provided by a text field in  a SAS Studio Custom step.
     

   Output:
   1. analyticsProjectCaslib: Set inside macro, a global variable indicating the caslib portion
      of the model studio path.

*------------------------------------------------------------------------------------------ */

%macro _extract_caslib_from_ms_location(projectLocation);

   %global analyticsProjectCaslib;

   data _null_;
      if index("&projectLocation.","/") > 0 then do;
         call symput("analyticsProjectCaslib",scan("&projectLocation.",2,"/","MO"));
      end;
      else do;
         call symput("analyticsProjectCaslib","&projectLocation.");
      end;
   run;

   %put NOTE: The macro variable analyticsProjectCaslib resolves to: &analyticsProjectCaslib.;

%mend _extract_caslib_from_ms_location;