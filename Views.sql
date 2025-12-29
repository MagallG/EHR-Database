-- 1. Patient Demographics Overview
	-- Quick demographic listing with computed age.
CREATE VIEW vw_Patient_Demographics AS
SELECT 
    Patient_ID,
    CONCAT(Sur_name, ' ', Other_name) AS Full_Name,
    Gender,
    DATEDIFF(YEAR, DOB, GETDATE()) AS Age,
    Nationality,
    Contact,
    Date_Registered
FROM Patient_Records;

-- 2. Patient Treatment Progress Summary----------
	-- Monitor viral load progress and treatment suppression.
CREATE VIEW vw_Patient_Treatment_Summary AS
SELECT 
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    m.First_VL_Results,
    m.Last_VL_Results,
    m.First_ART_Regimen,
    m.Current_ART_Regimen,
    m.TPT_Status,
    DATEDIFF(DAY, m.First_VL_date, m.Last_VL_visit) AS Days_Between_VL,
    CASE 
        WHEN m.Last_VL_Results <= 1000 THEN 'Suppressed'
        ELSE 'Not Suppressed'
    END AS VL_Status
FROM Med_history m
JOIN Patient_Records p ON m.Patient_ID = p.Patient_ID;

-- 3. Visit and Adherence Monitoring
	-- See adherence patterns, refill status, and counseling needs.
CREATE VIEW vw_Visit_Adherence AS
SELECT 
    v.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    v.Date_of_Visit,
    v.ART_Adherence,
    v.Refilled,
    v.Appointment,
    v.MMD_given,
    v.Councelling_note
FROM Visit_Info v
JOIN Patient_Records p ON v.Patient_ID = p.Patient_ID;

-- 4. Lab Test Tracking
	-- Track all lab tests, results, and pending samples.
CREATE VIEW vw_Lab_Tests AS
SELECT 
    l.Lab_No,
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    l.Test_Ordered,
    l.Sample_taken,
    l.Result,
    l.Reason_not_bled
FROM Labs l
JOIN Patient_Records p ON l.Patient_ID = p.Patient_ID;

-- 5. Viral load monthly
CREATE VIEW vw_Monthly_VL_Suppression AS
SELECT 
    FORMAT(m.Last_VL_visit, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Tested,
    SUM(CASE WHEN m.Last_VL_Results <= 1000 THEN 1 ELSE 0 END) AS Suppressed,
    CAST(SUM(CASE WHEN m.Last_VL_Results <= 1000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Percent_Suppressed
FROM Med_history m
WHERE m.Last_VL_visit IS NOT NULL
GROUP BY FORMAT(m.Last_VL_visit, 'yyyy-MM');

-- 6. Monthly TPT Completion 
CREATE VIEW vw_Monthly_TPT_Completion AS
SELECT 
    FORMAT(m.TPT_Completeion_date, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Completed
FROM Med_history m
WHERE m.TPT_Status = 'Complete'
GROUP BY FORMAT(m.TPT_Completeion_date, 'yyyy-MM');

-- 7. Monthly Clinic Visits 
CREATE VIEW vw_Monthly_Visits AS
SELECT 
    FORMAT(Date_of_Visit, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Visits,
    SUM(CASE WHEN Appointment = 'NO' THEN 1 ELSE 0 END) AS Missed_Appointments
FROM Visit_Info
GROUP BY FORMAT(Date_of_Visit, 'yyyy-MM')
;

-- 8. Counselling Follow-up
	-- Track reasons for counseling and outcomes.
CREATE VIEW vw_Counselling_Summary AS
SELECT 
    c.Councel_no,
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    c.Reason_fr_cnsl,
    c.Councelling_done,
    c.Outcome_if_Yes,
    c.Reason_if_No,
    c.Next_Appointment
FROM Counselling c
JOIN Patient_Records p ON c.Patient_ID = p.Patient_ID;

-- 9. Integrated Patient Summary
	-- For SQL daashboard
CREATE VIEW vw_Full_Patient_Profile AS
SELECT 
    p.Patient_ID,
    CONCAT(p.Sur_name, ' ', p.Other_name) AS Full_Name,
    p.Gender,
    DATEDIFF(YEAR, p.DOB, GETDATE()) AS Age,
    m.Current_ART_Regimen,
    m.Last_VL_Results,
    v.ART_Adherence,
    v.Refilled,
    c.Reason_fr_cnsl,
    c.Councelling_done,
    l.Test_Ordered,
    l.Result
FROM Patient_Records p
LEFT JOIN Med_history m ON p.Patient_ID = m.Patient_ID
LEFT JOIN Visit_Info v ON p.Patient_ID = v.Patient_ID
LEFT JOIN Counselling c ON p.Patient_ID = c.Patient_ID
LEFT JOIN Labs l ON p.Patient_ID = l.Patient_ID;


------------------------------ Analytical Queries ---------------
-- 1.Patient gender distribution
SELECT Gender, COUNT(*) AS Total
FROM Patient_Records
GROUP BY Gender;

-- 2. Age group breakdown
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 0 AND 17 THEN 'Child'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 18 AND 35 THEN 'Youth'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 36 AND 59 THEN 'Adult'
        ELSE 'Elderly'
    END AS Age_Group,
    COUNT(*) AS Total
FROM Patient_Records
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 0 AND 17 THEN 'Child'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 18 AND 35 THEN 'Youth'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 36 AND 59 THEN 'Adult'
        ELSE 'Elderly'
    END;
-- 3. ART regimen performance
SELECT 
    Current_ART_Regimen,
    AVG(Last_VL_Results) AS Avg_VL_Result,
    SUM(CASE WHEN Last_VL_Results <= 1000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Percent_Suppressed
FROM Med_history
GROUP BY Current_ART_Regimen;

-- 4. Visit frequency by staff 
SELECT 
    s.Staff_ID,
    CONCAT(s.Surname, ' ', s.other_name) AS Staff_Name,
    s.Department,
    COUNT(v.Patient_ID) AS Patients_Attended
FROM Visit_Info v
JOIN Staff s ON v.Staff_ID = s.Staff_ID
GROUP BY s.Staff_ID, s.Surname, s.other_name, s.Department
ORDER BY Patients_Attended DESC;

-- 5. Lab test distribution
SELECT 
    Test_Ordered,
    COUNT(*) AS Total_Tests,
    AVG(Result) AS Average_Result
FROM Labs
GROUP BY Test_Ordered;

-- 6. Missed appointments tracking
SELECT 
    Patient_ID,
    COUNT(*) AS Missed_Appointments
FROM Visit_Info
WHERE Appointment = 'NO'
GROUP BY Patient_ID;

-- 7. New patients monthly
CREATE VIEW vw_Monthly_New_Patients AS
SELECT 
    FORMAT(Date_Registered, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_New_Patients
FROM Patient_Records
GROUP BY FORMAT(Date_Registered, 'yyyy-MM');
--- NOTE: Views and data analysis to be added upon testing
--- to ease data extraction.

INSERT INTO Staff (Staff_ID, Surname, other_name, Username, loginPassword, Department)
VALUES ('REC001', 'Default', 'Admin', 'admin', 'admin123', 'Records');

