DROP TABLE IF EXISTS `beaming-courage-280500.eicu.eicu_abgs`;
CREATE TABLE `beaming-courage-280500.eicu.eicu_abgs` AS

SELECT *
FROM (
    SELECT *
    FROM (
      -- subquery
      SELECT 
        lab.patientunitstayid, 
        labresultoffset as chartoffset, 
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
ORDER BY patientunitstayid ASC