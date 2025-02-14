CREATE DATABASE EXERCISES
GO
USE EXERCISES
GO

-- Problem 1.	One-To-One Relationship
-- parent table
CREATE TABLE Passports
(
PassportID int NOT NULL UNIQUE, --PK
PassportNumber nvarchar(30) NOT NULL UNIQUE
)
-- child table
CREATE TABLE Persons
(
PersonID int NOT NULL UNIQUE, --PK
FirstName nvarchar(50) NOT NULL,
Salary DEC(8,2) NOT NULL,

PassportID int UNIQUE	 --FK one-to-one
)

--SELECT * FROM Persons
--SELECT * FROM Passports
ALTER TABLE Passports
ADD CONSTRAINT PK_Passports PRIMARY KEY (PassportID) 

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons PRIMARY KEY (PersonID) 

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports 
FOREIGN KEY (PassportID) REFERENCES Passports(PassportID) ON DELETE CASCADE	

INSERT INTO Passports (PassportID,PassportNumber)
VALUES
(101,'N34FG21B'),
(102,'K65LO4R7'),
(103,'ZE657QP2')

INSERT INTO Persons (PersonID,FirstName,Salary,PassportID)
VALUES
(1,'Roberto',43300,102),
(2,'Tom',56100,103),
(3,'Yana',60200,101)

-- DROP TABLE Persons
-- DROP TABLE Passports

/*
SELECT FirstName, Salary,PassportNumber
FROM Persons AS ps
	JOIN Passports AS pt ON ps.PassportID = pt.PassportID
*/

-- _________________________________________________________

--Problem 2.	One-To-Many Relationship
 
--DROP TABLE Models
--DROP TABLE Manufacturers
GO
CREATE TABLE Manufacturers
(
ManufacturerID	int PRIMARY KEY,
[Name] NVARCHAR(30) NOT NULL,
EstablishedOn DATE DEFAULT '1900-01-01'
)

CREATE TABLE Models
(
ModelID int PRIMARY KEY,
[Name] nvarchar(30) UNIQUE,
-- Foreign Key 
ManufacturerID INT REFERENCES Manufacturers(ManufacturerID)
)
--ALTER TABLE Manufacturers
--ADD CONSTRAINT PK_Manufacturers PRIMARY KEY (ManufacturerID)

--ALTER TABLE Models
--ADD CONSTRAINT PK_Models PRIMARY KEY (ModelID)

--ALTER TABLE Models
--ADD CONSTRAINT FK_Models_Manufacturers 
--FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID) 


INSERT INTO Manufacturers(ManufacturerID,[Name],EstablishedOn)
VALUES
(1,'BMW','1916-03-07'),
(2,'Tesla','2003-01-01'),
(3,'Lada','1966-05-01')
 

INSERT INTO Models (ModelID,[Name],ManufacturerID)
VALUES
(101,'X1',1),
(102,'i6',1),
(103,'Model S',2),
(104,'Model X',2),
(105,'Model 3',2),
(106,'Nova',3)

--SELECT * FROM Models md
--JOIN Manufacturers mn  ON md.ManufacturerID = mn.ManufacturerID

--  Problem 3.	Many-To-Many Relationship
 
USE EXERCISES
GO

--DROP TABLE StudentsExams  -- child
--DROP TABLE Students		-- parent
--DROP TABLE Exams			-- parent


CREATE TABLE Students
(
StudentID int PRIMARY KEY ,
[Name] nvarchar(60) NOT NULL  
)

CREATE TABLE Exams
(
ExamID int PRIMARY KEY ,
[Name] nvarchar(40) NOT NULL  
)

CREATE TABLE StudentsExams
(
StudentID int REFERENCES Students(StudentID) NOT NULL,
ExamID int REFERENCES Exams(ExamID) NOT NULL,

CONSTRAINT PK_StudentID_ExamID PRIMARY KEY(StudentID, ExamID) -- composite PK
)

