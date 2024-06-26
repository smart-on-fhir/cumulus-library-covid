-- TODO ED Note definition lives in core, not covid symptom (core__ed_note)
--  https://github.com/smart-on-fhir/cumulus-library-covid/issues/10

CREATE OR REPLACE VIEW covid_symptom__site_ed_note AS
SELECT
    t.from_system,
    t.from_code,
    t.from_display,
    t.system,
    t.code,
    t.display
FROM
    (
        VALUES
        (
            'BCH',
            'NOTE:149798455',
            'Emergency MD',
            'http://loinc.org',
            '34878-9',
            'Emergency medicine Note'
        ),
        (
            'BCH',
            'NOTE:159552404',
            'ED Note Scanned',
            'http://loinc.org',
            '34878-9',
            'Emergency medicine Note'
        ),
        (
            'BCH',
            'NOTE:3807712',
            'ED Note',
            'http://loinc.org',
            '34878-9',
            'Emergency medicine Note'
        ),
        (
            'BCH',
            'NOTE:189094644',
            'Emergency Dept Scanned Forms',
            'http://loinc.org',
            '34878-9',
            'Emergency medicine Note'
        ),
        (
            'BCH',
            'NOTE:189094576',
            'ED Scanned',
            'http://loinc.org',
            '34878-9',
            'Emergency medicine Note'
        ),
        (
            'BCH',
            'NOTE:3710480',
            'ED Consultation',
            'http://loinc.org',
            '51846-4',
            'Emergency department Consult note'
        )
    )
        AS t (from_system, from_code, from_display, system, code, display); --noqa: AL05
