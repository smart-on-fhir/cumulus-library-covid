-- ############################################################################
-- Table COVID19 PCR tests for COVID performed at the local hospital
-- **Likely does not include PCR tests from other healthcare settings**
--
-- Study Period: @core_study_period_covid
-- PCR Test Codes: @covid_define_pcr, @map_lab_code

CREATE TABLE covid_symptom__pcr AS
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
    covid_symptom__define_pcr AS pcr,
    covid_symptom__define_period AS p,
    covid_symptom__site_pcr,
    covid_symptom__study_period AS s
WHERE
    (s.encounter_ref = o.encounter_ref)
    AND (s.variant_era = p.variant_era)
    AND (o.lab_week BETWEEN p.variant_start AND p.variant_end)
    AND (o.lab_code.code = pcr.code)
    AND (o.lab_result.code IN (
        '260385009', 'Negative', 'NEGATIVE',
        '10828004', 'Positive', 'POSITIVE'
    ));

-- # TODO i2b2 specific lab result codes are hardcoded, should be covid_symptom__define_pcr
-- https://github.com/smart-on-fhir/cumulus-etl/issues/231