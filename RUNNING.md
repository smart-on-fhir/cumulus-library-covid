# Running the COVID study

This guide will help you reproduce the COVID study from scratch.

This includes not only the SQL in this Cumulus Library study,
but also the chart review side of things.

## Prerequisites

- An existing Cumulus stack, with an already-built `core` study.
  - See the general [Cumulus documentation](https://docs.smarthealthit.org/cumulus/)
    for setting that up.
- Install this repo with `pip install cumulus-library-covid`

## 1. Prepare your data

This study operates on DocumentReference resources
(it runs NLP on the referenced clinical notes).
So we need to make sure you've got those handy.

Gather some DocumentReference ndjson from your EHR.
You can either re-export the documents of interest,
or use ndjson from a previous export.

If you are choosing a subset of documents,
make sure to pull resources between March 2020 and June 2022.
That's the study period of interest.

Place the ndjson in a folder using filenames like `*.DocumentReference.*.ndjson`.

## 2. Run the ETL & Library study

- There are [separate instructions](https://docs.smarthealthit.org/cumulus/etl/studies/covid-symptom.html)
  for running the ETL and this COVID study's NLP
- You should probably re-run your Cumulus AWS Glue crawler at this point,
  to pick up this new NLP table and its schema.
- Then run this study with [cumulus-library](https://docs.smarthealthit.org/cumulus/library/)
  like so: `cumulus-library ... -t covid_symptom`

You should now have all the interesting results sitting in Athena.

## 3. Export from Athena

In Athena's web console, run these commands and download the CSV results,
using the given filenames (we will refer back to these filenames later):
- **ctakes.csv** (if you ran cTAKES): `select encounter_ref, symptom_display from covid_symptom__symptom_ctakes_negation`
- **gpt35.csv** (if you ran ChatGPT 3.5): `select encounter_ref, symptom_display from covid_symptom__symptom_gpt35`
- **gpt4.csv** (if you ran ChatGPT 4): `select encounter_ref, symptom_display from covid_symptom__symptom_gpt4`
- **docrefs.csv**: `select distinct docref_id from covid_symptom__symptom_ctakes_negation`
- **icd10.csv**: `select encounter_ref, substring(icd10_display, 7) as symptom_display from covid_symptom__symptom_icd10`

And with that, the natural language processing of notes is finished.
The rest of this guide will be about setting up a chart review for human comparison with NLP.

## 4. Configure Label Studio

- Install Label Studio according to [their docs](https://labelstud.io/guide/install.html).
- Create a new project, named however you like.
  - Skip the Data Import tab.
  - On the Label Setup tab, click "Custom template" on the bottom left and enter this config:
```
<View>
  <Labels name="label" toName="text">
    <Label value="Congestion or runny nose" background="#100"/>
    <Label value="Cough" background="#040"/>
    <Label value="Diarrhea" background="#008"/>
    <Label value="Dyspnea" background="#b00"/>
    <Label value="Fatigue" background="#0f0"/>
    <Label value="Fever or chills" background="#40a"/>
    <Label value="Headache" background="#afa"/>
    <Label value="Loss of taste or smell" background="#f0f"/>
    <Label value="Muscle or body aches" background="#9bf"/>
    <Label value="Nausea or vomiting" background="#0aa"/>
    <Label value="Sore throat" background="#a44"/>
  </Labels>
  <Text name="text" value="$text"/>
</View>
```

Once created, you will be looking at an empty project page.
Take note of the new URL, you'll need to know the Label Studio project ID later
(the number after `/projects/` in the URL).

## 5. Upload notes to Label Studio

- Review the Cumulus ETL [upload-notes docs](https://docs.smarthealthit.org/cumulus/etl/chart-review.html)
- You'll want to run `upload-notes` with the following options:
```shell
cumulus-etl upload-notes ... \
  <input folder with ndjson files from step 1 above> \
  <label studio url> \
  <your typical ETL PHI folder> \
  --philter=disable \
  --no-nlp \
  --anon-docrefs docrefs.csv
```

Remember to pass any other required parameters like `--ls-project` and `--ls-token`
(from the linked docs above).
If your DocumentReferences hold links to EHR resources (rather than inlined data),
you will also need to pass the usual ETL `--fhir-url` flag and its related authentication flags.

Once this is done, go to your project page in Label Studio and you should see a lot of charts.

## 6. Have subject-matter experts review the uploaded charts

Give them access to Label Studio and have them annotate the charts.

## 7. Export the annotated charts from Label Studio

On the Label Studio project page, click "Export" and keep the default JSON format.

Save this file as `labelstudio-export.json` in a new folder.

**NOTE: this file is PHI as it contains the note text.** Use appropriate caution.

## 8. Set up `chart-review`

- Run `pip install chart-review`
- Copy the `.csv` files from step 3 above into the same folder
  you used for `labelstudio-export.json` above (the "chart review folder").
- Add a new `config.yaml` file in that folder:
```yaml
labels:
  - Congestion or runny nose
  - Cough
  - Diarrhea
  - Dyspnea
  - Fatigue
  - Fever or chills
  - Headache
  - Loss of taste or smell
  - Muscle or body aches
  - Nausea or vomiting
  - Sore throat

annotators:
  human1: 1
  human2: 2
  ctakes:
    filename: ctakes.csv
  gpt35:
    filename: gpt35.csv
  gpt4:
    filename: gpt4.csv
  icd10:
    filename: icd10.csv
```

Replace `human1` and `human2` with the names of your annotators
and replace the numbers there with their respective user IDs in Label Studio.

## 9. Run `chart-review`

Now from within your chart review folder,
run `chart-review accuracy human1 ctakes` (again, replacing `human1` with the annotator's name).
This will score cTAKES' performance against the ground truth of the human annotator.

You should see a chart of F1 scores, true-positive counts, etc.
Which will tell you how accurate cTAKES NLP (plus negation) is,
as well as how accurate ICD10 codes are.

Read the [chart-review documentation](https://docs.smarthealthit.org/cumulus/chart-review/)
for more information on its features.
