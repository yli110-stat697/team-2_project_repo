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

Limitations: Some limiations might include that our adr_duration and 
Day_on_Drug have 0 values and very high values that might skew our data.
;

proc sgplot
  data = treatment_placebo_v1
  ;
    vbox day_on_drug / category = treatment_group
    ;
    vbox adr_duration / category = treatment_group
    ;
run;

proc sgplot
  data = treatment_placebo_v1
  ;
  scatter X = day_on_drug Y = adr_duration / group = treatment_group
  ;
run;


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

Limitations: Might have a limitation for our character variable and how 
accurate some of our results might be due to our lack of variety in 
ADR_Severity
;

proc glmmod 
  data = 
    patient_treatment_placebo_v1
  outdesign=
    patient_treatment_placebo_v1_2
  outparm=
    GLMParm
    ;
   class 
    adr_severity
    ;
   model 
    adr_severity =  age weight sex;
run
;


proc reg data =
   patient_treatment_placebo_v1_2
  ;
  DummyVars: model int_rate = COL2-COL6
  ;
  ods select ParameterEstimates;
  quit
  ;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Is the duration of the reaction correlated with the age, sex, and
weight of the patient?

Rationale: Would like to see if the severity and duration align with the same
factors that are significant.

Note: This compares the column ADR_duration from Placebo and Treatment to the 
column Age, Weight, and Sex from Patient_Info

Limitations: Again our issue might be based on how common one severity is 
versus the other ones which might prove to lack our correlation with soeme
of the variables.
;

proc glmmod 
  data = 
    patient_treatment_placebo_v1
  outdesign=
    patient_treatment_placebo_v1_3
  outparm=
    GLMParm
    ;
   class 
    adr_duration
    ;
   model 
    adr_duration =  age weight sex;
run
;


proc reg data =
   patient_treatment_placebo_v1_3
  ;
  DummyVars: model adr_duration = COL2-COL5
  ;
  ods select ParameterEstimates;
  quit
  ;
