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
;

title "Distribution of Age in Traetment Group";
proc sql; 
	select 
		 min(age) as min
		,max(age) as max
		,mean(age) as mean
		,median(age) as median
		,nmiss(age) as missing
	from
		patient_treatment_v2
	;
quit;



title "Distribution of Race in Traetment Group";
proc sql; 
	select 
		 race
		,count(*) as row_count_race
	from
		patient_treatment_v2
	group by
		race
	having 
		row_count_race > 0
	order by
		row_count_race desc
;
quit;



title "Distribution of Adverse Reaction in Traetment Group";
proc sql outobs=10; 
	select 
		 adverse_reaction
		,count(*) as row_count_reaction
	from
		patient_treatment_v2
	group by
		adverse_reaction
	having 
		row_count_reaction > 0
	order by
		row_count_reaction desc
	;
quit;


title "Distribution of Age in Placebo Group";
proc sql; 
	select 
		 min(age) as min
		,max(age) as max
		,mean(age) as mean
		,median(age) as median
		,nmiss(age) as missing
	from
		patient_placebo_v2
	;
quit;



title "Distribution of Race in Placebo Group";
proc sql; 
	select 
		 race
		,count(*) as row_count_race
	from
		patient_placebo_v2
	group by
		race
	having 
		row_count_race > 0
	order by
		row_count_race desc
	;
quit;



title "Distribution of Adverse Reaction in Placebo Group";
proc sql outobs=10; 
	select 
		 adverse_reaction
		,count(*) as row_count_reaction
	from
		patient_placebo_v2
	group by
		adverse_reaction
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
were based on the treatment itself or the duration on drug.

Note: This compares columns Day_on_drug, and severity in placebo and treatment 
datasets.
;

title "Distribution of Duration on drug in Placebo Group";
proc sql; 
	select 
		 min(day_on_drug) as min
		,max(day_on_drug) as max
		,mean(day_on_drug) as mean
		,median(day_on_drug) as median
		,nmiss(day_on_drug) as missing
	from
		patient_placebo_v2
	;
quit;


title "Distribution of Duration on drug in Treatment Group";
proc sql; 
	select 
		 min(day_on_drug) as min
		,max(day_on_drug) as max
		,mean(day_on_drug) as mean
		,median(day_on_drug) as median
		,nmiss(day_on_drug) as missing
	from
		patient_treatment_v2
	;
quit;


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
;


title "Distribution of Adverse Reaction time in Placebo Group";
proc sql; 
	select 
		 min(adr_duration) as min
		,max(adr_duration) as max
		,mean(adr_duration) as mean
		,median(adr_duration) as median
		,nmiss(adr_duration) as missing
	from
		patient_placebo_v2
	;
quit;


title "Distribution of Adverse Reaction time in Treatment Group";
proc sql; 
	select 
		 min(adr_duration) as min
		,max(adr_duration) as max
		,mean(adr_duration) as mean
		,median(adr_duration) as median
		,nmiss(adr_duration) as missing
	from
		patient_treatment_v2
	;
quit;
