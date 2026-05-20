CREATE VIEW vw_PatientDemographics AS
SELECT
    patient_key,
    age_group,
    gender,
    race,
    ethnicity
FROM DimDemographic;


CREATE VIEW vw_AdmissionDetails AS
SELECT
    admission_key,
    type_of_admission,
    patient_disposition,
    length_of_stay
FROM DimAdmission;


CREATE VIEW vw_FacilityDetails AS
SELECT
    facility_key,
	facility_id,
    county,
    service_area
FROM DimFacility;


CREATE VIEW vw_MDCDetails AS
SELECT
    mdc_key,
    mdc_code
FROM DimMDC;


CREATE VIEW vw_ComobidityDetails AS
SELECT
    cormorbidity_key,
    severity_code,
    mortality_risk
FROM DimComorbidity;


CREATE VIEW vw_PaymentTypology AS
SELECT
    payment_key,
    payment_typology
FROM DimPaymentTypology;


CREATE VIEW vw_ReadmissionFlag AS
SELECT
    derived_key,
    readmitted
FROM DimDerivedFeatures;


CREATE VIEW vw_ReadmissionAnalytics AS
SELECT 

    -- Demographics
    d.age_group,
    d.gender,
    d.race,
    d.ethnicity,

    -- Admission details
    a.type_of_admission,
    a.patient_disposition,
    a.length_of_stay,

    -- Facility details
    fac.facility_id,
    fac.county,
    fac.service_area,

    -- MDC
    m.mdc_code,

    -- Comorbidities
    c.severity_code,
    c.mortality_risk,

    -- Payment
    p.payment_typology,

    -- Readmission target variable
    r.readmitted

FROM FactInpatientVisit f

LEFT JOIN vw_PatientDemographics d
    ON f.patient_key = d.patient_key

LEFT JOIN vw_AdmissionDetails a
    ON f.admission_key = a.admission_key

LEFT JOIN vw_FacilityDetails fac
    ON f.facility_key = fac.facility_key

LEFT JOIN vw_MDCDetails m
    ON f.mdc_key = m.mdc_key

LEFT JOIN vw_ComobidityDetails c
    ON f.cormorbidity_key = c.cormorbidity_key

LEFT JOIN vw_PaymentTypology p
    ON f.payment_key = p.payment_key

LEFT JOIN vw_ReadmissionFlag r
    ON f.derived_key = r.derived_key;



SELECT * FROM vw_ReadmissionAnalytics;
