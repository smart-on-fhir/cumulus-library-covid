from library.schema import counts

def count_covid_prevalence_ed_month():
    view_name = 'count_covid_prevalence_ed_month'
    from_table = 'covid_prevalence_ed'
    cols = ['covid_icd10',
            'covid_pcr_result',
            'covid_symptom',
            'symptom_icd10_display',
            'variant_era',
            'author_month',
            'age_group']

    return counts.count_encounter(view_name, from_table, cols)
