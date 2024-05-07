filename ORSASCAS url "https://raw.githubusercontent.com/SundareshSankaran/sas_utility_programs/main/code/sas_or_cas/macro_sas_or_cas.sas";
%include ORSASCAS;
filename ORSASCAS clear;

/*-----------------------------------------------------------------------------------------*
  With a SAS libref
*------------------------------------------------------------------------------------------*/

%let engineName=;
%let error_flag = 0;
%let error_desc = ;

%_sas_or_cas(SASHELP,engineName, error_flag, error_desc, 0);

%put NOTE: Engine is &engineName.;
%put NOTE: Error flag is &error_flag with desc &error_desc.;

/*-----------------------------------------------------------------------------------------*
  With a CAS libref
*------------------------------------------------------------------------------------------*/

%let engineName=;
%let error_flag = 0;
%let error_desc = ;

cas ss;
caslib _ALL_ assign;

%_sas_or_cas(PUBLIC,engineName, error_flag, error_desc, 1);

cas CASAUTO terminate;

%put NOTE: Engine is &engineName.;
%put NOTE: Error flag is &error_flag with desc &error_desc.;