--CONSTRAINT FK_StudentsExams_Students 
--	FOREIGN KEY(StudentID) REFERENCES Students(StudentID),
--CONSTRAINT FK_StudentsExams_ExamID 
--	FOREIGN KEY(ExamID) REFERENCES Exams(ExamID)
 

INSERT INTO Students (StudentID,[Name])
VALUES
(1,'Mila'),
(2,'Toni'),
(3,'Ron')

INSERT INTO Exams (ExamID,[Name])
VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g')

INSERT INTO StudentsExams
VALUES
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103)


/*
SELECT b.[Name],c.[Name]
FROM StudentsExams as a
JOIN Students  as b ON a.StudentID = b.StudentID 
JOIN Exams as c ON a.ExamID = c.ExamID
*/

-- Problem 4.	Self-Referencing 
-- DROP TABLE Teachers

CREATE TABLE Teachers
(
TeacherID int PRIMARY KEY,
[Name] nvarchar(50) NOT NULL,

ManagerID int REFERENCES Teachers(TeacherID) -- FK to the PK in the same table
)


INSERT INTO Teachers (TeacherID,[Name],ManagerID)
VALUES
(101,'John',NULL),
(102,'Maya',106),
(103,'Silvia',106),
(104,'Ted',105),
(105,'Mark',101),
(106,'Greta',101)

/*
SELECT t1.[Name] AS Teacher, t2.[Name] AS Manager
FROM Teachers t1
left join Teachers t2 ON t2.TeacherID = t1.ManagerID
*/



-- Problem 5.	Online Store Database

CREATE DATABASE [Online Store];
GO
USE [Online Store]
GO

CREATE TABLE ItemTypes
(
ItemTypeID int PRIMARY KEY,
[Name] varchar(50) NOT NULL
)

CREATE TABLE Items
(
ItemID int PRIMARY KEY,
[Name] varchar(50) NOT NULL,
ItemTypeID int REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE Cities
(
CityID int PRIMARY KEY,
[Name] varchar(50) NOT NULL
)

CREATE TABLE Customers
(
CustomerID int PRIMARY KEY,
[Name] varchar(50) NOT NULL,
Birthday DATE,
CityID int REFERENCES Cities(CityID)
)

CREATE TABLE Orders
(
OrderID int PRIMARY KEY,
CustomerID int REFERENCES Customers(CustomerID)
)

CREATE TABLE OrderItems  -- JOIN TABLE
(
OrderID int,
ItemID int,
CONSTRAINT PK_Order_Item PRIMARY KEY(OrderID, ItemID),
CONSTRAINT FK_OrderID_Orders FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
CONSTRAINT FK_ItemID_Items FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
)

-- Problem 6.	University Database
CREATE DATABASE University
GO
USE University
GO

CREATE TABLE Subjects
(
SubjectID int PRIMARY KEY,
SubjectName nvarchar(50) NOT NULL
)

CREATE TABLE Majors
(
MajorID int PRIMARY KEY,
[Name] nvarchar(50) NOT NULL
)

CREATE TABLE Students
(
StudentID int PRIMARY KEY,
StudentNumber int NOT NULL UNIQUE,
StudentName nvarchar(60) NOT NULL,
MajorID int REFERENCES Majors(MajorID)
)

CREATE TABLE Payments
(
PaymentID int PRIMARY KEY,
PaymentDate DATE NOT NULL,
PaymentAmount DECIMAL NOT NULL,
StudentID INT REFERENCES Students(StudentID)
)

CREATE TABLE Agenda  --JOIN/MAPPING TABLE
(
StudentID int NOT NULL REFERENCES Students(StudentID), -- FK1
SubjectID int NOT NULL REFERENCES Subjects(SubjectID),  -- FK2

CONSTRAINT PK_Student_Subject PRIMARY KEY(StudentID,SubjectID) -- composite PK 
)




-- Problem 9.	*Peaks in Rila
USE Geography
GO

SELECT m.MountainRange, p.PeakName, p.Elevation 
	FROM Peaks AS p
	JOIN  Mountains AS m
		ON m.Id = p.MountainId --AND,OR,NOT -2nd criteria
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC