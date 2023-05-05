import sys
import ctakesclient

def main(args):
    symptoms_list = ctakesclient.filesystem.covid_symptoms()

    values_sql = [f"('{bsv.cui}','{bsv.tui}','{bsv.code}','{bsv.vocab}','{bsv.text}','{bsv.pref}')" for bsv in symptoms_list]
    values_sql = '\n,'.join(values_sql)

    table_cols = 'AS t (cui, tui, code, system, text, pref);'
    create_view = f'create or replace view covid_define_symptom as select * from (VALUES \n {values_sql}) \n {table_cols}'

    with open('covid_define_symptom.sql', 'w') as f:
        f.write(create_view)


if __name__ == "__main__":
    main(sys.argv[1:])
