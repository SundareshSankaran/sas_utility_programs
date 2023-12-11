
%macro _get_sas_content_folder_uri(targetFolderContent);

/*-----------------------------------------------------------------------------------------*
    Macro to obtain the URI of a desired SAS Content folder if it exists.
    This macro will check a given path in SAS Content and set a macro variable to folder URI 
    if it exists, or a direction to the error code if not.
 
    Inputs:
       - targetFolderContent: the full path of the folder to check for
 
    Outputs:
       - targetFolderURI (global variable): set inside macro to the URI of the folder
       - contentFolderExists (global variable): set to 0 if the folder does not exist, 1 if
         it does, and 99 in case of other conditions (such as HTTP request failure). 
         Note this is a side objective / additional objective of the current macro.
*------------------------------------------------------------------------------------------*/

   %global targetFolderURI;
   %global contentFolderExists;

   /*-----------------------------------------------------------------------------------------*
     Create a JSON payload containing the folder to check for.
   *------------------------------------------------------------------------------------------*/
   %local targetPathJSON;

   data _null_;
      call symput("targetPathJSON",'{"items": ['||'"'||transtrn(strip(transtrn(&targetFolderContent.,"/","   ")),"   ",'","')||'"'||'], "contentType": "folder"}');
   run;

   filename pathData temp;
   filename outResp temp;

   data _null_;
      length inputData $32767.;
      inputData = symget("targetPathJSON");
      file pathData;
	  put inputData;
   run;

   /*-----------------------------------------------------------------------------------------*
     Call the /folders/paths endpoint to obtain the URI of the desired folder.
   *------------------------------------------------------------------------------------------*/
   %local viyaHost;
   %let viyaHost=%sysfunc(getoption(SERVICESBASEURL));

   %put NOTE: The Viya host resolves to &viyaHost.;

   proc http
	  method='POST'
	  url="&viyaHost./folders/paths"
	  in=pathData 
	oauth_bearer=sas_services
	/* out=outResp; */
    ;
	headers 'Content-Type'='application/vnd.sas.content.folder.path+json';
   quit;
   
   /*-----------------------------------------------------------------------------------------*
     In the event of a successful request, extract the URI
   *------------------------------------------------------------------------------------------*/

   %if "&SYS_PROCHTTP_STATUS_CODE."="200" %then %do;
      filename TEMPFNM filesrvc folderpath=&targetFolderContent.;

    /*-----------------------------------------------------------------------------------------*
      The Filename Filesrvc leads to an automatic macro variable which holds the URI.  This 
      will be assigned to the global variable.
    *------------------------------------------------------------------------------------------*/
      data _null_;
	     call symput("targetFolderURI", "&_FILESRVC_TEMPFNM_URI.");
         call symputx("contentFolderExists", 1);
      run;

      filename TEMPFNM clear;
      %symdel _FILESRVC_TEMPFNM_URI;

   %end;
   %else %do;
      data _null_;
         call symput("targetFolderURI", "Refer SYS_PROCHTTP_STATUS_CODE macro variable.");
      run;
      /*-----------------------------------------------------------------------------------------*
         Note that this macro also doubles up as a check for a desired folder inside 
         SAS Content.  While it's desirable to have separate code/macros for every single desired 
         operation, we are adding this additional output because it does not require significant 
         computation (beyond the code below).
      *------------------------------------------------------------------------------------------*/
      %if "&SYS_PROCHTTP_STATUS_CODE."="404" %then %do;
         %put NOTE: Folder is not found. ;
         data _null_;
            call symputx("contentFolderExists",0);
         run;
      %end;
      %else %do;
         %put NOTE: The HTTP request returned &SYS_PROCHTTP_STATUS_CODE. ;
         data _null_;
            call symputx("contentFolderExists",99);
         run;
      %end;
   %end;

%mend _get_sas_content_folder_uri;