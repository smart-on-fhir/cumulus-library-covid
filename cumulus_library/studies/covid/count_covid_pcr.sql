-- ############################################################################
-- Table COVID19 PCR tests for COVID performed at the local hospital
-- **Likely does not include PCR tests from other healthcare settings**
--
-- Study Period: @core_study_period_covid
-- PCR Test Codes: @covid_define_pcr, @map_lab_code

CREATE TABLE covid__pcr AS
SELECT DISTINCT
    upper(o.lab_result.display) AS covid_pcr_result_display,
    o.lab_result AS covid_pcr_result,
    o.lab_code AS covid_pcr_code,
    o.lab_date AS covid_pcr_date,
    o.lab_week AS covid_pcr_week,
    o.lab_month AS covid_pcr_month,
    s.variant_era,
    s.author_date,
    s.author_week,
    s.author_month,
    s.ed_note,
    s.start_date,
    s.start_week,
    s.start_month,
    s.age_at_visit,
    s.gender,
    s.race_display,
    o.subject_ref,
    o.encounter_ref,
    o.observation_ref
FROM core__observation_lab AS o,
    covid__define_pcr AS pcr,
    covid__define_period AS p,
    covid__site_pcr,
    covid__study_period AS s
WHERE
    (s.encounter_ref = o.encounter_ref)
    AND (s.variant_era = p.variant_era)
    AND (o.lab_week BETWEEN p.variant_start AND p.variant_end)
    AND (o.lab_code.code = pcr.code)
    AND (o.lab_result.code IN (
        '260385009', 'Negative', 'NEGATIVE',
        '10828004', 'Positive', 'POSITIVE'
    ));

-- ############################################################################


CREATE OR REPLACE VIEW covid__count_pcr_week AS
WITH powerset AS (
    SELECT
        count(DISTINCT covid__pcr.subject_ref) AS cnt_subject,
        count(DISTINCT covid__pcr.encounter_ref) AS cnt_encounter,
        upper(covid_pcr_result.display) AS covid_pcr_result_display,
        covid__pcr.covid_pcr_week,
        covid__pcr.variant_era,
        covid__pcr.ed_note,
        covid__pcr.age_at_visit,
        covid__pcr.gender,
        covid__pcr.race_display
    FROM covid__pcr
    GROUP BY
        cube(
            covid__pcr.covid_pcr_result,
            covid__pcr.covid_pcr_week,
            covid__pcr.variant_era,
            covid__pcr.ed_note,
            covid__pcr.age_at_visit,
            covid__pcr.gender,
            covid__pcr.race_display
        )
)

SELECT DISTINCT
    cnt_encounter AS cnt,
    covid_pcr_result_display,
    covid_pcr_week,
    variant_era,
    ed_note,
    age_at_visit,
    gender,
    race_display
FROM powerset
WHERE cnt_subject >= 10
ORDER BY covid_pcr_week ASC, covid_pcr_result_display ASC;
