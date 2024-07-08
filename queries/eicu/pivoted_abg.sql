DROP TABLE IF EXISTS `spring-carving-271217.eicu.eicu_abgs`;
CREATE TABLE `spring-carving-271217.eicu.eicu_abgs` AS

SELECT *
FROM (
    SELECT *
    FROM (
      -- subquery
      SELECT 
        lab.patientunitstayid, 
        labresultoffset, 
        labresult, 
        labname, 
        labresultrevisedoffset
      FROM 
        `physionet-data.eicu_crd.lab` lab
      LEFT JOIN 
        `physionet-data.eicu_crd.patient` pat
      ON 
        pat.patientunitstayid = lab.patientunitstayid
      WHERE 
        lab.labtypeid = 7
      ORDER BY
        lab.patientunitstayid ASC,
        lab.labresultoffset ASC,
        lab.labresultrevisedoffset ASC
      -- LIMIT 10000 -- comment if you want to just do a test run
    )
    PIVOT (
      avg(labresult) FOR labname IN (
        "pH",
        "paCO2",
        "paO2",
        "O2 Sat (%)" AS SaO2,
        "Carboxyhemoglobin",
        "Methemoglobin"
      )
    )
) pivoted
WHERE
  pH IS NOT NULL AND
  paCO2 IS NOT NULL AND
  paO2 IS NOT NULL AND
  SaO2 IS NOT NULL;
