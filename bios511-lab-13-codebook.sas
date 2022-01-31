/*****************************************************************************
* Project : BIOS 511 Course
*
* Program name : codebook
*
* Author : Junjie Zhou
*
* Date created : 11/26/2019
*
* Purpose : This macro creates 2 codebooks that documents the metadata for a sas dataset
*
* Revision History :
*
* Date Author Ref (#) Revision
*
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/

%macro codebook(lib=,ds=,maxval=10);
	%if &lib= | &ds= %then %do; 
	  %put &=lib;
	  %put &=ds;
	  %abort;
	%end;
	
	proc format; 
	value tfmt 1 = 'NUM' 2 = 'CHAR';
	run;
	
	proc contents data=&lib..&ds. order=varnum out=contents noprint; 
	run;
	
	proc sort data=contents;
		by varnum;
	run;

	proc print data=contents label noobs;
		var name Type Label length;
		title "Contents of the &lib..&ds. Dataset";
		label name = "Variable Name" 
			  Type="Variable Type" Label="Variable Label" 
			  length="Variable Length";
		informat Type tfmt.;
	run;

	data freqtab;
	 	set contents end=last;
		call symput('vname'||strip(put(_n_,best.)),  strip(name));
		call symput('vtype'||strip(put(_n_,best.)),  strip(put(type,tfmt.)));
		call symput('vlabel'||strip(put(_n_,best.)), strip(label));
		if last then call symput('nVars',strip(put(_n_,best.)));
	run;

	%do j = 1 %to &nVars.;
		title1 "Analysis of Variable = &&vlabel&j. (Label=%upcase(&&vname&j.))";
		%if &&vtype&j = NUM %then %do;
			proc means data = &lib..&ds. noprint;
			 var &&vname&j.;
			 output out=mean_analysis n=num nmiss=num_missing mean=avg stddev=standard_dev
			 	median=median min=minimum max=maximum;
			run;
			
			proc print data=mean_analysis label noobs;
				var num num_missing avg standard_dev median minimum maximum;
				label num = "Number of Non-Missing Values"
					num_missing = "Number of Missing Values"
					avg = "Mean"
					standard_dev = "Standard Deviation"
					median = "Median"
					minimum = "Minimum"
					maximum = "Maximum";
			run;
		%end;
		
		%else %if &&vtype&j = CHAR %then %do;
			proc freq data=&lib..&ds.;
				table &&vname&j. /nocum noprint out=freqtab;
			run;
			
			proc sort data=freqtab;
				by descending count;
			run;
			
			%let printAll = YES;
			data _null_;
				set freqtab;
				if _n_ > &maxVal. then 
				call symput('printAll','NO');
			run; 
			
			%if &printAll=YES %then %do; 
				title1 "Frequency Analysis of Variable = %upcase(&&vname&j) (Label=&&vlabel&j)"; 
				proc print data=freqtab noobs label; 
				label &&vname&j = "Value"
				count = "Frequency Count"
				percent = "Percent of Total Frequency";
			%end;
			%else %do; 
				title1 "&maxval. Most Frequent Values of Variable %upcase(&&vname&j) (Label=&&vlabel&j)"; 
				proc print data=freqtab (obs=&maxval.) noobs label; 
				var &&vname&j count percent;
				label &&vname&j = "Value"
				count = "Frequency Count"
				percent = "Percent of Total Frequency"; 
			%end;
			run;
		%end;
	%end;
%mend;


