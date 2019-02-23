<<<<<<< HEAD
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] patient_info
[Dataset Description] This dataset contains the basic information about 
patients in the study, including sex, age, weight and race.
[Experimental Unit Description] Each patient in this study
[Number of Observations] 357
                    
[Number of Features] 5
[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web
[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4
[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset1DSN = patient_info;
%let inputDataset1URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/patient_info.xlsx?raw=true
;
%let inputDataset1Type = XLSX;


*
[Dataset 2 Name] placebo
[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the placebo group.
[Experimental Unit Description] Each patient in this study
[Number of Observations] 130
                    
[Number of Features] 8
[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web
[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4
[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset2DSN = placebo;
%let inputDataset2URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/placebo.xlsx?raw=true
;
%let inputDataset2Type = XLSX;


*
[Dataset 3 Name] treatment
[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the drug-treated group.
[Experimental Unit Description] Each patient in the study
[Number of Observations] 127
                    
[Number of Features] 8
[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web
[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4
[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset3DSN = treatment;
%let inputDataset3URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/treatment.xlsx?raw=true
;
%let inputDataset3Type = XLSX;

options fullstimer;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 3;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets

* check the dataset patient_info for possible duplicate patients/observations;
proc sql;
    create table patient_info_dups as
        select
             patient_id
            ,count(*) as row_count_for_patient_id
        from
            patient_info
        group by
            patient_id
        having
            row_count_for_patient_id > 1
    ;
    /* there are some replicated observations, meaning that this dataset nees
    to be cleaned*/
    create table patient_info_final as
        select
            distinct *
        from
            patient_info
        where
            not(missing(patient_id))
    ;
quit;


* check placebo dataset using the same techniques as above;
proc sql;
    create table placebo_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_placebo_obs
        from
            placebo
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_placebo_obs > 1
    ;
    create table placebo_final as
        select
            distinct *
        from
            placebo
    ;
quit;

* check treatment dataset using the same techniques as above;
proc sql;
    create table treat_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_treat_obs
        from
            treatment
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_treat_obs > 1
    ;
    create table treatment_final as
        select
            distinct *
        from
            treatment
    ;
quit;


* inspect columns of interest in cleaned versions of datasets;
    /*
    title "Inspect Distribution_of_Age_in Patient_Info";
    proc sql;
        select
             min(age) as min
            ,max(age) as max
            ,mean(age) as mean
            ,median(age) as median
            ,nmiss(age) as missing
        from
            Patient_info_final
        ;
    quit;
    title;

    title "Inspect Dstribution_of_Race in Patient_Info";
    proc sql;
        select
             race
            ,count(*) as row_count_race
        from
            Patient_info_final
        group by
            race
        ;
    quit;
    title;

    title "Inspect Relation_To_Drug in Placebo_final";
    proc sql;
        select
             relation_to_drug
            ,count(*) as row_count_relation
        from
            Placebo_final
        group by
            relation_to_drug
        ;
    quit;
    title;

    title "Inspect Relation_To_Drug in Treatment_final";
    proc sql;
        select
             relation_to_drug
            ,count(*) as row_count_relation
        from
            Treatment_final
        group by
            relation_to_drug
        ;
    quit;
    title;

    title "Inspect ADR_SEVERITY in Placebo_final";
    proc sql;
        select
             adr_severity
            ,count(*) as row_count_serverity
        from
            Placebo_final
        group by
            adr_severity
        ;
    quit;
    title;

    title "Inspect ADR_SEVERITY in Treatment_final";
    proc sql;
        select
             adr_severity
            ,count(*) as row_count_serverity
        from
            Treatment_final
        group by
            adr_severity
        ;
    quit;
    title;

    title "Inspect ADR_Duration in Placebo_final";
    proc sql;
        select
             min(adr_duration) as min
            ,mean(adr_duration) as mean
            ,median(adr_duration) as median
            ,max(adr_duration) as max
            ,nmiss(adr_duration) as missing
       from
            Placebo_final
        ;
    quit;
    title;

    title "Inspect ADR_Duration in Treatment_final";
    proc sql;
        select
             min(adr_duration) as min
            ,mean(adr_duration) as mean
            ,median(adr_duration) as median
            ,max(adr_duration) as max
            ,nmiss(adr_duration) as missing
       from
            Treatment_final
        ;
    quit;
    title;

    title "Inspect Day_On_Dug in Placebo_final";
    proc sql;
        select
             min(day_on_drug) as min
            ,mean(day_on_drug) as mean
            ,median(day_on_drug) as median
            ,max(day_on_drug) as max
            ,nmiss(day_on_drug) as missing
       from
            Placebo_final
        ;
    quit;
    title;

    title "Inspect Day_On_Dug in Treatment_final";
    proc sql;
        select
             min(day_on_drug) as min
            ,mean(day_on_drug) as mean
            ,median(day_on_drug) as median
            ,max(day_on_drug) as max
            ,nmiss(day_on_drug) as missing
       from
            Treatment_final
        ;
    quit;
    title;
    


* combine patient_info_final and placebo_final using a data-step match-merge;
* note: After running the data step and proc sort step below several times and
averaging the fullstimer output in the system log, they tend to take about 0.09
seconds of combined 'real time' to execute and a maximum of about 1.7 MB of
memory (1000 KB for the data step vs 680 KB for the proc sort step) on the
computer they were tested on;
data patient_placebo_v1;
    retain
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    keep
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    merge
        patient_info_final
        placebo_final
    ;
    by patient_id;
run;
proc sort data = patient_placebo_v1;
    by patient_id adverse_reaction adr_severity day_on_drug adr_duration;
run;

* combine patient_info_final and placebo_final using proc sql;
* note: After running the proc sql step below several times and averaging the
fullstimer output in the system log, they tend to take about 0.06 seconds of 
'real time' to execute and about 5.6 MB on the computer they were tested on. As
a result, the SQL appears slightly faster to execute as the combined data step
and proc sort step as above, but to use much more memory;
proc sql;
    create table patient_placebo_v2 as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            placebo_final as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

* verify that patient_placebo_v1 and patient_placebo_v2 are identical;
proc compare
        base=patient_placebo_v1
        compare=patient_placebo_v2
        novalues
    ;
run;

* combine patient_info_final and treatment_final using a data-step match-merge;
* note: After running the data step and proc sort step below several times and
averaging the fullstimer output in the system log, they tend to take about 0.08
seconds of combined 'real time' to execute and a maximum of about 1.5 MB of
memory (970 KB for the data step vs 680 KB for the proc sort step) on the
computer they were tested on;
data patient_treatment_v1;
    retain
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    keep
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    merge
        patient_info_final
        treatment_final
    ;
    by patient_id;
run;
proc sort data = patient_treatment_v1;
    by patient_id adverse_reaction adr_severity day_on_drug adr_duration;
run;

* combine patient_info_final and treatment_final using proc sql;
* note: After running the proc sql step below several times and averaging the
fullstimer output in the system log, they tend to take about 0.06 seconds of 
'real time' to execute and about 5.5 MB on the computer they were tested on;
proc sql;
    create table patient_treatment_v2 as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            treatment_final as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

* verify that patient_placebo_v1 and patient_placebo_v2 are identical;
proc compare
        base=patient_treatment_v1
        compare=patient_treatment_v2
        novalues
    ;
run;

*first vertical combine;
proc sql;
    create table placebo_treatment as
        select *
            from treatment_final
        union corr
        select *
            from placebo_final
    ;
quit;
*then horizontal join;
proc sql;
    create table patient_treatment_placebo as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            placebo_treatment as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;
*/

*Build analytical file;
proc sql;
    create table adverser_analytical_file_raw as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            (
                select *
                    from treatment_final
                union corr
                select *
                    from placebo_final
            ) as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

*remove duplicate observations from adverser_analytical_file_raw;
proc sort
    noduprecs
    data = adverser_analytical_file_raw
    out = adverser_analytical_file
  ;
  by
    patient_id treatment_group adverse_reaction
  ;
run;
=======
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] patient_info

[Dataset Description] This dataset contains the basic information about 
patients in the study, including sex, age, weight and race.

[Experimental Unit Description] Each patient in this study

[Number of Observations] 357
                    
[Number of Features] 5

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset1DSN = patient_info;
%let inputDataset1URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/patient_info.xlsx?raw=true
;
%let inputDataset1Type = XLSX;


*
[Dataset 2 Name] placebo

[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the placebo group.

[Experimental Unit Description] Each patient in this study

[Number of Observations] 130
                    
[Number of Features] 8

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset2DSN = placebo;
%let inputDataset2URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/placebo.xlsx?raw=true
;
%let inputDataset2Type = XLSX;


*
[Dataset 3 Name] treatment

[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the drug-treated group.

[Experimental Unit Description] Each patient in the study

[Number of Observations] 127
                    
[Number of Features] 8

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset3DSN = treatment;
%let inputDataset3URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/treatment.xlsx?raw=true
;
%let inputDataset3Type = XLSX;

options fullstimer;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 3;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets


* check the dataset patient_info for possible duplicate patients/observations;
proc sql;
    create table patient_info_dups as
        select
             patient_id
            ,count(*) as row_count_for_patient_id
        from
            patient_info
        group by
            patient_id
        having
            row_count_for_patient_id > 1
    ;
    /* there are some replicated observations, meaning that this dataset nees
    to be cleaned*/
    create table patient_info_final as
        select
            distinct *
        from
            patient_info
        where
            not(missing(patient_id))
    ;
quit;


* check placebo dataset using the same techniques as above;
proc sql;
    create table placebo_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_placebo_obs
        from
            placebo
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_placebo_obs > 1
    ;
    create table placebo_final as
        select
            distinct *
        from
            placebo
    ;
quit;


* check treatment dataset using the same techniques as above;
proc sql;
    create table treat_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_treat_obs
        from
            treatment
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_treat_obs > 1
    ;
    create table treatment_final as
        select
            distinct *
        from
            treatment
    ;
quit;


* inspect columns of interest in cleaned versions of datasets;
    /*
    title "Inspect Distribution_of_Age_in Patient_Info";
    proc sql;
        select
             min(age) as min
            ,max(age) as max
            ,mean(age) as mean
            ,median(age) as median
            ,nmiss(age) as missing
        from
            Patient_info_final
        ;
    quit;
    title;

    title "Inspect Dstribution_of_Race in Patient_Info";
    proc sql;
        select
             race
            ,count(*) as row_count_race
        from
            Patient_info_final
        group by
            race
        ;
    quit;
    title;

    title "Inspect Relation_To_Drug in Placebo_final";
    proc sql;
        select
             relation_to_drug
            ,count(*) as row_count_relation
        from
            Placebo_final
        group by
            relation_to_drug
        ;
    quit;
    title;

    title "Inspect Relation_To_Drug in Treatment_final";
    proc sql;
        select
             relation_to_drug
            ,count(*) as row_count_relation
        from
            Treatment_final
        group by
            relation_to_drug
        ;
    quit;
    title;

    title "Inspect ADR_SEVERITY in Placebo_final";
    proc sql;
        select
             adr_severity
            ,count(*) as row_count_serverity
        from
            Placebo_final
        group by
            adr_severity
        ;
    quit;
    title;

    title "Inspect ADR_SEVERITY in Treatment_final";
    proc sql;
        select
             adr_severity
            ,count(*) as row_count_serverity
        from
            Treatment_final
        group by
            adr_severity
        ;
    quit;
    title;

    title "Inspect ADR_Duration in Placebo_final";
    proc sql;
        select
             min(adr_duration) as min
            ,mean(adr_duration) as mean
            ,median(adr_duration) as median
            ,max(adr_duration) as max
            ,nmiss(adr_duration) as missing
       from
            Placebo_final
        ;
    quit;
    title;

    title "Inspect ADR_Duration in Treatment_final";
    proc sql;
        select
             min(adr_duration) as min
            ,mean(adr_duration) as mean
            ,median(adr_duration) as median
            ,max(adr_duration) as max
            ,nmiss(adr_duration) as missing
       from
            Treatment_final
        ;
    quit;
    title;

    title "Inspect Day_On_Dug in Placebo_final";
    proc sql;
        select
             min(day_on_drug) as min
            ,mean(day_on_drug) as mean
            ,median(day_on_drug) as median
            ,max(day_on_drug) as max
            ,nmiss(day_on_drug) as missing
       from
            Placebo_final
        ;
    quit;
    title;

    title "Inspect Day_On_Dug in Treatment_final";
    proc sql;
        select
             min(day_on_drug) as min
            ,mean(day_on_drug) as mean
            ,median(day_on_drug) as median
            ,max(day_on_drug) as max
            ,nmiss(day_on_drug) as missing
       from
            Treatment_final
        ;
    quit;
    title;
        */
    


* combine patient_info_final and placebo_final using a data-step match-merge;
* note: After running the data step and proc sort step below several times and
  averaging the fullstimer output in the system log, they tend to take about 
  0.09 seconds of combined 'real time' to execute and a maximum of about 1.7 MB 
  of memory (1000 KB for the data step vs 680 KB for the proc sort step) on the
  computer they were tested on;
data patient_placebo_v1;
    retain
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    keep
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    merge
        patient_info_final
        placebo_final
    ;
    by patient_id;
run;

proc sort data = patient_placebo_v1;
    by patient_id adverse_reaction adr_severity day_on_drug adr_duration;
run;

* combine patient_info_final and placebo_final using proc sql;
* note: After running the proc sql step below several times and averaging the 
  fullstimer output in the system log, they tend to take about 0.06 seconds of 
  'real time' to execute and about 5.6 MB on the computer they were tested on. 
  As a result, the SQL appears slightly faster to execute as the combined data 
  step and proc sort step as above, but to use much more memory;
proc sql;
    create table patient_placebo_v2 as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            placebo_final as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

* verify that patient_placebo_v1 and patient_placebo_v2 are identical;
proc compare
        base=patient_placebo_v1
        compare=patient_placebo_v2
        novalues
    ;
run;

* combine patient_info_final and treatment_final using a data-step match-merge;
* note: After running the data step and proc sort step below several times and
  averaging the fullstimer output in the system log, they tend to take about 
  0.08 seconds of combined 'real time' to execute and a maximum of about 1.5MB
  of memory (970 KB for the data step vs 680 KB for the proc sort step) on the 
  computer they were tested on;
data patient_treatment_v1;
    retain
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    keep
        patient_id
        age
        sex
        weight
        race
        day_on_drug
        adverse_reaction
        relation_to_drug
        adr_severity
        adr_duration
        treatment_group
        total_daily_dose
    ;
    merge
        patient_info_final
        treatment_final
    ;
    by patient_id;
run;

proc sort data = patient_treatment_v1;
    by patient_id adverse_reaction adr_severity day_on_drug adr_duration;
run;

* combine patient_info_final and treatment_final using proc sql;
* note: After running the proc sql step below several times and averaging the 
  fullstimer output in the system log, they tend to take about 0.06 seconds of
  'real time' to execute and about 5.5 MB on the computer they were tested on;
proc sql;
    create table patient_treatment_v2 as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            treatment_final as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

* verify that patient_placebo_v1 and patient_placebo_v2 are identical;
proc compare
        base=patient_treatment_v1
        compare=patient_treatment_v2
        novalues
    ;
run;


*first vertical combine;
proc sql;
    create table placebo_treatment as
        select *
            from treatment_final
        union corr
        select *
            from placebo_final
    ;
quit;
*then horizontal join;
proc sql;
    create table patient_treatment_placebo as
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            placebo_treatment as B
            on A.patient_id = B.patient_id
        order by
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;
>>>>>>> 8eff2de5840e39f7b8b94c57dcea5e9a3cda71da
