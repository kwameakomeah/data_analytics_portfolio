CREATE TABLE DimFacility (
    facility_key INT IDENTITY(1,1) PRIMARY KEY,
    facility_id VARCHAR(10),
    county NVARCHAR(100),
    service_area NVARCHAR(100),
	zip_code VARCHAR(10),
);

CREATE TABLE DimCLinical (
    diagnosis_key INT IDENTITY(1,1) PRIMARY KEY,
    diagnosis_code NVARCHAR(50),
	procedure_code NVARCHAR(50),
	drug_code VARCHAR(20),
	surgical_description NVARCHAR(100),
);

CREATE TABLE DimAdmission (
    admission_key INT IDENTITY(1,1) PRIMARY KEY,
	length_of_stay INT,
	patient_disposition NVARCHAR(50),
	type_of_admission NVARCHAR(50),
);


CREATE TABLE DimDemographic (
    patient_key INT IDENTITY(1,1) PRIMARY KEY,
    age_group NVARCHAR(100),
	gender NVARCHAR(10),
	race NVARCHAR(100),
	ethnicity NVARCHAR(100),
);


CREATE TABLE DimMDC (
    mdc_key INT IDENTITY(1,1) PRIMARY KEY,
    mdc_code INT,
);

CREATE TABLE DimDerivedFeatures (
    derived_key INT IDENTITY(1,1) PRIMARY KEY,
    clinical_score FLOAT,
	combined_score FLOAT,
	readmitted BIT,
);

CREATE TABLE DimPaymentTypology (
    payment_key INT IDENTITY(1,1) PRIMARY KEY,
    payment_typology NVARCHAR(200),
);

CREATE TABLE DimComorbidity (
    cormorbidity_key INT IDENTITY(1,1) PRIMARY KEY,
    severity_code INT,
	mortality_risk INT,
);


--Fact Table--

CREATE TABLE FactInpatientVisit (
    fact_key INT IDENTITY(1,1) PRIMARY KEY,
    facility_key INT,
    diagnosis_key INT,
    mdc_key INT,
    payment_key INT,
    patient_key INT,
    admission_key INT,
    cormorbidity_key INT,
    derived_key INT,

    FOREIGN KEY (facility_key) REFERENCES DimFacility(facility_key),
    FOREIGN KEY (diagnosis_key) REFERENCES DimClinical(diagnosis_key),
    FOREIGN KEY (mdc_key) REFERENCES DimMDC(mdc_key),
    FOREIGN KEY (payment_key) REFERENCES DimPaymentTypology(payment_key),
    FOREIGN KEY (patient_key) REFERENCES DimDemographic(patient_key),
    FOREIGN KEY (admission_key) REFERENCES DimAdmission(admission_key),
    FOREIGN KEY (cormorbidity_key) REFERENCES DimComorbidity(cormorbidity_key),
    FOREIGN KEY (derived_key) REFERENCES DimDerivedFeatures(derived_key)
);

--LOADING--



INSERT INTO DimFacility (facility_id, county, service_area, zip_code)
SELECT DISTINCT 
    facility_id,
    county,
    service_area,
    zip_code
FROM Staging_Sparcs_Inpatient;


INSERT INTO DimCLinical (diagnosis_code, procedure_code, drug_code, surgical_description)
SELECT DISTINCT 
    diagnosis_code,
    procedure_code,
    drug_code,
    surgical_description
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimAdmission (length_of_stay, patient_disposition, type_of_admission)
SELECT DISTINCT 
    length_of_stay,
    patient_disposition,
    type_of_admission
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimDemographic (age_group, gender, race, ethnicity)
SELECT DISTINCT 
    age_group,
    gender,
    race,
    ethnicity
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimMDC (mdc_code)
SELECT DISTINCT 
    mdc_code
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimDerivedFeatures (clinical_score, combined_score, readmitted)
SELECT DISTINCT 
    clinical_score,
    combined_score,
    readmitted
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimPaymentTypology (payment_typology)
SELECT DISTINCT 
    payment_typology
FROM Staging_Sparcs_Inpatient;

INSERT INTO DimComorbidity (severity_code, mortality_risk)
SELECT DISTINCT 
    severity_code,
    mortality_risk
FROM Staging_Sparcs_Inpatient;




--Load Fact Table--

INSERT INTO FactInpatientVisit (
    facility_key,
    diagnosis_key,
    mdc_key,
    payment_key,
    patient_key,
    admission_key,
    cormorbidity_key,
    derived_key
)
SELECT 
    f.facility_key,
    c.diagnosis_key,
    m.mdc_key,
    p.payment_key,
    d.patient_key,
    a.admission_key,
    co.cormorbidity_key,
    df.derived_key
FROM Staging_Sparcs_Inpatient si
JOIN DimFacility f
    ON si.facility_id = f.facility_id
    AND si.county = f.county
    AND si.service_area = f.service_area
    AND si.zip_code = f.zip_code
JOIN DimCLinical c
    ON si.diagnosis_code = c.diagnosis_code
    AND si.procedure_code = c.procedure_code
    AND si.drug_code = c.drug_code
    AND si.surgical_description = c.surgical_description
JOIN DimAdmission a
    ON si.length_of_stay = a.length_of_stay
    AND si.patient_disposition = a.patient_disposition
    AND si.type_of_admission = a.type_of_admission
JOIN DimDemographic d
    ON si.age_group = d.age_group
    AND si.gender = d.gender
    AND si.race = d.race
    AND si.ethnicity = d.ethnicity
JOIN DimMDC m
    ON si.mdc_code = m.mdc_code
JOIN DimPaymentTypology p
    ON si.payment_typology = p.payment_typology
JOIN DimComorbidity co
    ON si.severity_code = co.severity_code
    AND si.mortality_risk = co.mortality_risk
JOIN DimDerivedFeatures df
    ON si.clinical_score = df.clinical_score
    AND si.combined_score = df.combined_score
    AND si.readmitted = df.readmitted;








