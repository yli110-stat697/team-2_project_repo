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
            ,adverse_reaction
            ,count(*) as row_count_for_placebo_obs
        from
            placebo
        group by
             patient_id
            ,day_on_drug
            ,adverse_reaction
        having
            row_count_for_placebo_obs > 1
    ;
    /* remove rows with missing unique id components, or with unique ids that
       do not correspond to schools; after executing this query, the new
       dataset frpm1516 will have no duplicate/repeated unique id values,
       and all unique id values will correspond to our experimenal units of
       interest, which are California Public K-12 schools; this means the 
       columns County_Code, District_Code, and School_Code in frpm1516 are 
       guaranteed to form a composite key */
    create table frpm1516 as
        select
            *
        from
            frpm1516_raw
        where
            /* remove rows with missing unique id value components */
            not(missing(County_Code))
            and
            not(missing(District_Code))
            and
            not(missing(School_Code))
            and
            /* remove rows for District Offices and non-public schools */
            School_Code not in ("0000000","0000001")
    ;
quit;


* check gradaf15_raw for bad unique id values, where the column CDS_CODE is 
intended to be a primary key;
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools; after executing this query, we see that
       gradaf15_raw_bad_unique_ids only has non-school values of CDS_Code that
       need to be removed */
    /* note to learners: the query below uses an in-line view together with a
       left join (see Chapter 3 for definitions) to isolate all problematic
       rows within a single query; it would have been just as valid to use
       mulitple queries, as above, but it's often convenient to use a single
       query to create a table with speficic properties; in particular, in the
       above two examples, we blindly eliminated rows having specific
       properties when creating frpm1415 and frpm1516, whereas the query below
       allows us to build a fit-for-purpose mitigation step with no guessing
       or unnecessary effort */
    create table gradaf15_raw_bad_unique_ids as
        select
            A.*
        from
            gradaf15_raw as A
            left join
            (
                select
                     CDS_CODE
                    ,count(*) as row_count_for_unique_id_value
                from
                    gradaf15_raw
                group by
                    CDS_CODE
            ) as B
            on A.CDS_CODE=B.CDS_CODE
        having
            /* capture rows corresponding to repeated primary key values */
            row_count_for_unique_id_value > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(CDS_CODE)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(CDS_CODE,8,7) in ("0000000","0000001")
    ;
    /* remove rows with primary keys that do not correspond to schools; after
       executing this query, the new dataset gradaf15 will have no
       duplicate/repeated unique id values, and all unique id values will
       correspond to our experimenal units of interest, which are California
       Public K-12 schools; this means the column CDS_Code in gradaf15 is 
       guaranteed to form a primary key */
    create table gradaf15 as
        select
            *
        from
            gradaf15_raw
        where
            /* remove rows for District Offices and non-public schools */
            substr(CDS_CODE,8,7) not in ("0000000","0000001")
    ;
quit;


* check sat15_raw for bad unique id values, where the column CDS is intended
to be a primary key;
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools; after executing this query, we see that
       sat15_raw_bad_unique_ids only has non-school values of CDS that need to
       be removed */
    create table sat15_raw_bad_unique_ids as
        select
            A.*
        from
            sat15_raw as A
            left join
            (
                select
                     CDS
                    ,count(*) as row_count_for_unique_id_value
                from
                    sat15_raw
                group by
                    CDS
            ) as B
            on A.CDS=B.CDS
        having
            /* capture rows corresponding to repeated primary key values */
            row_count_for_unique_id_value > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(CDS)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(CDS,8,7) in ("0000000","0000001")
    ;
    /* remove rows with primary keys that do not correspond to schools; after
       executing this query, the new dataset gradaf15 will have no
       duplicate/repeated unique id values, and all unique id values will
       correspond to our experimenal units of interest, which are California
       Public K-12 schools; this means the column CDS in sat15 is guaranteed
       to form a primary key */
    create table sat15 as
        select
            *
        from
        sat15_raw
    where
        /* remove rows for District Offices */
        substr(CDS,8,7) ne "0000000"
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

