DROP TABLE IF EXISTS `spring-carving-271217.mimiciv.mimiciv_abgs`;
CREATE TABLE `spring-carving-271217.mimiciv.mimiciv_abgs` AS

SELECT *
FROM
(
  -- subquery
  SELECT 
    le.SUBJECT_ID, 
    le.HADM_ID, 
    le.CHARTTIME, 
    dle2.LABEL, 
    le.VALUE
  FROM 
    `physionet-data.mimiciii_clinical.labevents` le
  LEFT JOIN 
  (
    SELECT 
      ITEMID, 
      LABEL 
    FROM 
      `physionet-data.mimiciii_clinical.d_labitems` 
    LIMIT 1000
  ) dle2 
  ON dle2.ITEMID = le.ITEMID
  WHERE le.ITEMID IN 
  (
    SELECT ITEMID 
    FROM 
      `physionet-data.mimiciii_clinical.d_labitems` 
    WHERE category IN ("Blood Gas", "BLOOD GAS") 
    LIMIT 1000
  )
  ORDER BY 
    SUBJECT_ID ASC, 
    CHARTTIME ASC
)

PIVOT (
  ANY_VALUE(VALUE) 
  FOR LABEL IN (
    "pH",
    "pCO2" as paCO2,
    "pO2" as paO2,
    "Oxygen Saturation" AS SaO2,
    "Carboxyhemoglobin", 
    "Methemoglobin",
    "SPECIMEN TYPE" AS SpecimenType
  )
) pivoted

WHERE
  HADM_ID IS NOT NULL AND
  SUBJECT_ID IS NOT NULL AND
  pH IS NOT NULL AND
  paCO2 IS NOT NULL AND
  paO2 IS NOT NULL AND
  SaO2 IS NOT NULL AND
  SpecimenType IS NOT NULL AND
  SpecimenType IN ("ART");
