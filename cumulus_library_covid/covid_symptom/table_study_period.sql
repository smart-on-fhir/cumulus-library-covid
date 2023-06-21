CREATE TABLE covid_symptom__study_period AS
SELECT DISTINCT
    v.variant_era,
    s.start_date,
    s.start_week,
    s.start_month,
    s.end_date,
    s.age_at_visit,
    s.author_date,
    s.author_week,
    s.author_month,
    s.author_year,
    s.gender,
    s.race_display,
    s.subject_ref,
    s.encounter_ref,
    s.doc_ref,
    s.diff_enc_note_days,
    s.enc_class_code,
    s.doc_type_code,
    s.doc_type_display,
    s.ed_note, -- TODO https://github.com/smart-on-fhir/cumulus-library-covid/issues/10
    a.age_group
FROM core__study_period AS s,
    covid_symptom__define_period AS v,
    covid_symptom__define_age AS a
WHERE
    s.age_at_visit = a.age
    AND s.gender IN ('female', 'male')
    AND s.author_date BETWEEN v.variant_start AND v.variant_end
    AND s.start_date BETWEEN v.variant_start AND v.variant_end
    AND s.diff_enc_note_days BETWEEN -30 AND 30;

CREATE TABLE covid_symptom__meta_date AS
SELECT
    min(start_date) AS min_date,
    max(end_date) AS max_date
FROM covid_symptom__study_period;

-- NOTICE! this is the study period BEFORE covid for retrospective comparison to FLU.
CREATE TABLE covid_symptom__study_period_2016 AS
WITH period_2016 AS (
    SELECT * FROM core__study_period WHERE ed_note -- noqa: AM04
),

period_2020 AS (
    SELECT DISTINCT
        period_2016.*,
        -- TODO https://github.com/smart-on-fhir/cumulus-library-covid/issues/11
        coalesce(cssp.variant_era, 'before-covid') AS variant_era,
        -- TODO https://github.com/smart-on-fhir/cumulus-library-covid/issues/9
        coalesce(csda.age_group, '>21') AS age_group
    FROM period_2016
    LEFT JOIN covid_symptom__define_age AS csda ON period_2016.age_at_visit = csda.age
    LEFT JOIN
        covid_symptom__study_period AS cssp
        ON period_2016.encounter_ref = cssp.encounter_ref
)

SELECT * FROM period_2020;