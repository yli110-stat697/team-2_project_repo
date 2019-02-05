*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate final analytic file;
%include '.\STAT697-01_s19-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the distribution of days on drug and duration of adverse 
reaction for placebo and non placebo patients?

Rationale: This would help formulate more questions around how some patients 
react whether age, weight and/or sex could be a factor.

Note: This compares the column Day_On_Drug and ADR_Duration with 
Treatment_Group from Placebo and Treatment.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Is there a correlation with Severity of reaction from age, weight,
and sex?

Rationale: This would help identify any significant factors that contribute to 
the severity of the drug reaction.

Note: This compares the column ADR_Severity from Placebo and Treatment to the 
column Age, Weight, and Sex from Patient_Info.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Is the duration of the reaction correlated with the age, sex, and
weight of the patient?

Rationale: Would like to see if the severity and duration align with the same
factors that are significant.

Note: This compares the column ADR_Severity from Placebo and Treatment to the 
column Age, Weight, and Sex from Patient_Info
;
