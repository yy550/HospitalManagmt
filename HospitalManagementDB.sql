-- 1. Create the Database

CREATE DATABASE HospitalManagement;

-- 2. Create Patients Table
CREATE TABLE patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    address VARCHAR(255),
    registration_date DATE,
    insurance_provider VARCHAR(100),
    insurance_number VARCHAR(50),
    email VARCHAR(100)
);

-- 3. Create Doctors Table
CREATE TABLE doctors (
    doctor_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    phone_number VARCHAR(20),
    years_experience INT,
    hospital_branch VARCHAR(100),
    email VARCHAR(100)
);

-- 4. Create Appointments Table
CREATE TABLE appointments (
    appointment_id VARCHAR(50) PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    doctor_id VARCHAR(50) NOT NULL,
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit VARCHAR(255),
    status VARCHAR(20),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 5. Create Treatments Table
CREATE TABLE treatments (
    treatment_id VARCHAR(50) PRIMARY KEY,
    appointment_id VARCHAR(50) NOT NULL,
    treatment_type VARCHAR(100),
    description TEXT,
    cost DECIMAL(10, 2),
    treatment_date DATE,
    CONSTRAINT fk_treatment_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- 6. Create Billing Table
CREATE TABLE billing (
    bill_id VARCHAR(50) PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    treatment_id VARCHAR(50) NOT NULL,
    bill_date DATE,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_billing_treatment FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id)
);