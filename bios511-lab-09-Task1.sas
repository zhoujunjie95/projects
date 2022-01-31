/*****************************************************************************
* Project : BIOS 511 Course
*
* Program name : lab-09-730235682-Task1
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
libname data "&root/Lab/&lab./Data";

/*********************************************************************
                        SAS Code for Task # 1 / Step # 1
 *********************************************************************/

ods select position;
proc contents data=lab9data.lb varnum; run;

proc sort data=lab9data.lb out=tests(keep=LBCAT LBTEST: LBSTRESU) nodupkey;
	by LBCAT LBTEST: LBSTRESU; run;
proc print; run;

proc sort data=lab9data.lb out=tests(keep=VISITNUM VISIT) nodupkey;
	by VISITNUM VISIT; run;
proc print; run;

proc sort data=lab9data.lb out=tests(keep=LBSTAT LBREASND) nodupkey;
	by LBSTAT LBREASND; run;
proc print; run;

proc print data=lab9data.lb (obs=10);
	where lbtest='Albumin' and lbstresu='';
run;

proc print data=lab9data.lb (obs=10);
	where lbtest='Albumin' and lbstresu^='';
run;

/*********************************************************************
                        SAS Code for Task # 1 / Step # 2
 *********************************************************************/

/* Merge DM and LB*/

data dm;
	set lab9data.dm;
	keep usubjid age sex race country armcd arm rfxstdtc;
run;

proc sort data=dm out=dmsorted;
	by usubjid;
run;

proc sort data=lab9data.lb out=lbsorted;
	by usubjid lbtestcd lbtest visitnum visit lbdtc;
run;

data merged;
	merge dmsorted lbsorted;
	by usubjid;
run;

data adlb;
	set merged;
	by usubjid lbtestcd lbtest visitnum visit lbdtc;
	/* lbseq */
	retain LBSEQ;
	if first.usubjid then LBSEQ=1;
	else LBSEQ=LBSEQ+1;
	/* lbnrind */
	if lbstresn='.' then LBNRIND='';
	if lbtest='Albumin' and lbstresn>. then do;
	if lbstresn <35 then LBNRIND='L';
	else if lbstresn >55 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Calcium' and lbstresn>. then do;
	if lbstresn <2.1 then LBNRIND='L';
	else if lbstresn >2.7 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Hematocrit' and sex='F' and lbstresn>. then do;
	if lbstresn <0.349 then LBNRIND='L';
	else if lbstresn >0.445 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Hematocrit' and sex='M' and lbstresn>. then do;
	if lbstresn <0.388 then LBNRIND='L';
	else if lbstresn >0.5 then LBNRIND='H';
	else LBNRIND='N';
	end;
run;

data lbblfl;
	merge dmsorted(in=a) lbsorted(in=b);
	by usubjid;
	if a and b;
	if input(scan(lbdtc,1,'T'),yymmdd10.) <= input(rfxstdtc,yymmdd10.) and lbstresn >.;
run;

data lbblfl2;
	set lbblfl;
	by usubjid lbtestcd lbdtc;
	/* lbnrind */
	if lbstresn='.' then LBNRIND='';
	if lbtest='Albumin' and lbstresn>. then do;
	if lbstresn <35 then LBNRIND='L';
	else if lbstresn >55 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Calcium' and lbstresn>. then do;
	if lbstresn <2.1 then LBNRIND='L';
	else if lbstresn >2.7 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Hematocrit' and sex='F' and lbstresn>. then do;
	if lbstresn <0.349 then LBNRIND='L';
	else if lbstresn >0.445 then LBNRIND='H';
	else LBNRIND='N';
	end;
	
	if lbtest='Hematocrit' and sex='M' and lbstresn>. then do;
	if lbstresn <0.388 then LBNRIND='L';
	else if lbstresn >0.5 then LBNRIND='H';
	else LBNRIND='N';
	end;

	if last.lbtestcd;
	keep usubjid lbtestcd visitnum lbstresn lbnrind;
	rename lbstresn = BASE visitnum = BASEVISITNUM lbnrind = BASECAT;
run;

data data.adlb2;
	merge lbblfl2 adlb;
	by usubjid lbtestcd;
	/* lbblfl */
	if visitnum = basevisitnum then LBBLFL='Y';
	/* change */
	CHANGE = lbstresn - base;
	/* pct_change */
	PCT_CHANGE = (lbstresn-base)/base*100;
	drop basevisitnum rfxstdtc;
run;







