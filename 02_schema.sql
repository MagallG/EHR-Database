-- Patients information table
CREATE table Patient_Records(
  Patient_ID varchar(10) NOT NULL PRIMARY KEY,
  Sur_name varchar(50) NOT NULL,
  Other_name varchar(70) NULL,
  Gender varchar(1) NOT NULL CHECK(Gender IN ('M','F')),
  DOB date NOT NULL,
  Nationality varchar(12) CHECK(Nationality IN ('National', 'Non-national')) NOT NULL,
  Address varchar(100) NULL, -- UI will show how this should be entered.
  Contact varchar(10) NULL,
  NIN varchar(14) NULL, -- Only if Nationality is 'National'
  NOK varchar(50) NULL,
  NOK_Contact varchar(9),
  Date_Registered date DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (Patient_ID LIKE '[0-9][0-9][0-9]/[A-Z][A-Z][A-Z]/[0-9][0-9]'), -- ID should be of the form '000/XYZ/00'
  CHECK (NIN LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z][A-Z][A-Z][A-Z]'), -- NIN should be of the form 'CM87521457MEMP'
  CHECK (Contact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CHECK (NOK_Contact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

-- Patient Medical history
-------- To be filled immediately after the patient has been registered.
CREATE table Med_history(
  Patient_ID varchar(10),
  Recency_results varchar(10) CHECK(Recency_results IN ('Recent', 'Not Recent')),
  First_VL_date date,
  First_VL_Results int,
  First_CD4_count int,
  Last_VL_visit date,
  Last_VL_Results int,
  First_ART_Regimen varchar(11),
  Current_ART_Regimen varchar(11),
  Allergies varchar(100),
  TPT_Status varchar(3) CHECK(TPT_Status IN ('Complete', 'On TPT', 'Not Started')),
  TPT_Start_Date date, --- Only appears when TPT_Status is chosen as 'Complete' or 'On TPT'
  TPT_Completeion_date date, --- Only appears when TPT_Status is chosen as 'Complete'
  TPT_regimen varchar(20), --- Only appears when TPT_Status is chosen as 'Complete' or 'On TPT'
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID),
  CHECK (First_ART_Regimen like '[A-Z][A-Z][A-Z]/[0-9][A-Z][A-Z]/[A-Z][A-Z][A-Z]'),
  CHECK (First_ART_Regimen like '[A-Z][A-Z][A-Z]/[0-9][A-Z][A-Z]/[A-Z][A-Z][A-Z]')
);

-- Staff Information table
------------------ to have a default, be able to add and update users, and linked to login. To start the UI, a user has
create table Staff(
	Staff_ID varchar(6) PRIMARY KEY,
	Surname varchar(50) NOT NULL,
	other_name varchar(50) NOT NULL,
	Username varchar(50) NOT NULL,
	loginPassword varchar(50) not null,
	Department varchar(50) CHECK(Department IN ('Records','ART', 'Counselling', 'Lab', 'Maternity', 'OPD', 'Ward')) NOT NULL,
  
  -- Constraints 
  CHECK (Staff_ID LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9]')  -- Staff ids to be of the format 'LAB001', 'OPD111', 'MAT001' and 'WRD001'
);

-- Visit Information table
CREATE table Visit_Info(
  Patient_ID varchar(10),
  Staff_ID varchar(6) PRIMARY KEY, -- Auto entered from login details
  Date_of_Visit date DEFAULT CURRENT_TIMESTAMP,
  Appointment varchar(3) CHECK(Appointment IN ('YES','NO')),
  Last_Scheduled_Appointment date NULL,
  ART_Adherence varchar(9) CHECK(ART_Adherence in ('VERY POOR','POOR', 'GOOD', 'VERY GOOD')),
  ARV_sideEffects varchar(100) NULL,
  TPT_Given varchar(3) CHECK(TPT_Given IN ('YES','NO')), --If TPT Status in Med_history table is either 'On TPT'or 'Not Started'
  TPT_regimen_Given varchar(20),
  Refilled varchar(3) CHECK(Refilled IN ('YES','NO')),
  MMD_given int,
  Due_for_bleeding  varchar(3) CHECK(Due_for_bleeding IN ('YES','NO')),
  Bleeding_needed varchar(20) CHECK(Bleeding_needed IN ('Recency', 'Viral Load', 'CD4')),
  Bleeding_note varchar(20) CHECK(Bleeding_note IN ('Bled', 'Sent to lab', 'Not Bled')),
  Councelling_note varchar(20) CHECK(Councelling_note IN ('Needed', 'Not needed')),
  Clinical_notes varchar(150),
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID),
  FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

-- Laboratory Information table
CREATE table Labs(
  Lab_No INT IDENTITY(1001, 1) primary key,
  Patient_ID varchar(10),
  Test_Ordered varchar(20) CHECK(Test_Ordered IN ('Recency', 'Viral Load', 'CD4')),
  Sample_taken varchar(3) CHECK(Sample_taken IN ('Yes', 'No')),
  Result float,
  Reason_not_bled varchar(100) NULL,
  
  -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID)
);

-- Counselling Information table
CREATE table Counselling(
  Councel_no INT IDENTITY(1001, 1) PRIMARY KEY,
  Patient_ID varchar(10),
  Reason_fr_cnsl varchar(100) NOT NULL,
  Councelling_done varchar(3) CHECK(Councelling_done IN ('Yes', 'No')),
  Outcome_if_Yes varchar(100),
  Reason_if_No varchar(100),
  Next_Appointment date,
  
   -- Constraints
  FOREIGN KEY (Patient_ID) REFERENCES Patient_Records(Patient_ID)
);
