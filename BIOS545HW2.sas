/*****************************************************************************
* Project : BIOS 545 Course
*
* Program name : HW2.sas
*
* Author : Junjie Zhou
*
* Date created : 1/28/2020
*
* Purpose : Biostatistics 545 Homework 2
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
%let root = /folders/myshortcuts/BIOS545;

/*********************************************************************
                        SAS code for importing data
 *********************************************************************/

ods rtf file="&root./Chinese_Height.rtf";
filename refile '/folders/myshortcuts/BIOS545/Data/Chinese_Health.xlsx';
proc import datafile=refile
	dbms=xlsx
	out=work.import;
RUN;

/*********************************************************************
                        SAS code for univariate descriptives
 *********************************************************************/

title "Univariate Descriptives for Height of the Responding Woman and her Partner";
proc univariate data=work.import;
	var R_height A_height;
run;

/*********************************************************************
                        SAS code for regression
                        
2. Regressing R_height on A_height
   y=106.75+0.31x
   x=(y-106.75)/0.31
   
   Regressing A_height on R_height
   y=116.74+0.34x
   x=(y-116.74)/0.34
   
   The x values are different for the 2 regression equations so
   regressing R_height on A_height is not equivalent to regressing
   A_height on R_height
 *********************************************************************/

title "Regressing R_height on A_height";
proc reg data=work.import plots=none;
ods select ParameterEstimates;
	model R_height=A_height;
run;

title "Regressing A_height on R_height";
proc reg data=work.import plots=none;
ods select ParameterEstimates;
	model A_height=R_height;
run;

/*********************************************************************
                        SAS code for correlation

3. Pearson Correlation Coefficient=0.32386
   Slope of z-scores=0.32386
   
   The pearson correlation coefficient is equal to the slope of the
   z-scores because correlation and regression values correspond to
   each other when X and Y are standardized in regression.
 *********************************************************************/

title "Pearson Correlation between R_height and A_height";
proc corr data=work.import;
	var R_height A_height;
run;

/* Turning raw data into z-scores */
proc standard data=work.import mean=0 std=1 out=height;
run;

title "Regressing z(A_height) on z(R_height)";
proc reg data=height plots=none;
	model A_height=R_height;
run;

/*********************************************************************
                        SAS code for regression
                        
4. The regression line goes through (mean of x, mean of y) because
   when you plug the points into the regression equation both sides
   are equal to each other.
   
   The regression line without the intercept does not go through 
   (mean of x, mean of y) because when you plug the points into the 
   regression equation both sides are not equal to each other.
 *********************************************************************/

title "Regressing A_height on R_height";
proc reg data=work.import plots=none;
	model A_height=R_height / noint;
run;

/* Without Intercept */
DATA _NULL_;
	x = 159.290743;
	b =  1.07386;
	y_hat = x*b;
	y = 171.166884;
	PUT "The predicted y at x-bar is: " y_hat;
	PUT "The observed y-bar is:       " y;
RUN;
/* With Intercept */
DATA _NULL_;
	x  = 159.290743;
	b0 = 116.73728;
	b1 =  0.34170;
	y_hat = b0 + x*b1;
	y = 171.166884;
	PUT "The predicted y at x-bar is: " y_hat;
	PUT "The observed y-bar is:       " y;
RUN;

/*
Suppressed intercept:
The predicted y at x-bar is: 171.05595728
The observed y-bar is:       171.166884

With intercept fitted:
The predicted y at x-bar is: 171.16692688
The observed y-bar is:       171.16684
*/

/*********************************************************************
                        SAS code for ANOVA
                        
5. There is 1 degree of freedom for simple linear regression because
   only 1 of the 2 parameters, the intercept or the slope, can change.
   
   The parameter estimates for slope is 0.34170 and intercept is 
   116.73728 meaning that partner height can be estimated by adding
   116.73728 to 0.34170 times the woman's height.
   
   A standard error of 0.02550 tells us that values fall on average 
   around 0.02550 of the regression line.
   
   We got a t-value of 13.40 and a p-value of less than 0.0001. The 
   t-test tests the null hypothesis that the parameter is equal to 0.
   The parameter is statistically significant because p=0.0001 which is 
   less than the alpha value of 0.05 so we have enough evidence to 
   reject the null hypothesis and suggest that the parameter may not be
   equal to 0. If the parameter was 0 then the probability of 
   observing a value this or more extreme is 0.0001.
   
   The p-value from the ANOVA table is also less than 0.0001 so it is
   the same p-value from the t-test of the slope because ANOVA analyzes
   the differences between groups and regression analyzes the differences
   between variables but since we only have 1 X variable then the model
   is the same. T-tests are just a special case of ANOVA. 
   
   ANOVA Table
   
   	    SS	    df	    MS      F      P
   Reg     6.995     1    6.995   7.312  <0.01
   Resid  45.922    48    0.957
   Total  52.917    49
 *********************************************************************/

data _null_;
	slope = 0.34170;
	SE    = 0.02550;
	lq    = quantile("T", .025, 1532);
	uq    = quantile("T", .975, 1532); 
	ll    = slope+(lq*SE);              
	ul    = slope+(uq*SE);             
	put "The 95% CI for the slope is (" ll ", " ul ")";
run;
/* The 95% CI for the slope is (0.2916814015, 0.3917185985); */

title "Regressing A_height on R_height";
proc reg data=work.import;
ods select anova fitplot;
	model A_height=R_height;
run;

ods rtf close;

