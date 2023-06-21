create or replace view covid_symptom__define_dx_icd10 as select * from (values
('http://hl7.org/fhir/sid/icd-10-cm', 'U07.1', 'COVID-19')
) AS t (system, code, display) ;
