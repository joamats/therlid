-- Generate our own lab table based on LCP code

DROP TABLE IF EXISTS `spring-carving-271217.test.pivoted_lab_extended`;
CREATE TABLE `spring-carving-271217.test.pivoted_lab_extended` AS

-- not existing in eICU2
-- d_dimer
-- thrombin
-- indirect bilirubin
-- ggt

-- forked from https://github.com/joamats/pulse-ox-dataset/blob/master/queries/eICU-1/pivoted_lab_extended.SQL
-- remove duplicate labs if they exist at the same time
WITH vw0 AS (
  SELECT
      patientunitstayid,
      labname,
      labresultoffset,
      labresultrevisedoffset
  FROM `aiwonglab.eicu_crd_ii_v0_1_0.lab` AS lab
  WHERE labname IN (
      'albumin',
      'total bilirubin',
      'direct bilirubin',
      'BUN',
      'calcium',
      'chloride',
      'creatinine',
      'bedside glucose', 'glucose',
      'bicarbonate', -- HCO3
      'Total CO2',
      'Hct',
      'Hgb',
      'PT - INR',
      'PTT',
      'lactate',
      'platelets x 1000',
      'potassium',
      'sodium',
      'WBC x 1000',
      '-bands',
      -- Liver enzymes
      'ALT (SGPT)',
      'AST (SGOT)',
      'alkaline phos.',
      'fibrinogen',
      'PT',
      'MCH',
      'MCHC',
      'MCV',
      'MPV',
      'RDW',
      'RBC',
      'CPK',
      'CPK-MB',
      'LDH',
      'anion gap'
  )
  GROUP BY patientunitstayid, labname, labresultoffset, labresultrevisedoffset
  HAVING COUNT(DISTINCT labresult) <= 1
),

-- create a derived table with the SAFE_CAST results due to schema being different from eicu1
vw1 AS (
  SELECT
      lab.patientunitstayid,
      lab.labname,
      lab.labresultoffset,
      lab.labresultrevisedoffset,
      SAFE_CAST(lab.labresult AS FLOAT64) AS labresult
  FROM `aiwonglab.eicu_crd_ii_v0_1_0.lab` AS lab
  INNER JOIN vw0
    ON lab.patientunitstayid = vw0.patientunitstayid
    AND lab.labname = vw0.labname
    AND lab.labresultoffset = vw0.labresultoffset
    AND lab.labresultrevisedoffset = vw0.labresultrevisedoffset
),

vw2 AS (
  SELECT
      patientunitstayid,
      labname,
      labresultoffset,
      labresultrevisedoffset,
      labresult,
      ROW_NUMBER() OVER (
          PARTITION BY patientunitstayid, labname, labresultoffset
          ORDER BY labresultrevisedoffset DESC
      ) AS rn
  FROM vw1
  WHERE (labname = 'albumin' AND labresult >= 0.5 AND labresult <= 6.5)
    OR (labname = 'total bilirubin' AND labresult >= 0.2 AND labresult <= 100)
    OR (labname = 'direct bilirubin' AND labresult >= 0.01 AND labresult <= 80)
    OR (labname = 'BUN' AND labresult >= 1 AND labresult <= 280)
    OR (labname = 'calcium' AND labresult > 0 AND labresult <= 9999)
    OR (labname = 'chloride' AND labresult > 0 AND labresult <= 9999)
    OR (labname = 'creatinine' AND labresult >= 0.1 AND labresult <= 28.28)
    OR (labname IN ('bedside glucose', 'glucose') AND labresult >= 25 AND labresult <= 1500)
    OR (labname = 'bicarbonate' AND labresult >= 0 AND labresult <= 9999)
    OR (labname = 'Total CO2' AND labresult >= 0 AND labresult <= 9999)
    OR (labname = 'Hct' AND labresult >= 5 AND labresult <= 75)
    OR (labname = 'Hgb' AND labresult > 0 AND labresult <= 9999)
    OR (labname = 'PT - INR' AND labresult >= 0.5 AND labresult <= 15)
    OR (labname = 'lactate' AND labresult >= 0.1 AND labresult <= 30)
    OR (labname = 'platelets x 1000' AND labresult > 0 AND labresult <= 9999)
    OR (labname = 'potassium' AND labresult >= 0.05 AND labresult <= 12)
    OR (labname = 'PTT' AND labresult > 0 AND labresult <= 500)
    OR (labname = 'sodium' AND labresult >= 90 AND labresult <= 215)
    OR (labname = 'WBC x 1000' AND labresult > 0 AND labresult <= 100)
    OR (labname = '-bands' AND labresult >= 0 AND labresult <= 100)
    OR (labname = 'ALT (SGPT)' AND labresult > 0)
    OR (labname = 'AST (SGOT)' AND labresult > 0)
    OR (labname = 'alkaline phos.' AND labresult > 0)
    OR (labname = 'fibrinogen' AND labresult IS NOT NULL)
    OR (labname = 'PT' AND labresult > 0)
    OR (labname = 'MCH' AND labresult IS NOT NULL)
    OR (labname = 'MCHC' AND labresult IS NOT NULL)
    OR (labname = 'MCV' AND labresult IS NOT NULL)
    OR (labname = 'MPV' AND labresult IS NOT NULL)
    OR (labname = 'RDW' AND labresult IS NOT NULL)
    OR (labname = 'RBC' AND labresult IS NOT NULL)
    OR (labname = 'CPK' AND labresult > 0)
    OR (labname = 'CPK-MB' AND labresult > 0)
    OR (labname = 'LDH' AND labresult IS NOT NULL)
    OR (labname = 'anion gap' AND labresult IS NOT NULL)
)

