# TherLid: A Thermometry Linked Dataset
An open-source thermometry dataset, derived from MIMIC-IV, eICU-CRD-1, and eICU-CRD-2.

This repository contains six main notebooks:

- **`1_dataset.ipynb`**: Pipeline for creating the dataset.
- **`2_consort_diagram.ipynb`**: Code to generate the consort diagrams.
- **`3_tableones.ipynb`**: Code for producing the descriptive tables presented in the manuscript.
- **`4_technical_validation.ipynb`**: Code for the technical validation and the figures included in the manuscript.
- **`5_missingness.ipynb`**: Code for generating the missingness report by racial and ethnic groups.
- **`6_example.ipynb`**: Code to run through an example usecase of the dataset.

Additionally, these Google Spreadsheets contain the variables and mappings used in the dataset harmonization:

* [Variables](https://docs.google.com/spreadsheets/d/1SOWmaaq_FR5kkMXYnM1-6V7SR8vd0PPPuhvSmSpB_jA/)
* [Defintions](https://docs.google.com/spreadsheets/d/1nKYWio1WaPbDPGAmQazPKp-V0Nxv2xFXHhy6yRrG7Qc/)

All other derived tables can be found in:
* [MIMIC-Code Repository](https://github.com/MIT-LCP/mimic-code)
* [eICU-Code Repository](https://github.com/MIT-LCP/eicu-code/)
* eICU2

This workflow is inspired by:
https://github.com/joamats/pulse-ox-dataset