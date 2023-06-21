-- ############################################################################
-- Table COVID19 Diagnosis

CREATE TABLE covid_symptom__dx AS
SELECT DISTINCT
    c.subject_ref,
    c.encounter_ref,
    c.cond_code.coding[1].code AS cond_code, -- noqa: LT01,RF02
    c.recorded_week AS cond_week,
    s.enc_class_code,
    s.age_at_visit,
    s.ed_note,
    s.variant_era
FROM core__condition AS c,
    covid_symptom__study_period AS s,
    covid_symptom__define_dx AS dx
WHERE
    c.cond_code.coding[1].code = dx.code -- noqa: LT01,RF02
    AND c.encounter_ref = s.encounter_ref;