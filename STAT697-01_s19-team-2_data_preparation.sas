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

title "Inspect Percent_Eligible_Free_K12 in frpm1415";
proc sql;
    select
     min(Percent_Eligible_Free_K12) as min
    ,max(Percent_Eligible_Free_K12) as max
    ,mean(Percent_Eligible_Free_K12) as max
    ,median(Percent_Eligible_Free_K12) as max
    ,nmiss(Percent_Eligible_Free_K12) as missing
    from
    frpm1415
    ;
quit;
title;

title "Inspect Percent_Eligible_Free_K12 in frpm1516";
proc sql;
    select
     min(Percent_Eligible_Free_K12) as min
    ,max(Percent_Eligible_Free_K12) as max
    ,mean(Percent_Eligible_Free_K12) as max
    ,median(Percent_Eligible_Free_K12) as max
    ,nmiss(Percent_Eligible_Free_K12) as missing
    from
    frpm1516
    ;
quit;
title;

title "Inspect PCTGE1500, after converting to numeric values, in sat15";
proc sql;
    select
     min(input(PCTGE1500,best12.)) as min
    ,max(input(PCTGE1500,best12.)) as max
    ,mean(input(PCTGE1500,best12.)) as max
    ,median(input(PCTGE1500,best12.)) as max
    ,nmiss(input(PCTGE1500,best12.)) as missing
    from
    sat15
    ;
quit;
title;

title "Inspect NUMTSTTAKR, after converting to numeric values, in sat15";
proc sql;
    select
     input(NUMTSTTAKR,best12.) as Number_of_testers
    ,count(*)
    from
    sat15
    group by
    calculated Number_of_testers
    ;
quit;
title;

title "Inspect TOTAL, after converting to numeric values, in gradaf15";
proc sql;
    select
     input(TOTAL,best12.) as Number_of_course_completers
    ,count(*)
    from
    gradaf15
    group by
    calculated Number_of_course_completers
    ;
quit;
title;

