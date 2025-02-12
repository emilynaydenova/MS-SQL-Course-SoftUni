USE SoftUni
GO

SELECT CONCAT_WS(' ',FirstName,MiddleName,LastName) as [Full Name],
		JobTitle,
		Salary
	FROM Employees

SELECT TOP(10)
	CONCAT_WS(' ',FirstName,MiddleName,LastName) as [Full Name],
		JobTitle,
		Salary
	FROM Employees

SELECT DISTINCT JobTitle 
		FROM Employees

SELECT DISTINCT JobTitle,Salary  
		FROM Employees

SELECT COUNT(DISTINCT JobTitle) 
		FROM Employees   -- 58

SELECT DISTINCT JobTitle,
     (SELECT COUNT(*) FROM Employees AS e2 WHERE e2.JobTitle = e1.JobTitle) AS 'Count'
	FROM [Employees] as e1

-- better
SELECT JobTitle, COUNT(*)
FROM Employees
GROUP BY JobTitle

SELECT LastName, DepartmentID 
  FROM Employees 
 WHERE DepartmentID = 1

SELECT LastName, Salary
  FROM Employees 
 WHERE Salary >= 40000


SELECT FirstName, LastName, Salary
  FROM Employees 
 --WHERE FirstName ='Chris'
 WHERE FirstName LIKE '%ris' -- 'ris' IN FirstName or find()

 SELECT FirstName, LastName, JobTitle, Salary
  FROM Employees 
 WHERE Salary >= 10000
		AND Salary <= 20000
		AND JobTitle = 'Production Technician'
		AND FirstName LIKE 'A%'


 SELECT FirstName, LastName, JobTitle, Salary
  FROM Employees 
 WHERE Salary BETWEEN 12500	AND 15000  -- inclusive

SELECT FirstName, LastName, ManagerID 
FROM Employees
WHERE ManagerID IN (109, 3, 16)

-- with regEx
SELECT FirstName, LastName, Salary
  FROM Employees 
 --WHERE FirstName LIKE '[A,K]%'   -- begin with A or K
 --WHERE FirstName LIKE '[A-K]%'   -- begin with A to K
 --WHERE FirstName LIKE '[A-K][a-m]%'   -- begin with A to K, second a-m
 WHERE FirstName LIKE '%[s][a-k]%'

 --RegEx https://study.com/academy/lesson/regular-expressions-in-sql-server-databases-implementation-use.html

 SELECT FirstName,LastName, HireDate
    FROM Employees
ORDER BY HireDate DESC,FirstName

USE SoftUni
GO

CREATE VIEW v_GetDateByDayOfWeek AS 
	SELECT HireDate , DATENAME(dw,HireDate) AS [DayOfWeek]
	  FROM Employees

SELECT * FROM v_GetDateByDayOfWeek


 --____________________________________________________________
 USE Geography
 GO
 -- DATABASE Geography
 CREATE VIEW v_Highest_Peak AS
	 SELECT TOP(1) * FROM Peaks
	 ORDER BY Elevation DESC
 
 SELECT * FROM v_Highest_Peak


 --______________________________________________________________

 USE SoftUni
 GO

 SELECT LastName,JobTitle,DepartmentID  
 INTO Workers
 FROM Employees

 /*CREATE SEQUENCE [schema_name . ] sequence_name  
    [ AS [ built_in_integer_type | user-defined_integer_type ] ]  
    [ START WITH <constant> ]  
    [ INCREMENT BY <constant> ]  
    [ { MINVALUE [ <constant> ] } | { NO MINVALUE } ]  
    [ { MAXVALUE [ <constant> ] } | { NO MAXVALUE } ]  
    [ CYCLE | { NO CYCLE } ]  
    [ { CACHE [ <constant> ] } | { NO CACHE } ]  
    [ ; ] */

CREATE SEQUENCE seq_MySequence AS INT
     START WITH 0
   INCREMENT BY 1001

SELECT NEXT VALUE FOR seq_MySequence


--- DELETING

SELECT * FROM Employees

INSERT INTO Employees(FirstName,LastName,JobTitle,DepartmentID,HireDate,Salary)
	VALUES 
	('Ivan','Petrov','Bagerist',8,'2020-12-27',5000)

DELETE FROM Employees
WHERE EmployeeID = (SELECT MAX(EmployeeID) FROM Employees)

--- Updating
UPDATE Employees
   SET Salary *= 1.10,
       JobTitle = 'Senior' + JobTitle
 WHERE DepartmentID = 3

 SELECT * FROM Projects
 WHERE EndDate IS NULL 

 UPDATE Projects
   SET EndDate = GETDATE()
 WHERE EndDate IS NULL AND StartDate < '2005-01-01'


 -------------- output as JSON
SELECT LastName, Salary
	FROM Employees FOR JSON AUTO;


----------- EXERCISES ---------------
USE SoftUni
GO

--- Problem 2.	Find All Information About Departments
SELECT * 
	FROM Departments

--- Problem 3.	Find all Department Names
SELECT [Name]
	FROM Departments

--- Problem 4.	Find Salary of Each Employee
SELECT FirstName, LastName, Salary
	FROM Employees

--- Problem 5.	Find Full Name of Each Employee
SELECT FirstName, MiddleName, LastName
	FROM Employees

--- Problem 6.	Find Email Address of Each Employee
SELECT CONCAT(FirstName,'.',LastName,'@softuni.bg') AS [Full Email Address] 
	FROM Employees

--- Problem 7.	Find All Different Employee’s Salaries
SELECT DISTINCT Salary
	FROM Employees
 

--- Problem 8.	Find all Information About Employees
SELECT *
	FROM Employees
	WHERE JobTitle = 'Sales Representative'

--- Problem 9.	Find Names of All Employees by Salary in Range
SELECT FirstName,LastName,JobTitle
	FROM Employees 
	WHERE Salary BETWEEN 20000 AND 30000


--- Problem 10.	 Find Names of All Employees 
-- SELECT CONCAT_WS(' ',FirstName,MiddleName, LastName) AS [Full Name]
-- SELECT REPLACE(CONCAT(FirstName+' ',MiddleName+' ',LastName+' '),'  ',' ') AS [Full Name]
SELECT CONCAT(FirstName,' ',MiddleName,' ',LastName) AS [Full Name]
	FROM Employees
	WHERE Salary in (25000, 14000, 12500, 23600)

--- Problem 11.	 Find All Employees Without Manager
SELECT FirstName, LastName
	FROM Employees
	WHERE ManagerID IS NULL

--- Problem 12. Find All Employees with Salary More Than 50000
SELECT FirstName, LastName, Salary
	FROM Employees
	WHERE Salary > 50000
	ORDER BY Salary DESC

--- Problem 13.	 Find 5 Best Paid Employees.
SELECT TOP(5) FirstName, LastName
	FROM Employees
	ORDER BY Salary DESC

--- Problem 14.	Find All Employees Except Marketing
SELECT FirstName, LastName
	FROM Employees
	WHERE DepartmentID != 4


--- Problem 15.	Sort Employees Table
SELECT * 
	FROM Employees
	ORDER BY Salary DESC, FirstName, LastName DESC, MiddleName

GO
--- Problem 16. Create View Employees with Salaries
CREATE VIEW V_EmployeesSalaries 
AS
	SELECT FirstName,LastName,Salary
	FROM Employees

GO
--
SELECT * FROM V_EmployeesSalaries
DROP View V_EmployeesSalaries  -- for delete

GO
--- Problem 17.	Create View Employees with Job Titles
CREATE VIEW V_EmployeeNameJobTitle 
AS
--SELECT CONCAT_WS(' ',FirstName,MiddleName,LastName) AS [Full Name], JobTitle AS [Job Title]
	SELECT CONCAT(FirstName,' ',ISNULL(MiddleName,''),' ',LastName) AS [Full Name],
		JobTitle AS [Job Title]
		FROM Employees

GO
SELECT * FROM V_EmployeeNameJobTitle

--- Problem 18.Distinct Job Titles
SELECT DISTINCT JobTitle
	FROM Employees

--- Problem 19.	Find First 10 Started Projects
SELECT TOP(10) * 
	FROM Projects
	ORDER BY StartDate, [Name]


-- Problem 20. Last 7 Hired Employees
SELECT TOP(7) FirstName, LastName, HireDate 
	FROM Employees
	ORDER BY HireDate DESC


/*
UPDATE table1
SET table1.c1 = ....,
    table1.c2 = expression,
    ...   
FROM table1
     [INNER | LEFT] JOIN table2 ON join_predicate
WHERE 
    where_predicate;
*/
 -- Backup SoftUni 

--- Problem 21. Increase Salaries !!!!
UPDATE Employees
	SET Salary *= 1.12
	FROM Employees e
	JOIN Departments d ON e.DepartmentID = d.DepartmentID
	WHERE d.[Name] IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services') 
	SELECT Salary FROM Employees;
 
---
--- Restore SoftUni

-- Problem 22. All Mountain Peaks
USE Geography
GO

SELECT PeakName
	FROM Peaks
	ORDER BY PeakName

-- Problen 23. Biggest Countries by Population
SELECT TOP(30) CountryName,[Population]
	FROM Countries
	WHERE ContinentCode = 'EU'
	ORDER BY [Population] DESC


--- Problem 24.	 *Countries and Currency (Euro / Not Euro)
SELECT CountryName, CountryCode,
    CASE 
	  WHEN CurrencyCode = 'EUR' THEN 'Euro'
	  ELSE 'Not Euro'
	END AS 'Currency'
FROM Countries
ORDER BY CountryName
 

 /*SELECT ProductNumber, Name,
 "Price Range" = 
  CASE 
     WHEN ListPrice =  0 THEN 'Mfg item - not for resale'
     WHEN ListPrice < 50 THEN 'Under $50'
     WHEN ListPrice >= 50 and ListPrice < 250 THEN 'Under $250'
     WHEN ListPrice >= 250 and ListPrice < 1000 THEN 'Under $1000'
     ELSE 'Over $1000'
  END
FROM Production.Product
ORDER BY ProductNumber ;*/

GO 

-- Problem 25.	 All Diablo Characters
USE Diablo
GO

SELECT [Name]
	FROM Characters
	ORDER BY [Name]