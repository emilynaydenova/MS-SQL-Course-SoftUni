-------- TABLE MINIONS,TOWNS  ------------------
-- Problem 1.
CREATE DATABASE Minions
GO

USE Minions
GO

-- Problem 2.
CREATE TABLE Minions
(
Id int PRIMARY KEY,    --id int IDENTITY(1,1) PRIMARY KEY, 
[Name] nvarchar(50) NOT NULL,
Age tinyint, 
 )
 GO

 CREATE TABLE Towns
 (
 Id int PRIMARY KEY,    
 [Name] nvarchar(50) NOT NULL,
 )
 -- ------------------------------------
/* for adding PK of several columns - NOT NULL!
ALTER TABLE Persons
ADD CONSTRAINT PK_Person PRIMARY KEY (ID,LastName)
 the primary key column(s) must already have been declared 
 to not contain NULL values (when the table was first created).
*/

/* what will happen if Id is already PK ? */

ALTER TABLE Minions
ADD CONSTRAINT PK_Minions PRIMARY KEY (Id,Name)

/*Msg 1779, Level 16, State 0, Line 25
Table 'Minions' already has a primary key defined on it.
Msg 1750, Level 16, State 0, Line 25
Could not create constraint or index. See previous errors.*/

-- to delete constraint -> see name from down code
ALTER TABLE Minions
DROP CONSTRAINT PK__Minions__3214EC075EA140A3

-- !!!!!!!!!!!!!!!!!! to see constraints
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Minions' -- and constraint_type = 'Primary Key'
/*
The INFORMATION_SCHEMA.TABLE_CONSTRAINTS system object can be easily used 
to retrieve information about all defined constraints in a specific table
using the T-SQL script below:
 
SELECT CONSTRAINT_NAME,
     TABLE_SCHEMA ,
     TABLE_NAME,
     CONSTRAINT_TYPE
     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
   WHERE TABLE_NAME='ConstraintDemo2'
 */

-- ----------------------------------------------
-- creating PK with defenite name
CREATE TABLE RR
(
Id int NOT NULL,
NN varchar(50),
CONSTRAINT [Pk_RR] PRIMARY KEY ([Id])
)
-- -----------------------------------------

-- Problem 3.
-- 1st solution - in one step
ALTER TABLE Minions
ADD TownID INT FOREIGN KEY REFERENCES Towns(Id)
GO

--2nd solution - in 2 steps
--add new column TownId
ALTER TABLE Minions
ADD TownID INT;
GO
-- Add new constraint FK - named
ALTER TABLE Minions
ALTER TABLE Minions
ADD CONSTRAINT FK_MinionTownID FOREIGN KEY (TownID) REFERENCES Towns(Id);

GO
/*
CREATE TABLE child_table
(
  column1 datatype [ NULL | NOT NULL ],
  column2 datatype [ NULL | NOT NULL ],
  ...

  CONSTRAINT fk_name
    FOREIGN KEY (child_col1, child_col2, ... child_col_n)
    REFERENCES parent_table (parent_col1, parent_col2, ... parent_col_n)
    [ ON DELETE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
    [ ON UPDATE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ] 
);
 ON DELETE CASCADE/ON UPDATE CASCADE - It means that the child data is either deleted or updated when 
 the parent data is deleted or updated.
*/


-- PROBLEM 4.
/* FOR INSERT -CSV_DATA_INSERT_SQL.py  !!!!!!!
*/
SET IDENTITY_INSERT Towns ON
INSERT INTO Towns (Id,[Name]) VALUES
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna')
SET IDENTITY_INSERT Towns OFF
GO

SET IDENTITY_INSERT Minions ON
INSERT INTO Minions (Id,[Name],Age,TownId) VALUES 
(1,'Kevin',22,1),
(2,'Bob',15,3),
(3,'Steward',NULL,2)
SET IDENTITY_INSERT Minions OFF
GO

/* An explicit value for the identity column in table 'Minions' can only be specified
when a column list is used and IDENTITY_INSERT is ON.*/
 

/*Populate one table using another table
You can populate the data into a table through the select statement over another table; 
provided the other table has a set of fields, which are required to populate the first table.

Here is the syntax ?
*/
INSERT INTO first_table_name [(column1, column2, ... columnN)] 
   SELECT column1, column2, ...columnN 
   FROM second_table_name
   [WHERE condition];
 

 SELECT [Id] AS MinionID, [Name],[Age],[TownId] FROM Minions 
-- Problem 5.
TRUNCATE TABLE Minions
GO
-- Problem 6.
DROP TABLE Minions
DROP TABLE Towns
GO


