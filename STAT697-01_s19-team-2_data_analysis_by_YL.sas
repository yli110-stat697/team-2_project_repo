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
Question: What are the distributions of age, weight, and sex of patients in two
different groups?

Rationale: This would help to decide if the study randomized the choices of 
treatment. In other words, we want to be sure that the the grouping wasn't 
biased.

Note: This compares the age, weight, race columns in the patient_info dataset.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Was the drug treatment having significant adverse reactions?

Rationale: This would help us to identify whether the reported adverse reactions
were from placebo effect or they really exist.

Note: This compares columns adverse_reaction and severity in placebo and 
treatment datasets.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What are other factors that might affect the patients reactions to 
drugs/placebo?

Rationale: This could help us to find more potential factors that affect 
people's reactions to drugs.

Note: This compares the columns age, weight from patient_info to the column 
adverse_reaction and severity from placebo and treatment.
;

