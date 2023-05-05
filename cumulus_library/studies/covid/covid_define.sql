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

-- ############################################################################
-- COVID19 Diagnosis

create or replace view covid__define_dx as 
    select t.code_system, t.code, t.display from
(VALUES
     ('http://hl7.org/fhir/sid/icd-10-cm', 'U07.1', 'COVID-19')
) AS t (code_system, code, display)
;


-- ############################################################################
-- COVID19 PCR

create or replace view covid__define_pcr as 
    select t.code_system, t.code, t.display from
(VALUES
      ('http://loinc.org', '94500-6', 'SARS-CoV-2 (COVID-19) RNA [Presence] in Respiratory specimen by NAA with probe detection')
     ,('http://loinc.org', '95406-5', 'SARS-CoV-2 (COVID-19) RNA [Presence] in Nose by NAA with probe detection')
) AS t (code_system, code, display)
;

create or replace view covid__define_pcr_result as 
    select t.code_system, t.code, t.display, t.boolean_flag from
(VALUES
     ('http://snomed.info/sct', '10828004',  'Positive',    TRUE)
    ,('http://snomed.info/sct', '260385009', 'Negative',    FALSE)
    ,('http://snomed.info/sct', '272519000', 'Absent',      NULL)
    ,('http://hl7.org/fhir/us/covid19library/CodeSystem/covid19-lab-values-cs', 'invalid', 'Invalid', NULL)
) AS t (code_system,  code, display, boolean_flag)
;

-- ############################################################################
-- COVID19 Symptom CUI (UMLS Unified Medical Language System)

create or replace view covid__define_symptom_cui as 
    select t.cui,t.pref from (VALUES
  ('C0027424', 'Congestion or runny nose')
 ,('C1260880', 'Congestion or runny nose')
 ,('C0010200', 'Cough')
 ,('C0850149', 'Cough')
 ,('C0239134', 'Cough')
 ,('C0011991', 'Diarrhea')
 ,('C0015672', 'Fatigue')
 ,('C0231218', 'Fatigue')
 ,('C0085593', 'Fever or chills')
 ,('C0015967', 'Fever or chills')
 ,('C0085594', 'Fever or chills')
 ,('C0018681', 'Headache')
 ,('C0231528', 'Muscle or body aches')
 ,('C0281856', 'Muscle or body aches')
 ,('C0027497', 'Nausea or vomiting')
 ,('C0042963', 'Nausea or vomiting')
 ,('C0027498', 'Nausea or vomiting')
 ,('C0003126', 'Loss of taste or smell')
 ,('C1332239', 'Loss of taste or smell')
 ,('C0013404', 'Dyspnea')
 ,('C0242429', 'Sore throat'))
 AS t (cui, pref)
 ;

-- Influenza symptoms are a subset of the COVID symptoms, and important as a comparison.
create or replace view covid__define_flu as
    select distinct code, code_display from vocab__icd_legend C
    where ( C.code like '487%' or C.code like '488%' or c.code like 'J12.9%' or c.code like 'J11%' or c.code like 'J10%' or c.code like 'J09%')
;

-- ############################################################################
-- COVID19 Age Groups (primarily for Suicidality study)

create or replace view covid__define_age as 
select t.age, t.age_group from
(VALUES
      (0, '<5')
     ,(1, '<5')
     ,(2, '<5')
     ,(3, '<5')
     ,(4, '<5')
     ,(5, '=>5')
     ,(6, '=>5')
     ,(7, '=>5')
     ,(8, '=>5')
     ,(9, '=>5')
     ,(10, '=>5')
     ,(11, '=>5')
     ,(12, '=>5')
     ,(13, '=>5')
     ,(14, '=>5')
     ,(15, '=>5')
     ,(16, '=>5')
     ,(17, '=>5')
     ,(18, '=>5')
     ,(19, '=>5')
     ,(20, '=>5')
     ,(21, '=>5')
) AS t (age, age_group)
;

-- ############################################################################
-- COVID19 Study Period for Variant Eras
--
-- Variant eras are defined using COVID-19 data for Massachusetts from CoVariant [16].
-- Pre-Delta era was defined as March 1, 2020 to June 20, 2021
-- Delta era as June 21, 2021 to December 19, 2021
-- Omicron era as December 20, 2021 onwards.

create or replace view covid__define_period as 
    select t.variant_era, t.variant_start, t.variant_end from (VALUES
--  ('before-covid', date('2020-02-29'), date('2021-02-28'))
  ('before-delta', date('2020-03-01'), date('2021-06-20'))
 ,('delta',     date('2021-06-21'), date('2021-12-19'))
 ,('omicron',   date('2021-12-20'), date('2022-06-01')))
AS t (variant_era, variant_start, variant_end)
;





