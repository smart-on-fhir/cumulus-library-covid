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

CREATE TABLE covid_symptom__symptom AS
WITH mention AS (
    SELECT
        t.concept,
        t.concept.cui,
        nr.match.text AS match_text,
        nr.subject_id,
        nr.encounter_id,
        nr.docref_id
    FROM covid_symptom__nlp_results AS nr,
        UNNEST(match.conceptattributes) AS t (concept)
)

SELECT DISTINCT
    s.variant_era,
    s.subject_ref,
    s.encounter_ref,
    m.docref_id,
    def.pref AS symptom_display,
    s.start_date AS start_date,
    s.end_date AS end_date,
    s.author_week,
    s.author_month,
    s.age_group,
    s.gender,
    s.race_display,
    s.enc_class_code,
    s.ed_note
FROM mention AS m,
    covid_symptom__define_symptom_cui AS def,
    covid_symptom__study_period AS s
WHERE
    concept.cui = def.cui
    AND s.encounter_ref = CONCAT('Encounter/', m.encounter_id);


CREATE TABLE covid_symptom__symptom_icd10 AS
WITH temp_period AS (
    SELECT
        variant_era,
        subject_ref,
        encounter_ref,
        start_date,
        author_week,
        author_month,
        age_group,
        gender,
        race_display,
        enc_class_code
        AS ed_note
    FROM covid_symptom__study_period
),

icd10_list AS (
    SELECT DISTINCT
        code AS icd10_code,
        CONCAT('ICD10:', pref) AS icd10_display
    FROM covid_symptom__define_symptom WHERE code_system = 'ICD10CM'
    UNION
    SELECT DISTINCT
        code AS icd10_code,
        'ICD10:Influenza' AS icd10_display
    FROM covid_symptom__define_flu
)

SELECT DISTINCT
    temp_period.*,
    icd10_list.icd10_code,
    icd10_list.icd10_display
FROM temp_period,
    core__condition AS v,
    icd10_list
WHERE
    temp_period.encounter_ref = v.encounter_ref
    AND v.cond_code.coding[1].code = icd10_list.icd10_code; --noqa: RF02,LT01








-- ############################################################################
--  COVID19 Symptoms by Variant Era
--
CREATE OR REPLACE VIEW covid_symptom__count_symptom_week AS
WITH powerset AS (
    SELECT
        COUNT(DISTINCT subject_ref) AS cnt_subject,
        COUNT(DISTINCT encounter_ref) AS cnt_encounter,
        symptom_display,
        variant_era,
        author_week,
        age_group,
        gender,
        race_display,
        enc_class_code,
        ed_note
    FROM covid_symptom__symptom
    GROUP BY
        CUBE(
            symptom_display,
            variant_era,
            author_week,
            age_group,
            gender,
            race_display,
            enc_class_code,
            ed_note
        )
)

SELECT
    cnt_encounter AS cnt,
    symptom_display,
    variant_era,
    author_week,
    age_group,
    gender,
    race_display,
    enc_class_code,
    ed_note
FROM powerset
WHERE cnt_subject >= 10
ORDER BY author_week ASC, cnt_encounter DESC;
