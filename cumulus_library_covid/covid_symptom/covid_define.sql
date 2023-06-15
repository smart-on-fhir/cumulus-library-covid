-- ############################################################################
-- BCH Boston Children's Hospital
--
-- Site vocabularies :
-- * ICD-10 diagnosis codes ;
-- * LOINC for laboratory values and encounter documents
--
-- Other sites may have different "fhir_terminology" reflecting the local EMR/medical coding practice.
--
-- ValueSet expansion
-- https://www.nlm.nih.gov/vsac/support/usingvsac/covid19valuesets.html
-- http://build.fhir.org/ig/HL7/fhir-COVID19Library-ig/ValueSet-covid19-pos-neg-inv-vs.html

CREATE OR REPLACE VIEW covid_symptom__define_pcr_result AS
SELECT
    t.code_system,
    t.code,
    t.display,
    t.boolean_flag
FROM
    (
        VALUES
        ('http://snomed.info/sct', '10828004', 'Positive', TRUE),
        ('http://snomed.info/sct', '260385009', 'Negative', FALSE),
        ('http://snomed.info/sct', '272519000', 'Absent', NULL),
        (
            'http://hl7.org/fhir/us/covid19library/CodeSystem/covid19-lab-values-cs',
            'invalid',
            'Invalid',
            NULL
        )
    ) AS t (code_system, code, display, boolean_flag);

-- ############################################################################
-- COVID19 Symptom CUI (UMLS Unified Medical Language System)

CREATE OR REPLACE VIEW covid_symptom__define_symptom_cui AS
SELECT
    t.cui,
    t.pref
FROM (
    VALUES
    ('C0027424', 'Congestion or runny nose'),
    ('C1260880', 'Congestion or runny nose'),
    ('C0010200', 'Cough'),
    ('C0850149', 'Cough'),
    ('C0239134', 'Cough'),
    ('C0011991', 'Diarrhea'),
    ('C0015672', 'Fatigue'),
    ('C0231218', 'Fatigue'),
    ('C0085593', 'Fever or chills'),
    ('C0015967', 'Fever or chills'),
    ('C0085594', 'Fever or chills'),
    ('C0018681', 'Headache'),
    ('C0231528', 'Muscle or body aches'),
    ('C0281856', 'Muscle or body aches'),
    ('C0027497', 'Nausea or vomiting'),
    ('C0042963', 'Nausea or vomiting'),
    ('C0027498', 'Nausea or vomiting'),
    ('C0003126', 'Loss of taste or smell'),
    ('C1332239', 'Loss of taste or smell'),
    ('C0013404', 'Dyspnea'),
    ('C0242429', 'Sore throat')
)
AS t (cui, pref);
