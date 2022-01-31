/*****************************************************************************
* Project : BIOS 511 Course
*
* Program name : lab-09-730235682-Task2
*
* Author : Junjie Zhou
*
* Date created : 10/29/2019
*
* Purpose : Advance Dataset Programming and Creating Graphs in SAS
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
%let lab = Lab 09;
%let dataPath = &root/data/Echo;
%let outPath = &root/Lab/&lab./output;
libname lab9data "&dataPath." access=read;
libname data "&root/Lab/&lab./Data" access=read;

/*********************************************************************
                        SAS Code for Task # 2 / Step # 1
 *********************************************************************/

ods pdf file = "&outPath./lab-09-730235682-output.pdf";
ods graphics / height=4.5in width=8in;

data lb;
	set data.adlb2 (in=b);	
	output;
	country='A';
	output;
run;

data lbsorted;
	set lb;
	if lbblfl='Y' then
	week='Baseline';
	else if visit='Week 16' then
	week='Week 16';
	else if visit='Week 32' then
	week='Week 32';
run;

proc means data=lbsorted nway noprint;
	class armcd arm country lbtestcd week;
	var pct_change;
	output out=lb2(drop=_type_) n(pct_change)=n
	mean(pct_change)=meandiff std(pct_change)=stddiff;
run;

data lbmean;
	set lb2;
	low=meandiff-(2*stddiff);
	high=meandiff+(2*stddiff);
run;

proc format;
	value $cty
	'A'='Overall'
	'CAN'='Canada'
	'MEX'='Mexico'
	'USA'='United States';
run;
/* Albumin Graph */
title 'Plot of Percent Change in Albumin by Treatment Group';
title2 'Mean +/- Two Standard Deviations';
proc sgpanel data=lbmean (where=(lbtestcd='ALB'));
	format country $cty.;
	label high='Percent Change from Baseline';
	panelby country / rows=1 onepanel;
	highlow x=week low=low high=high / group=armcd groupdisplay=cluster 
	clusterwidth=0.2 highcap=serif lowcap=serif;
	series x=week y=meandiff / group=armcd;
	scatter x=week y=meandiff / group=armcd markerattrs=(symbol=circlefilled size=10)
	groupdisplay=cluster clusterwidth=0.2;
	colaxis label='Visit Name';
	colaxistable n / class=armcd;
run;
/* Calcium Graph */
title 'Plot of Percent Change in Calcium by Treatment Group';
title2 'Mean +/- Two Standard Deviations';
proc sgpanel data=lbmean (where=(lbtestcd='CA'));
	format country $cty.;
	label high='Percent Change from Baseline';
	panelby country / rows=1 onepanel;
	highlow x=week low=low high=high / group=armcd groupdisplay=cluster 
	clusterwidth=0.2 highcap=serif lowcap=serif;
	series x=week y=meandiff / group=armcd;
	scatter x=week y=meandiff / group=armcd markerattrs=(symbol=circlefilled size=10)
	groupdisplay=cluster clusterwidth=0.2;
	colaxis label='Visit Name';
	colaxistable n / class=armcd;
run;
/* Hematocrit Graph */
title 'Plot of Percent Change in Hematocrit by Treatment Group';
title2 'Mean +/- Two Standard Deviations';
proc sgpanel data=lbmean (where=(lbtestcd='HCT'));
	format country $cty.;
	label high='Percent Change from Baseline';
	panelby country / rows=1 onepanel;
	highlow x=week low=low high=high / group=armcd groupdisplay=cluster 
	clusterwidth=0.2 highcap=serif lowcap=serif;
	series x=week y=meandiff / group=armcd;
	scatter x=week y=meandiff / group=armcd markerattrs=(symbol=circlefilled size=10)
	groupdisplay=cluster clusterwidth=0.2;
	colaxis label='Visit Name';
	colaxistable n / class=armcd;
run;

ods pdf close;




