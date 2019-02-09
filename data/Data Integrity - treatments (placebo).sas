* check Placebo & Treatment for bad/missing id values;
proc sql;
    /* check for missing id values; after executing this query, we
       see that treatments_dups only has one row, which just happens to 
       have all three elements of the componsite key missing, which we can
       mitigate as part of eliminating rows having missing unique id component
       in the next query */
    create table treatments_dups as
        select
             patient_id
			,treatment_group
            ,count(*) as row_count_for_unique_id_value
        from
            Treatment
        group by
             patient_id
			,treatment_group
        having
            row_count_for_unique_id_value > 1
    ;
    /* there is no missing id components in our dataset */

quit;
