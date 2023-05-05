-- ############################################################################
-- Table COVID19 PCR tests for COVID performed at the local hospital
-- **Likely does not include PCR tests from other healthcare settings**
--
-- Study Period: @core_study_period_covid
-- PCR Test Codes: @covid_define_pcr, @map_lab_code

create table covid__pcr as
     select  distinct
	         upper(O.lab_result.display) as covid_pcr_result_display
	        ,O.lab_result as covid_pcr_result
	        ,O.lab_code   as covid_pcr_code
	        ,O.lab_date   as covid_pcr_date
	        ,O.lab_week   as covid_pcr_week
	        ,O.lab_month  as covid_pcr_month
            ,S.variant_era
            ,S.author_date
            ,S.author_week
            ,S.author_month
            ,S.ed_note
            ,S.start_date
            ,S.start_week
            ,S.start_month
	        ,S.age_at_visit
	        ,S.gender
	        ,S.race_display
            ,O.subject_ref
            ,O.encounter_ref
            ,O.observation_ref
     from	 core__observation_lab as O
            , covid__define_pcr as PCR
            , covid__define_period P
            , covid__site_pcr as SITE
            , covid__study_period S
     where 	(S.encounter_ref = O.encounter_ref)
       AND  (S.variant_era = P.variant_era)
       AND  (O.lab_week between P.variant_start and P.variant_end)
       AND  (O.lab_code.code = PCR.code)
       AND  (O.lab_result.code in (
                '260385009', 'Negative', 'NEGATIVE',
                '10828004', 'Positive', 'POSITIVE'));

-- ############################################################################


create or replace view covid__count_pcr_week as
with powerset as (
    select
         count(distinct subject_ref) AS cnt_subject
        ,count(distinct encounter_ref) AS cnt_encounter
        ,upper(covid_pcr_result.display) as covid_pcr_result_display
        ,covid_pcr_week
        ,variant_era
        ,ed_note
        ,age_at_visit
        ,gender
        ,race_display
    from	covid__pcr
    group by CUBE (
         covid_pcr_result
        ,covid_pcr_week
        ,variant_era
        ,ed_note
        ,age_at_visit
        ,gender
        ,race_display)
)
select distinct cnt_encounter as cnt
	        ,covid_pcr_result_display
	        ,covid_pcr_week
	        ,variant_era
	        ,ed_note
	        ,age_at_visit
	        ,gender
	        ,race_display
from     powerset
where    cnt_subject >=10
order by covid_pcr_week asc, covid_pcr_result_display
;


