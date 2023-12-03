/*-----------------------------------------------------------------------------------------*
    The following is a test of a SAS macro to obtain the URI of a folder in SAS Content,
    or to provide an indication that it exists.
 
    Inputs:
       - targetFolderContent: Provide full path of a folder inside SAS Content to check for
 
    Outputs:
       - targetFolderURI (global variable): set inside macro to the URI of the folder
       - contentFolderExists (global variable): set to 0 if the folder does not exist, 1 if
         it does, and 99 in case of other conditions (such as HTTP request failure). 
         Note this is a side objective / additional objective of the current macro.
*------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------*
   Provide inputs here. Make sure you enclose the same in quotes
*------------------------------------------------------------------------------------------*/
%let targetFolderContent="/Public/Adult_Census_Study";


/*-----------------------------------------------------------------------------------------*
   Check this condition: what if you had already declared two macro variables corresponding 
   to the output of the global macro variables created within?
*------------------------------------------------------------------------------------------*/
/* %global targetFolderURI;
%global contentFolderExists; */

/*-----------------------------------------------------------------------------------------*
   Run test
*------------------------------------------------------------------------------------------*/
%_obtain_sas_content_folder_uri(&targetFolderContent.);

/*-----------------------------------------------------------------------------------------*
   Examine outputs
*------------------------------------------------------------------------------------------*/
%put NOTE: The URI for &targetFolderContent. is &targetFolderURI.;
%put NOTE: The flag to indicate the folder exists is &contentFolderExists.;

