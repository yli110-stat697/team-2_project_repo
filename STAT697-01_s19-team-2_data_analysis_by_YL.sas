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

Limitations: Descriptive statistics are useful, but eyeballing the differences
between treatment and placebo groups is not accurate. Besides, there are other
factors that may underlie the difference for these two groups, like the genetic
issues(some genotypes are more prone to have adverse effect).
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

Limitations: There are so many different types of adverse reactions, and each
reactions have different severities and durations. Severities might positively
correlate to durations, but it's also possible that they are negatively related
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

Limitations: To construct a predicative or classifcation model for adverse
reactions, we can build models based on different combinations of variables in
the given dataset. However, the variables given may not have a clear
explanation for the response variables. Besides, the response variable has a
few choices, picking up the suited one is critial.
;

