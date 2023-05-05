create TABLE covid__study_period AS
    select distinct V.variant_era, S.*, A.age_group
    from core__study_period S
        , covid__define_period V
        , covid__define_age A
    where S.age_at_visit = A.age
      and s.gender in ('female','male')
      and S.author_date between V.variant_start and V.variant_end
      and S.start_date  between V.variant_start and V.variant_end
      and diff_enc_note_days between -30 and 30
;

CREATE TABLE covid__meta_date AS
    select min(start_date) as min_date, max(end_date) as max_date
FROM covid__study_period
;

-- NOTICE! this is the study period BEFORE covid for retrospective comparison to FLU.
CREATE table covid__study_period_2016 as
with period_2016 as(
      select * FROM  core__study_period P where ed_note
),
period_2020 as (
    select distinct
          period_2016.*
        , case when covid__study_period.variant_era is not null
                then covid__study_period.variant_era
                else 'before-covid' end as variant_era
        , case when covid__define_age.age_group is not null
            then covid__define_age.age_group else '>21' end as age_group
    FROM  period_2016
    left join covid__define_age on period_2016.age_at_visit = covid__define_age.age
    left join covid__study_period on period_2016.encounter_ref = covid__study_period.encounter_ref
)
select * from period_2020
;

create table covid__count_study_period as
with powerset as (
    select
          variant_era
        , start_month
        , ed_note
        , gender
        , age_group
        , race_display
    ,count(distinct subject_ref) as cnt_subject
    ,count(distinct encounter_ref) as cnt_encounter
    from    covid__study_period
    where   start_month between date('2020-03-01') and date('2022-06-01')
    group by cube(variant_era, start_month, ed_note, gender, age_group, race_display)
)
    select   variant_era, start_month, ed_note, gender, age_group, race_display
            ,cnt_encounter as cnt
    from powerset
    where cnt_subject >= 10
    order by start_month asc, cnt_encounter desc
;