SELECT
    patientunitstayid,
    labresultoffset AS chartoffset,
    MAX(CASE WHEN labname = 'albumin' THEN labresult ELSE NULL END) AS albumin,
    MAX(CASE WHEN labname = 'total bilirubin' THEN labresult ELSE NULL END) AS bilirubin_total,
    MAX(CASE WHEN labname = 'direct bilirubin' THEN labresult ELSE NULL END) AS bilirubin_direct,
    MAX(CASE WHEN labname = 'BUN' THEN labresult ELSE NULL END) AS bun,
    MAX(CASE WHEN labname = 'calcium' THEN labresult ELSE NULL END) AS calcium,
    MAX(CASE WHEN labname = 'chloride' THEN labresult ELSE NULL END) AS chloride,
    MAX(CASE WHEN labname = 'creatinine' THEN labresult ELSE NULL END) AS creatinine,
    MAX(CASE WHEN labname IN ('bedside glucose', 'glucose') THEN labresult ELSE NULL END) AS glucose,
    MAX(CASE WHEN labname = 'bicarbonate' THEN labresult ELSE NULL END) AS bicarbonate,
    MAX(CASE WHEN labname = 'Total CO2' THEN labresult ELSE NULL END) AS TotalCO2,
    MAX(CASE WHEN labname = 'Hct' THEN labresult ELSE NULL END) AS hematocrit,
    MAX(CASE WHEN labname = 'Hgb' THEN labresult ELSE NULL END) AS hemoglobin,
    MAX(CASE WHEN labname = 'PT - INR' THEN labresult ELSE NULL END) AS INR,
    MAX(CASE WHEN labname = 'lactate' THEN labresult ELSE NULL END) AS lactate,
    MAX(CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE NULL END) AS platelets,
    MAX(CASE WHEN labname = 'potassium' THEN labresult ELSE NULL END) AS potassium,
    MAX(CASE WHEN labname = 'PTT' THEN labresult ELSE NULL END) AS ptt,
    MAX(CASE WHEN labname = 'PT' THEN labresult ELSE NULL END) AS pt,
    MAX(CASE WHEN labname = 'sodium' THEN labresult ELSE NULL END) AS sodium,
    MAX(CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE NULL END) AS wbc,
    MAX(CASE WHEN labname = '-bands' THEN labresult ELSE NULL END) AS bands,
    MAX(CASE WHEN labname = 'ALT (SGPT)' THEN labresult ELSE NULL END) AS alt,
    MAX(CASE WHEN labname = 'AST (SGOT)' THEN labresult ELSE NULL END) AS ast,
    MAX(CASE WHEN labname = 'alkaline phos.' THEN labresult ELSE NULL END) AS alp,
    MAX(CASE WHEN labname = 'fibrinogen' THEN labresult ELSE NULL END) AS fibrinogen,
    MAX(CASE WHEN labname = 'MCH' THEN labresult ELSE NULL END) AS mch,
    MAX(CASE WHEN labname = 'MCHC' THEN labresult ELSE NULL END) AS mchc,
    MAX(CASE WHEN labname = 'MCV' THEN labresult ELSE NULL END) AS mcv,
    MAX(CASE WHEN labname = 'MPV' THEN labresult ELSE NULL END) AS mpv,
    MAX(CASE WHEN labname = 'RDW' THEN labresult ELSE NULL END) AS rdw,
    MAX(CASE WHEN labname = 'RBC' THEN labresult ELSE NULL END) AS rbc,
    MAX(CASE WHEN labname = 'CPK' THEN labresult ELSE NULL END) AS ck_cpk,
    MAX(CASE WHEN labname = 'CPK-MB' THEN labresult ELSE NULL END) AS ck_mb,
    MAX(CASE WHEN labname = 'LDH' THEN labresult ELSE NULL END) AS ld_ldh,
    MAX(CASE WHEN labname = 'anion gap' THEN labresult ELSE NULL END) AS aniongap 
FROM vw2
WHERE rn = 1
GROUP BY patientunitstayid, labresultoffset
ORDER BY patientunitstayid, labresultoffset;
