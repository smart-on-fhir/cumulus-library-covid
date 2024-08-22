"""Gpt unit tests"""

import datetime
import os
import tempfile
import unittest

import duckdb
import pandas
from cumulus_library import cli


class GptTestCase(unittest.TestCase):
    """Test case for the gpt symptom tables."""

    def setUp(self):
        super().setUp()
        self.maxDiff = None

    @staticmethod
    def register(db: duckdb.DuckDBPyConnection, name: str, table: pandas.DataFrame) -> None:
        db.register(f"{name}_df", table)
        db.sql(f"CREATE TABLE {name} AS SELECT * FROM {name}_df")

    def make_core_tables(self, db: duckdb.DuckDBPyConnection) -> None:
        """Make a single core encounter, patient, and docref"""
        encounter = pandas.DataFrame(
            {
                "period_start_day": [datetime.date(2016, 10, 10)],
                "period_start_week": [datetime.date(2016, 10, 10)],
                "period_start_month": [datetime.date(2016, 10, 1)],
                "period_end_day": [datetime.date(2016, 10, 11)],
                "age_at_visit": [12],
                "status": ["finished"],
                "class_code": [None],
                "class_display": [None],
                "encounter_ref": ["Encounter/E1"],
                "subject_ref": ["Patient/P1"],
            }
        )
        self.register(db, "core__encounter", encounter)

        patient = pandas.DataFrame(
            {
                "gender": ["unknown"],
                "race_display": [None],
                "ethnicity_display": [None],
                "subject_ref": ["Patient/P1"],
            }
        )
        self.register(db, "core__patient", patient)

        condition = pandas.DataFrame(
            {
                "recordeddate_day": [datetime.date(2016, 10, 10)],
                "recordeddate_week": [datetime.date(2016, 10, 10)],
                "recordeddate_month": [datetime.date(2016, 10, 1)],
                "recordeddate_year": [datetime.date(2016, 1, 1)],
                "code": ["U07.1"],
                "encounter_ref": ["Encounter/E1"],
                "subject_ref": ["Patient/P1"],
            }
        )
        self.register(db, "core__condition", condition)

        docref = pandas.DataFrame(
            {
                "author_day": [datetime.date(2016, 10, 10)],
                "author_week": [datetime.date(2016, 10, 10)],
                "author_month": [datetime.date(2016, 10, 1)],
                "author_year": [datetime.date(2016, 1, 1)],
                "type_code": ["34878-9"],
                "type_display": ["Emergency medicine Note"],
                "documentreference_ref": ["DocumentReference/D1"],
                "encounter_ref": ["Encounter/E1"],
                "subject_ref": ["Patient/P1"],
            }
        )
        self.register(db, "core__documentreference", docref)

        lab = pandas.DataFrame(
            {
                "observation_code": ["94309-2"],
                "effectivedatetime_day": [datetime.date(2016, 10, 10)],
                "effectivedatetime_week": [datetime.date(2016, 10, 10)],
                "effectivedatetime_month": [datetime.date(2016, 10, 1)],
                "valuecodeableconcept_code": ["10828004"],
                "observation_ref": ["Observation/O1"],
                "encounter_ref": ["Encounter/E1"],
                "subject_ref": ["Patient/P1"],
            }
        )
        self.register(db, "core__observation_lab", lab)

        ed_note = pandas.DataFrame(
            {
                "code": ["34878-9"],
                "from_code": ["149798455"],
            }
        )
        self.register(db, "core__ed_note", ed_note)

        nlp = pandas.DataFrame(
            {
                "docref_id": ["D1"],
                "encounter_id": ["E1"],
                "subject_id": ["P1"],
                "match": [
                    {
                        "conceptattributes": [
                            {"cui": "C0027424"},
                        ],
                        "text": "Congestion",
                    }
                ],
            }
        )
        self.register(db, "covid_symptom__nlp_results", nlp)

    def make_gpt_table(self, db: duckdb.DuckDBPyConnection, name: str, **kwargs) -> None:
        symptoms = {
            "congestion_or_runny_nose": False,
            "cough": False,
            "diarrhea": False,
            "dyspnea": False,
            "fatigue": False,
            "fever_or_chills": False,
            "headache": False,
            "loss_of_taste_or_smell": False,
            "muscle_or_body_aches": False,
            "nausea_or_vomiting": False,
            "sore_throat": False,
        }
        symptoms.update(kwargs)
        table = pandas.DataFrame(
            {
                "encounter_id": ["E1"],
                "docref_id": ["D1"],
                "symptoms": [symptoms],
            }
        )
        self.register(db, f"covid_symptom__nlp_results_{name}", table)

    def test_happy_path(self) -> None:
        """Runs the study on some input data and spot-checks the gpt results"""
        test_dir = os.path.dirname(__file__)
        root_dir = os.path.dirname(test_dir)
        study_dir = f"{root_dir}/cumulus_library_covid"

        with tempfile.TemporaryDirectory() as tmpdir:
            db = duckdb.connect(f"{tmpdir}/duck.db")
            self.make_core_tables(db)
            self.make_gpt_table(db, "gpt35", cough=True, fever_or_chills=True)
            self.make_gpt_table(db, "gpt4")  # test that we mark no-symptom-found docrefs
            db.close()

            cli.main(
                [
                    "build",
                    # "--verbose",
                    "--target=covid_symptom",
                    f"--study-dir={study_dir}",
                    "--db-type=duckdb",
                    f"--database={tmpdir}/duck.db",
                ]
            )
            db = duckdb.connect(f"{tmpdir}/duck.db")

            # Confirm we flag the right symptoms when present
            rel = db.sql("SELECT * FROM covid_symptom__symptom_gpt35")
            rows = rel.order("symptom_display").fetchall()
            self.assertEqual(
                [
                    ("Encounter/E1", "DocumentReference/D1", "Cough"),
                    ("Encounter/E1", "DocumentReference/D1", "Fever or chills"),
                ],
                rows,
            )

            # Confirm we flag a no-results docref too
            rel = db.sql("SELECT * FROM covid_symptom__symptom_gpt4")
            rows = rel.order("symptom_display").fetchall()
            self.assertEqual(
                [
                    ("Encounter/E1", "DocumentReference/D1", ""),
                ],
                rows,
            )
