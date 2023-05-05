-- ############################################################################
-- Table COVID19 Diagnosis

create TABLE covid__dx as
select distinct
      C.subject_ref
    , C.encounter_ref
    , C.cond_code.coding[1].code as cond_code
    , C.recorded_week as cond_week
    , S.enc_class_code
    , S.age_at_visit
    , S.ed_note
    , S.variant_era
from core__condition C
    , covid__study_period S
    , covid__define_dx DX
where C.cond_code.coding[1].code = DX.code
  and C.encounter_ref = S.encounter_ref
;

create or replace view covid__count_dx_week as
with powerset as (
    select    count(distinct subject_ref)   AS cnt_subject
            , count(distinct encounter_ref) AS cnt_encounter
            , cond_week
            , enc_class_code
            , age_at_visit
            , ed_note
            , variant_era
    from	covid__dx  DX
    group by CUBE(
              cond_week
            , enc_class_code
            , age_at_visit
            , ed_note
            , variant_era)
)
select cnt_encounter as cnt
        , cond_week, enc_class_code, age_at_visit, ed_note, variant_era
from powerset
where cnt_subject >= 10 order by cnt desc
;

