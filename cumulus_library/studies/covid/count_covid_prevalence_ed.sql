CREATE table covid__prevalence_ed as
with from_period as(
      select distinct
          encounter_ref
        , subject_ref
        , author_week
        , author_month
        , gender
        , race_display
        , age_at_visit
        , age_group
        , variant_era
    FROM  covid__study_period
    where ed_note
),
join_2020 as (
    select distinct
          P.encounter_ref
        , P.subject_ref
        , P.author_week
        , P.author_month
        , P.gender
        , P.race_display
        , P.age_group
        , P.variant_era
        , case when PCR.covid_pcr_result_display is not null then PCR.covid_pcr_result_display else 'No PCR' end as covid_pcr_result
        , case when DX.cond_code is not null then 'COVID ICD10' else 'No COVID ICD10'  end as covid_icd10
        , case when (DX.cond_code is not null or PCR.covid_pcr_result_display = 'POSITIVE') then 'COVID DX' else 'No COVID DX'  end as covid_dx
        , case when NLP.symptom_display is not null then NLP.symptom_display else 'No Symptom' end as covid_symptom
        , case when ICD10.icd10_display is not null then ICD10.icd10_display else 'No Symptom ICD10' end as symptom_icd10_display
    FROM  from_period P
    left join covid__dx  DX  on P.encounter_ref = DX.encounter_ref
    left join covid__pcr PCR on P.encounter_ref = PCR.encounter_ref
    left join covid__symptom NLP on P.encounter_ref = NLP.encounter_ref
    left join covid__symptom_icd10 ICD10 on P.encounter_ref = ICD10.encounter_ref
)
select * from join_2020
order by author_week, variant_era
;


create or replace view covid__count_prevalence_ed_month as
with powerset as
(
    select count(distinct encounter_ref) as cnt
        ,count(distinct subject_ref) as cnt_subject
        , covid_dx
        , covid_icd10
        , covid_pcr_result
        , covid_symptom
        , symptom_icd10_display
        , variant_era
        , author_month
        , age_group
    from covid__prevalence_ed
    group by CUBE (
          covid_dx
        , covid_icd10

        , covid_pcr_result
        , covid_symptom
        , symptom_icd10_display
        , variant_era
        , author_month
        , age_group)
)
select 
        cnt
        , covid_dx
        , covid_icd10
        , covid_pcr_result
        , covid_symptom
        , symptom_icd10_display
        , variant_era
        , author_month
        , age_group
from powerset
where cnt_subject >= 10
order by author_month asc, cnt desc
;



