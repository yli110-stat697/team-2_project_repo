
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
[Research Question 1] What are the distributions of age, race, and adverse reaction in two different groups? 
Rationale: This would help to find out what would be the adverser reaction between race and age group after treatment.We want to make sure if there is any repeating adverse reaction (any actual adverse reaction) between groups to prevent any malpractice.
Note: This compares the age, weight, race columns in the patient_info dataset.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
[Research Question 2] Does the duration on drug has significant impact on adverse severity?
Rationale: This could help us to identify whether the reported adverse severity were based on the treatment itself or the duration on drug.
Note: This compares columns Day_on_drug, and severity in placebo and treatment datasets.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
[Research Question 3] Was the adverse reaction times differ significantly between two groups of patients? 
Rationale: This could help us to find out whether the duration of adverse reaction has impact (other than the actual treatment*) between two treatment groups.
Note: This compares the columns ADR_DURATION from adverse_reaction and severity from placebo and treatment.
;v
