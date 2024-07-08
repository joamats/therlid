DROP TABLE IF EXISTS `spring-carving-271217.test.eicu2_abgs`;
CREATE TABLE `spring-carving-271217.test.eicu2_abgs` AS

--forked from https://github.com/joamats/pulse-ox-dataset/blob/master/notebooks/1_dataset.ipynb
--safecast labresult as schema is different from eicu1
SELECT *
FROM (
    SELECT *
    FROM (
        SELECT 
            lab.patientunitstayid, 
            labresultoffset, 
            SAFE_CAST(labresult AS FLOAT64) AS labresult,  
            labname, 
            labresultrevisedoffset AS chartoffset
        FROM `aiwonglab.eicu_crd_ii_v0_1_0.lab` lab
        LEFT JOIN `aiwonglab.eicu_crd_ii_v0_1_0.patient` pat
            ON pat.patientunitstayid = lab.patientunitstayid
        WHERE lab.labtypeid = 7
        ORDER BY
            lab.patientunitstayid ASC,
            lab.labresultoffset ASC,
            lab.labresultrevisedoffset ASC
    )
    PIVOT (
        AVG(labresult) 
        FOR labname IN (
            "pH",
            "paCO2",
            "paO2",
            "O2 Sat (%)" as SaO2,
            "Carboxyhemoglobin",
            "Methemoglobin"
        )
    )
) AS pivoted
ORDER BY patientunitstayid ASC