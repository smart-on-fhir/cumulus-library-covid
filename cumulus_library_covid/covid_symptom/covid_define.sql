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
