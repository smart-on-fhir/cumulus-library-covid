-- ####################################
CREATE or replace VIEW covid_symptom__count_dx_week AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , cond_week, enc_class_code, age_at_visit, ed_note, variant_era        
        FROM covid_symptom__dx
        group by CUBE
        ( cond_week, enc_class_code, age_at_visit, ed_note, variant_era )
    )
    select
          cnt_encounter  as cnt 
        , cond_week, enc_class_code, age_at_visit, ed_note, variant_era
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_dx_month AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , cond_month, enc_class_code, age_at_visit, ed_note, variant_era        
        FROM covid_symptom__dx
        group by CUBE
        ( cond_month, enc_class_code, age_at_visit, ed_note, variant_era )
    )
    select
          cnt_encounter  as cnt 
        , cond_month, enc_class_code, age_at_visit, ed_note, variant_era
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_pcr_week AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , covid_pcr_week, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display        
        FROM covid_symptom__pcr
        group by CUBE
        ( covid_pcr_week, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display )
    )
    select
          cnt_encounter  as cnt 
        , covid_pcr_week, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_pcr_month AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , covid_pcr_month, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display        
        FROM covid_symptom__pcr
        group by CUBE
        ( covid_pcr_month, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display )
    )
    select
          cnt_encounter  as cnt 
        , covid_pcr_month, covid_pcr_result_display, variant_era, ed_note, age_at_visit, gender, race_display
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_study_period_week AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , start_week, variant_era, start_month, ed_note, gender, age_group, race_display        
        FROM covid_symptom__study_period
        group by CUBE
        ( start_week, variant_era, start_month, ed_note, gender, age_group, race_display )
    )
    select
          cnt_encounter  as cnt 
        , start_week, variant_era, start_month, ed_note, gender, age_group, race_display
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_study_period_month AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , start_month, variant_era, start_month, ed_note, gender, age_group, race_display        
        FROM covid_symptom__study_period
        group by CUBE
        ( start_month, variant_era, start_month, ed_note, gender, age_group, race_display )
    )
    select
          cnt_encounter  as cnt 
        , start_month, variant_era, start_month, ed_note, gender, age_group, race_display
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;


-- ####################################
CREATE or replace VIEW covid_symptom__count_study_period_year AS 
    with powerset as
    (
        select
        count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref)   as cnt_encounter
        , start_year, variant_era, start_month, ed_note, gender, age_group, race_display        
        FROM covid_symptom__study_period
        group by CUBE
        ( start_year, variant_era, start_month, ed_note, gender, age_group, race_display )
    )
    select
          cnt_encounter  as cnt 
        , start_year, variant_era, start_month, ed_note, gender, age_group, race_display
    from powerset 
    WHERE cnt_subject >= 10 
    ORDER BY cnt desc;

