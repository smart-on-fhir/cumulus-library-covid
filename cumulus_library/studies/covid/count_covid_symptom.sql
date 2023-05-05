
--desc covid_symptom__nlp_results;
--id                  	string
--docref_id           	string
--encounter_id        	string
--subject_id          	string
--match               	struct<
--    begin:bigint,
--    end:bigint,
--    polarity:bigint,
--    text:string,
--    type:string,
--    conceptAttributes:array<struct<
--        code:string,
--        codingScheme:string,
--        cui:string,
--        tui:string>>>

-- ############################################################################
-- Table COVID19 Symptoms
--
-- @covid_define_symptom_cui
--

create table covid__symptom as
with mention AS
(
    select concept, concept.cui
        , match.text as match_text
        , subject_id
        , encounter_id
        , docref_id
    from covid_symptom__nlp_results
    ,UNNEST(match.conceptattributes) t (concept)
)
     select distinct
              S.variant_era
            , S.subject_ref
            , S.encounter_ref
            , M.docref_id
	        , DEF.PREF as symptom_display
	        , S.start_date as start_date
	        , S.end_date as end_date
	        , S.author_week
	        , S.author_month
	        , S.age_group
	        , S.gender
	        , S.race_display
            , S.enc_class_code
            , S.ed_note
     from	  mention as M
            , covid__define_symptom_cui as DEF
            , covid__study_period as S
     where 	concept.cui = DEF.CUI
         and S.encounter_ref = concat('Encounter/', M.encounter_id)
;


create TABLE covid__symptom_icd10 as
with temp_period as (
    select
         variant_era
        ,subject_ref
        ,encounter_ref
        ,start_date
        ,author_week
        ,author_month
        ,age_group
        ,gender
        ,race_display
        ,enc_class_code
        ed_note
    from covid__study_period
),
icd10_list as
(
    select distinct code as icd10_code
        , concat('ICD10:',pref) as icd10_display
        from covid__define_symptom where code_system='ICD10CM'
    UNION
    select distinct code as icd10_code
        , 'ICD10:Influenza' as icd10_display from covid__define_flu
)
select distinct temp_period.*
    , icd10_list.icd10_code
    , icd10_list.icd10_display
from  temp_period
    , core__condition V
    , icd10_list
where temp_period.encounter_ref = V.encounter_ref
and V.cond_code.coding[1].code = icd10_code
;








-- ############################################################################
--  COVID19 Symptoms by Variant Era
--
create or replace view covid__count_symptom_week AS
    with powerset as (
    select
          count(distinct subject_ref)   as cnt_subject
        , count(distinct encounter_ref) as cnt_encounter
        , symptom_display
        , variant_era
        , author_week
        , age_group
        , gender
        , race_display
        , enc_class_code
        , ed_note
    from covid__symptom
    group by CUBE(
          symptom_display
        , variant_era
        , author_week
        , age_group
        , gender
        , race_display
        , enc_class_code
        , ed_note)
)
select
      cnt_encounter as cnt
    , symptom_display
    , variant_era
    , author_week
    , age_group
    , gender
    , race_display
    , enc_class_code
    , ed_note
from powerset
where cnt_subject >= 10
order by author_week, cnt_encounter desc;



