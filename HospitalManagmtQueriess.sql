-- Below are sample queries

-- Who are the patients?
SELECT first_name
	,last_name
	,date_of_birth
FROM patients;

-- Number of total patients
SELECT COUNT(*)
FROM patients

-- Insurance Providers
SELECT DISTINCT(insurance_provider)
FROM patients;

-- Patients with emergency visits
SELECT *
FROM appointments
WHERE reason_for_visit = 'Emergency' AND appointment_date >= '2023-08-01'
ORDER BY appointment_date DESC;

-- Patients with emergency visits and were a no-show
SELECT *
FROM appointments
WHERE reason_for_visit = 'Emergency' AND status = 'No-show'
ORDER BY appointment_date DESC;

-- No-Show Rates
SELECT (COUNT(CASE WHEN status = 'No-Show' OR status = 'Cancelled' THEN 1 END) * 100.0/COUNT(*)) AS no_show_percent
FROM appointments;

-- Appointments by month (YYYY-MM-DD)
SELECT DATE_TRUNC('month', appointment_date) AS month_appmt
	, COUNT(appointment_id) AS total_appmts
FROM  appointments
GROUP BY 1
ORDER BY 1;

-- Number of treatment types offered
SELECT treatment_type, COUNT(*) AS treatment_count
FROM treatments
GROUP BY treatment_type
ORDER BY COUNT(*) DESC;

-- Doctors' Workload
SELECT doctor_id
	, COUNT(appointment_id) AS total_visits
FROM appointments
WHERE status = 'Completed'
GROUP BY 1
ORDER BY COUNT(appointment_id) DESC;

-- Operational Capacity - peak hours
SELECT 
    EXTRACT(HOUR FROM appointment_time) AS hour_of_day,
    COUNT(appointment_id) AS visit_volume
FROM appointments
WHERE status = 'Completed'
GROUP BY 1
ORDER BY visit_volume DESC

-- Peak day of the week
SELECT TO_CHAR(appointment_date, 'Day') AS day_of_week
	, COUNT(*) AS avg_volume
FROM appointments
GROUP BY 1, EXTRACT(DOW FROM appointment_date)
ORDER BY EXTRACT(DOW FROM appointment_date);

-- Total revenue by treatment type
SELECT t.treatment_type
	, SUM(b.amount) AS total_revenue
FROM treatments t
JOIN billing b ON t.treatment_id = b.treatment_id
WHERE b.payment_status = 'Paid'
GROUP BY t.treatment_type
ORDER BY SUM(b.amount) DESC;

-- Patients with outstanding bills 
SELECT p.patient_id
	, p.first_name
	, p.last_name
	, SUM(b.amount) as total_outstanding
FROM patients p 
JOIN billing b ON p.patient_id = b.patient_id
WHERE b.payment_status IN ('Pending', 'Failed')
GROUP BY p.patient_id;

-- Billing department efficiency (collection rate) 
-- can also seperate into a monthly basis
SELECT (SUM(
	CASE WHEN payment_status = 'Paid' THEN amount ELSE 0 END)
	* 100.0/SUM(amount)) AS collection_rate_pt
FROM billing;

-- Monthly Revenue Growth
WITH monthly_revenue AS (
	SELECT DATE_TRUNC('month', bill_date) AS month
	, SUM(amount) AS revenue
	FROM billing
	WHERE payment_status = 'Paid'
	GROUP BY 1
)

SELECT month
	, revenue
	, LAG(revenue) OVER (ORDER BY month) AS previous_monthly_revenue
	, (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue)
	OVER (ORDER BY month) * 100 AS growth_rate
FROM monthly_revenue;

-- Payment methods with high failure rates
SELECT payment_method,
	COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END)
	* 100.0/COUNT(*) AS failure_payment_rate
FROM billing
GROUP BY payment_method
ORDER BY 2 DESC;

-- Unbilled treatments
SELECT t.treatment_id
	, t.treatment_type
	, t.treatment_date
FROM treatments t 
LEFT JOIN  billing b ON t.treatment_id = b.treatment_id
WHERE b.payment_status IN ('Pending', 'Failed')
ORDER BY 2,3;

-- Revenue yet to be collected
SELECT payment_method
	, SUM(amount) AS total_outstanding
FROM billing
WHERE payment_status IN ('Pending', 'Failed')
GROUP BY payment_method;

-- Patient treatment and billing history
SELECT a.patient_id
	, a.appointment_date
	, t.treatment_type
	, t.cost
	, b.amount AS amount_billed
	, b.payment_status
FROM appointments a
LEFT JOIN  treatments t ON a.appointment_id = t.appointment_id
LEFT JOIN billing b ON t.treatment_id = b.treatment_id
ORDER BY a.patient_id, a.appointment_date;

-- Average treatment cost per patient
SELECT DISTINCT(a.patient_id)
	, AVG(t.cost) OVER(PARTITION BY a.patient_id) AS avg_cost_per_patient
FROM appointments a 
JOIN treatments t ON a.appointment_id = t.appointment_id
ORDER BY a.patient_id;

-- Treatment Cost vs Average
SELECT t.treatment_id
    , t.treatment_type 
    , t.cost
	, (SELECT AVG(cost) FROM treatments) AS avg_cost
    , t.cost - (SELECT AVG(cost) FROM treatments) AS variance
FROM treatments t
WHERE t.cost > (SELECT AVG(cost) FROM treatments);

-- Patient Retention
SELECT patient_id
	, COUNT(appointment_id) AS visits_count
FROM appointments 
GROUP BY patient_id
HAVING COUNT(appointment_id) > 1
ORDER BY COUNT(appointment_id) DESC;

-- Reasons for visiting the hospital
-- can also do monthly
SELECT reason_for_visit
	, COUNT(*) AS visit_count
FROM appointments
GROUP BY reason_for_visit
ORDER BY COUNT(*) DESC;

-- Who are these frequent visiters and their needs
-- a continuation of the above query
SELECT patient_id
	, reason_for_visit
	, COUNT(*) AS visit_count
FROM appointments 
GROUP BY patient_id, reason_for_visit
HAVING COUNT(*) > 1;

-- Bed Occupancy
SELECT appointment_date
	, COUNT(*) AS total_visits
	, COUNT(*) FILTER (WHERE status = 'Completed') AS completed_visits
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date DESC;