---- TABLE PEOPLE -------------
-- Problem 7.
CREATE TABLE People
(
Id int NOT NULL PRIMARY KEY IDENTITY(1,1),
[Name] nvarchar(200) NOT NULL,
Picture VARBINARY(MAX) CHECK(DATALENGTH(Picture) <= 2097152),
Height DECIMAL(3,2),
[Weight] DECIMAL(5,2),
Gender CHAR(1)  NOT NULL CHECK (Gender='m' or Gender='f'),
Birthdate DATE NOT NULL,
Biography NVARCHAR(MAX)
)

-- DROP TABLE People
--
INSERT INTO People ([Name], Picture,Height,[Weight],Gender,Birthdate,Biography)
VALUES
       ('First',NULL,1.80,83.5,'m','1990-07-24',NULL),
	   ('Second',NULL,1.65,58.0,'f','1985-08-16',NULL),
	   ('Third',NULL,1.70,68.5,'m','1975-02-14',NULL),
	   ('Forth',NULL,1.83,90.0,'m','1973-09-19',NULL),
	   ('Fifth',NULL,1.58,49.0,'f','1988-01-21',NULL);
GO
SELECT * FROM People

-- Problem 8.
CREATE TABLE Users
(
Id BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
Username VARCHAR(30) UNIQUE NOT NULL,
[Password] VARCHAR(26) NOT NULL,
ProfilePicture VARBINARY(MAX) CHECK(DATALENGTH(ProfilePicture) <= (900 * 1024)),
LastLoginTime DATETIME2,
IsDeleted BIT NOT NULL       -- no boolean datatype in sql /only in Postgresql
-- as BIT can be 0,1 or NULL, constaraint NOT NULL limited values to 0 or 1.
);

INSERT INTO Users (Username, [Password], ProfilePicture,LastLoginTime,IsDeleted)
VALUES
       ('Pesho','123',NULL,'12.25.2020',0),   -- !!! date format 'MM.dd.yyyy'
	   ('Gosho','123',NULL,NULL,0),
	   ('Ivan','123',NULL,NULL,0),
	   ('Test','123',NULL,NULL,1),
	   ('Test123','123',NULL,NULL,1);
GO        
SELECT * FROM Users;

select * from information_schema.table_constraints
where table_name = 'Users'

-- Problem 9.
-- Composite PK
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07843B549C

ALTER TABLE Users
ADD CONSTRAINT PK_Users_composite PRIMARY KEY(Id,Username)

-- Problem 10.
ALTER TABLE Users
ADD CONSTRAINT CK_Password CHECK (LEN([Password]) >=5)  -- LEN - count of symbols

-- Problem 11.
ALTER TABLE Users
ADD CONSTRAINT  DF_logintime DEFAULT GETDATE() FOR LastLoginTime
-- GETDATE() returns in a 'YYYY-MM-DD hh:mm:ss.mmm' format.
-- CURRENT_TIMESTAMP is an ANSI SQL function whereas 
-- GETDATE is the T-SQL version of that same function.

-- Problem 12.
select * from information_schema.table_constraints
where table_name = 'Users'

ALTER TABLE USERS
DROP CONSTRAINT PK_Users

ALTER TABLE USERS
ADD CONSTRAINT PK_Users PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Username CHECK (LEN(Username) >=3)

-- Problem 13.
----  DATABASE MOVIES --------------------
CREATE DATABASE Movies
GO

USE Movies
GO

CREATE TABLE Directors 
(
Id int PRIMARY KEY,
DirectorName nvarchar(100) NOT NULL,
Notes nvarchar(max)
)
CREATE TABLE Genres 
(
Id smallint PRIMARY KEY,
GenreName nvarchar(100) NOT NULL,
Notes nvarchar(max)
)
CREATE TABLE Categories
(
Id smallint PRIMARY KEY,
CategoryName nvarchar(100), 
Notes nvarchar(max)
)
CREATE TABLE Movies 
(
Id bigint PRIMARY KEY,
Title nvarchar(255),
DirectorId int FOREIGN KEY REFERENCES Directors(Id),
CopyrightYear DATE,
[Length] TIME,
GenreId smallint FOREIGN KEY REFERENCES Genres(Id),
CategoryId smallint FOREIGN KEY REFERENCES Categories(Id) ,
Rating tinyint,
Notes nvarchar(max)
)

INSERT INTO Directors VALUES
  ('D1',NULL),
  ('D2',NULL),
  ('D3',NULL),
  ('D4',NULL),
  ('D5',NULL);
INSERT INTO Genres VALUES
  ('G1',NULL),
  ('G2',NULL),
  ('G3',NULL),
  ('G4',NULL),
  ('G5',NULL);
INSERT INTO Categories VALUES
  ('C1',NULL),
  ('C2',NULL),
  ('C3',NULL),
  ('C4',NULL),
  ('C5',NULL);

INSERT INTO Movies VALUES
  ('TITLE1',3,NULL,NULL,1,5,10,NULL),
  ('TITLE2',2,NULL,NULL,3,4,9,NULL),
  ('TITLE3',4,NULL,NULL,5,3,8,NULL),
  ('TITLE4',5,NULL,NULL,2,2,6,NULL),
  ('TITLE5',1,NULL,NULL,4,1,7,NULL);

  SELECT * FROM Directors;
  SELECT * FROM Genres;
  SELECT * FROM Categories;
  SELECT * FROM Movies;

 -- Problem 14.
 -- DATABASE CarRental--------------
 CREATE DATABASE CarRental
 GO

 USE CarRental
 GO

CREATE TABLE Categories
(
Id TINYINT PRIMARY KEY IDENTITY(1,1),
CategoryName nvarchar(50) NOT NULL, 
DailyRate DECIMAL(5,2) DEFAULT 5.0,
WeeklyRate DECIMAL(6,2) DEFAULT 30.0, 
MonthlyRate DECIMAL(7,2) DEFAULT 120.0,
WeekendRate DECIMAL(6,2) DEFAULT 25.0
)

CREATE TABLE Cars
(
Id INT PRIMARY KEY IDENTITY(1,1),
PlateNumber varchar(20) NOT NULL,
Manufacturer nvarchar(20),
Model nvarchar(20),
CarYear DATE,
CategoryId TINYINT FOREIGN KEY REFERENCES Categories(Id),
Doors tinyint,
Picture varbinary(MAX),
Condition varchar(MAX),
Available CHAR(1) NOT NULL,
        CHECK (Available IN ('Y','N'))
);
CREATE TABLE Employees
(
Id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
FirstName nvarchar(20),
LastName nvarchar(30),
Title nvarchar(10),
Notes nvarchar(200)
)
CREATE TABLE Customers 
(
Id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
DriverLicenceNumber nvarchar(20) NOT NULL,
FullName nvarchar(50) NOT NULL, 
[Address] nvarchar(50),
City nvarchar(30),
ZIPCode nvarchar(20),
Notes nvarchar(200)
)

CREATE TABLE RentalOrders 
(
Id bigint NOT NULL IDENTITY(1,1),
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
CarId INT FOREIGN KEY REFERENCES Car(Id),
TankLevel DEC(6,2), 
KilometrageStart smallint,
KilometrageEnd smallint,
TotalKilometrage smallint,
StartDate DATE,
EndDate DATE,
TotalDays smallint,
RateApplied  ????????????????,
TaxRate DEC(6,2),
OrderStatus CHAR(1),
Notes NVARCHAR(MAX)
)
 
INSERT INTO Categories(CategoryName) 
  VALUES 
  ('First'),
  ('Second'),
  ('Third');

INSERT INTO Cars(PlateNumber,Manufacturer,Model,CategoryID,Available) 
  VALUES 
  ('FR 456789','Citroen','Aircross',2,'Y'),
  ('SW 45 67 8G','Volvo','440',3,'N'),
  ('34 4567 HJ','Audi','5',1,'N');
  
   INSERT INTO Employees 
   VALUES
   ('Ivan1','Ivanov1','Mr.',NULL),
   ('Ivan2','Ivanov2','Mr.',NULL),
   ('Ivan3','Ivanov3','Mr.',NULL);

   INSERT INTO Customers (DriverLicenceNumber,FullName)
VALUES
 ('BG5674578','������� �������'),
 ('FR903456G7','Emanuel Poaro'),
 ('BG 7634092','����� ������ ������');

 INSERT INTO RentalOrders 
VALUES
 (1,3,2,25.00,134450.00,137567.00,3112.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (3,2,1,54.00,134450.00,137567.00,3112.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1,1,3,55.00,134450.00,137567.00,3112.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

  SELECT * FROM Categories;
  SELECT * FROM Cars;
  SELECT * FROM Employees;
  SELECT * FROM Customers;
  SELECT * FROM RentalOrders;




-- Problem 15.
-- DATABASE Hotel

CREATE DATABASE Hotel
GO

USE Hotel
GO
 --- DDL - Data Definition Language 
CREATE TABLE Employees (
  Id int PRIMARY KEY IDENTITY(1,1),
  FirstName nvarchar(30) NOT NULL,
  LastName nvarchar(30) NOT NULL,
  Title nvarchar(10),
  Notes nvarchar(MAX)
)

CREATE TABLE Customers 
(
  AccountNumber varchar(30) PRIMARY KEY NOT NULL,
  -- An account number is a unique identifier of the owner of a service
  -- and permits access to it.
  -- it shouldn't be PK because client may want to change it 
  -- and the same account could be used by another in the family or company - not UNIQUE 
  FirstName nvarchar(30) NOT NULL,
  LastName nvarchar(30) NOT NULL,
  PhoneNumber varchar(22),
  EmergencyName nvarchar(50),
  EmergencyNumber varchar(22),
  Notes nvarchar(MAX)
)

CREATE TABLE RoomStatus 
(
 RoomStatus varchar(10) PRIMARY KEY NOT NULL, 
 Notes nvarchar(MAX)
)

CREATE TABLE RoomTypes
(
	RoomType nvarchar(20) PRIMARY KEY NOT NULL,
	Notes nvarchar(MAX)
)

CREATE TABLE BedTypes 
(
BedType nvarchar(20) PRIMARY KEY NOT NULL,
 Notes nvarchar(MAX)
)

CREATE TABLE Rooms 
(
  RoomNumber int PRIMARY KEY IDENTITY(1,1),
  RoomType nvarchar(20) FOREIGN KEY REFERENCES RoomTypes(RoomType),
  BedType nvarchar(20) FOREIGN KEY REFERENCES BedTypes(BedType),
  Rate FLOAT,
  RoomStatus varchar(10) FOREIGN KEY REFERENCES RoomStatus(RoomStatus),
  Notes nvarchar(MAX)
)

CREATE TABLE Payments 
(
  Id int PRIMARY KEY IDENTITY(1,1),
  EmployeeId int FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
  PaymentDate datetime2,
  AccountNumber varchar(30) FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
  FirstDateOccupied datetime2,
  LastDateOccupied datetime2,
  TotalDays int,
  AmountCharged DECIMAL(18,2),
  TaxRate VARCHAR(10),
  TaxAmount DECIMAL(18,2),
  PaymentTotal DECIMAL(18,2) NOT NULL,
  Notes nvarchar(MAX)
)

CREATE TABLE Occupancies 
(
  Id int PRIMARY KEY IDENTITY,
  EmployeeId int FOREIGN KEY REFERENCES Employees(Id),
  DateOccupied datetime2,
  AccountNumber varchar(30)  FOREIGN KEY REFERENCES Customers(AccountNumber),
  RoomNumber int FOREIGN KEY REFERENCES Rooms(RoomNumber),
  RateApplied int,
  PhoneCharge int,
  Notes nvarchar(MAX)
)


-- Problem 16. 
-- DATABASE SoftUni

CREATE DATABASE SoftUni
GO

USE SoftUni
GO

CREATE TABLE Towns (
Id int NOT NULL PRIMARY KEY IDENTITY(1,1),
[Name] nvarchar(50) NOT NULL
)
CREATE TABLE Addresses (
Id int NOT NULL PRIMARY KEY IDENTITY(1,1),
AddressText nvarchar(100),
TownId int NOT NULL FOREIGN KEY REFERENCES Towns(Id)
)
CREATE TABLE Departments (
Id int NOT NULL PRIMARY KEY IDENTITY(1,1),
[Name] nvarchar(50) NOT NULL
)
CREATE TABLE Employees (
Id int NOT NULL PRIMARY KEY IDENTITY(1,1),
FirstName nvarchar(50) NOT NULL,
MiddleName nvarchar(50),
LastName nvarchar(50) NOT NULL,
JobTitle nvarchar(30) NOT NULL,
DepartmentId int NOT NULL FOREIGN KEY REFERENCES Departments(Id),
HireDate DATE,
Salary DEC(7,2),
AddressId int FOREIGN KEY REFERENCES Addresses(Id)
)
 
-- Problem 18.
INSERT INTO Towns([Name])
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

-- can't  TRUNCATE TABLE Towns - it is FK

INSERT INTO Departments ([Name])
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')
SELECT * FROM Departments

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
VALUES 
('Ivan', 'Ivanov', 'Ivanov','.NET Developer',4,'2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov','Senior Engineer',1, '2004-03-02',4000.00),
('Maria', 'Petrova', 'Ivanova','Intern' ,5,	'2016-08-28',	525.25),
('Georgi', 'Teziev', 'Ivanov',	'CEO',2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan',	'Intern',3,	'2016-08-28',	599.88)



---------   Problem 19.	Basic Select All Fields
SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

---------- Problem 20.	Basic Select All Fields and Order Them
SELECT * FROM Towns ORDER BY [Name] ;
SELECT * FROM Departments ORDER BY [Name] ;
SELECT * FROM Employees ORDER BY Salary DESC;

-- Problem 21.	Basic Select Some Fields
SELECT [Name] FROM Towns ORDER BY [Name] ;
SELECT [Name] FROM Departments ORDER BY [Name] ;
SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Salary DESC;

----------Problem 22.	Increase Employees Salary ------
SELECT * FROM Employees;

UPDATE Employees
 SET Salary *= 1.1;

SELECT Salary FROM Employees;

----------Problem 23.	Decrease Tax Rate
USE Hotel
GO

UPDATE Payments
	SET TaxRate *=0.97
SELECT TaxRate FROM Payments

----------Problem 24.	Delete All Records

TRUNCATE TABLE  Occupancies;
SELECT * FROM  Occupancies;