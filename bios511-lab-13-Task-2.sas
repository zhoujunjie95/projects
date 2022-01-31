/*****************************************************************************
* Project : BIOS 511 Course
*
* Program name : lab-13-Task-2-730235682
*
* Author : Junjie Zhou
*
* Date created : 11/26/2019
*
* Purpose : Advanced Data Step and Macro Programming
*
* Revision History :
*
* Date Author Ref (#) Revision
*
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/

option mergenoby=error nodate nonumber;
ods noproctitle;
%let root = /folders/myshortcuts/BIOS511;
%let lab = Lab 13;
%let data = &root/data/echo;
%let dataPath = &root/Lab/&lab./data;
%let outPath = &root/Lab/&lab./output;
%let macroPath = &root/lab/&lab./macros;
libname data "&dataPath." access=read;
libname out "&dataPath." access=read;
libname echo "&data." access=read;

/*********************************************************************
                        SAS Code for Task # 2 / Step # 1
 *********************************************************************/

%include "&macroPath./codebook.sas";

ods pdf file="&outPath./adsl-codebook-730235682.pdf" style=sasweb;
	%codebook(lib=out,ds=adsl,maxVal=4);
ods pdf close;

ods pdf file="&outPath./dm-codebook-730235682.pdf" style=sasweb;
	%codebook(lib=echo,ds=dm);
ods pdf close;

















