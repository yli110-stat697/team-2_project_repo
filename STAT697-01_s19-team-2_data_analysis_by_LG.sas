*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate final analytic file;
%include '.\STAT697-01_s19-team-0_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
[Research Question 1] What are the distributions of age, race, and adverse 
reaction in two different groups? 

Rationale: This would help to find out what would be the adverser reaction 
between race and age group after treatment.We want to make sure if there is 
any repeating adverse reaction (any actual adverse reaction) between groups to 
prevent any malpractice.

Note: This compares the age, race columns in the patient_info dataset.

Limitations: Values of "Adverser reaction" equal to zero should be excluded 
from the analysis, since they are potentially missing data values.
;

title "Distribution of Age in Traetment Group";
proc sgplot data=Adverser_analytical_file;
	vbox age / category = treatment_group;
run;

title "Distribution of Race in Traetment Group";
proc sql; 
	select 
		 treatment_group
		,race
		,count(*) as row_count_race
	from
		Adverser_analytical_file
	group by
		 treatment_group
		,race
	having 
		row_count_race > 0
	;
quit;

title "Distribution of Adverse Reaction in Traetment Group";
proc sql outobs=10; 
	select 
		 treatment_group
		,adverse_reaction
		,count(*) as row_count_reaction
	from
		Adverser_analytical_file
	group by
		 treatment_group
		,adverse_reaction
	having 
		row_count_reaction > 0
	order by
		row_count_reaction desc
	;
quit;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
[Research Question 2] Does the duration on drug has significant impact on 
adverse severity?

Rationale: This could help us to identify whether the reported adverse severity 
were based on the treatment itself or/and the duration on drug.

Note: This compares columns Day_on_drug, and severity in placebo and treatment 
datasets.

Limitations: Values of "Adverse severity" equal to zero should be excluded from 
the analysis, since they are potentially missing data values.
;

title "Distribution of Duration on drug in Treatment Group";
proc sgplot data=Adverser_analytical_file;
	vbox day_on_drug / category = treatment_group;
run;

ods graphics on;
title 'Occurrence of ADR Severity';
proc logistic data=Adverser_analytical_file;
	class treatment_group;
	model adr_severity = treatment_group day_on_drug /influence;
	/*
	p-value=0.5804 > alpha=0.05, failed to conclude that the duration on drug has 
	significant impact on adverse severity (treatment group, p-value=0.5804
	has no significant impact on adverse severity as well).
	*/
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
[Research Question 3] Was the adverse reaction times differ significantly 
between two groups of patients? 

Rationale: This could help us to figure out whether the duration of adverse 
reaction has impact (other than the actual treatment*) between two treatment 
groups.

Note: This compares the columns ADR_DURATION from adverse_reaction and severity 
from placebo and treatment.

Limitations: Values of "treatments (groups of patients)" equal to zero should 
be excluded from the analysis, since they are potentially missing data values. 
;

title "Distribution of Adverse Reaction time in Treatment Group";
proc sgplot data=Adverser_analytical_file;
	vbox adr_duration / category = treatment_group;
run;

ods graphics on;
title 'Difference of ADR Reaction Time in two groups';
proc glm data=Adverser_analytical_file;
	class treatment_group;
	model adr_duration = treatment_group /solution;
	output out=residuals r=resid;
	/*
	Since F value for treatment goup is 3.90, with p-value=0.0492 < alph=0.05, 
	reject H0. There is enough evident to show that the ADR duration time is 
	different between treatment group, however, the result is not significant.
	*/
run;

/* 
Check Assumptions for valid ANOVA:
1. Homogeneity variances
proc glm data=Adverser_analytical_file; 
	class treatment_group; 
	model adr_duration = treatment_group /solution;
	means treatment_group / hovtest = levene; 
	*
	H0: Homogeneity variances
	Ha: Not all variances are the same
	Since p-value=0.3197 > alpha=0.05, Homogeneity variance.
	;
run; 

2. Nomality of residuals
proc univariate data=residuals plot normal; 
	var resid; 
	*
	H0: Normal residuals
	Ha: Residuals not normally distributed
	Since p-value<0.0001, Residuals are normally distributed.
	;
run; 

* Based on above validation, model is valid ANOVA;
*/
