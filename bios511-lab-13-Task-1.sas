/*****************************************************************************
* Project : BIOS 511 Course
*
* Program name : lab-13-Task-1-730235682
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
%let dataPath = &root/data/Echo;
%let outPath = &root/Lab/&lab./output;
%let data = &root/lab/&lab./data;
libname lb13data "&dataPath." access=read;
libname data "&data";

/*********************************************************************
                        SAS Code for Task # 1 / Step # 1
 *********************************************************************/

proc format;
	value $cfmt
	'CAN'='Canada'
	'MEX'='Mexico'
	'USA'='United States';
run;

data dm;
	set lb13data.dm;
	keep usubjid armcd arm age race country;
	country=put(country,$cfmt.);
run;

/*********************************************************************
                        SAS Code for Task # 1 / Step # 2
 *********************************************************************/

data age;
	set dm;
	length ageCat $5;
	label agecat = "Age Category";
	if age=. then agecat=' ';
	else if age<45 then agecat='<45';
	else if age>=55 then agecat='>=55';
	else agecat='45-55';
run;

proc sort data=age;
	by usubjid;
run;

/*********************************************************************
                        SAS Code for Task # 1 / Step # 3
 *********************************************************************/

data pc;
	set lb13data.pc;
	if substr(pcstresc,1,1)='<' then pcstresn=input(substr(pcstresc,2),best12.);
run;

proc sort data=pc;
	by usubjid descending pcstresn;
run;

data pcsorted;
	set pc;
	by usubjid;
	if first.usubjid;
	pcmax = pcstresn;
	keep usubjid pcmax;
run;

data adsl4;
	merge age pcsorted (keep=usubjid pcmax);
	by usubjid;
	label pcmax="Maximum Plasma Concentration";
run;

/*********************************************************************
                        SAS Code for Task # 1 / Step # 4
 *********************************************************************/

data pc2;
	set lb13data.pc;
	if substr(pcstresc,1,1)='<' then pcstresn=input(substr(pcstresc,2),best12.);
run;

ods select ExtremeObs;
ods output ExtremeObs=adsl2;
proc univariate data=pc2 nextrobs=2; 
	class usubjid;
	var pcstresn;
run;

proc means data=adsl2;
	by usubjid;
	var high;
	output out=high(drop=_type_ _freq_)
	mean(high)=pcmax2;
run;

data adsl3;
	merge adsl4 high (keep=usubjid pcmax2);
	by usubjid;
	label pcmax2="Maximum Plasma Concentration (Avg.)";
run;

/*********************************************************************
                        SAS Code for Task # 1 / Step # 5
 *********************************************************************/

data vs;
	set lb13data.vs;
	if visitnum<=1 then period='BEFORE';
	else if visitnum>1 then period='AFTER';
run;

proc sort data=vs out=vssorted;
	by usubjid period vstestcd;
run;

proc means data=vssorted mean nway;
	class usubjid period vstestcd;
	var vsstresn;
	output out=vs2(drop=_type_ _freq_)
	mean= ;
run;

proc transpose data=vs2 out=vs3 (drop= _name_ _label_) delimiter=_;
	by usubjid;
	id period vstestcd;
	var vsstresn;
run;

data diff;
	set vs3;
	diabp_change=after_diabp-before_diabp;
	sysbp_change=after_sysbp-before_sysbp;
	hr_change=after_hr-before_hr;
	wgt_change=after_weight-before_weight;
run;

data data.adsl;
	retain usubjid armcd arm age agecat race country;
	merge adsl3 diff (keep=usubjid diabp_change sysbp_change hr_change wgt_change);
	by usubjid;
	label diabp_change="Change in Diastolic Blood Pressure"
	sysbp_change="Change in Systolic Blood Pressure"
	hr_change="Change in Heart Rate"
	wgt_change="Change in Weight";
run;


