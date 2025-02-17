USE SoftUni
GO
-- Problem 1.	Find Names of All Employees by First Name
 SELECT FirstName,LastName 
	FROM Employees
	WHERE FirstName LIKE 'SA%'
-- WHERE LEFT(FirstName,2) LIKE 'SA'

 -- Problem 2.	  Find Names of All employees by Last Name 
 SELECT FirstName, LastName
	FROM Employees
	WHERE LastName LIKE '%ei%'

-- Problem 3.	Find First Names of All Employees
SELECT FirstName
	FROM Employees
	WHERE DepartmentID IN (3,10) AND YEAR(HireDate) BETWEEN 1995 AND 2005


 -- Problem 4.	Find All Employees Except Engineers
 SELECT FirstName, LastName 
	FROM Employees
	WHERE JobTitle NOT LIKE '%engineer%'


 -- Problem 5.	Find Towns with Name Length
SELECT [Name] FROM Towns
	WHERE LEN([Name]) IN (5,6)
	ORDER BY [Name]

-- Problem 6.	 Find Towns Starting With
SELECT * FROM Towns
	WHERE [Name] LIKE '[MKBE]%'
	ORDER BY [Name]
-- WHERE LEFT(Name,1) IN ('M', 'K', 'B', 'E')

-- Problem 7.	 Find Towns Not Starting With
SELECT * FROM Towns
	WHERE [Name] NOT LIKE '[RBD]%'
	ORDER BY [Name]

GO
-- Problem 8.	Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 
AS
	SELECT FirstName,LastName 
	FROM Employees
	WHERE YEAR(HireDate) > 2000

SELECT * FROM V_EmployeesHiredAfter2000 

DROP VIEW V_EmployeesHiredAfter2000

-- Problem 9.	Length of Last Name
SELECT FirstName,LastName 
	FROM Employees
WHERE LEN(LastName) = 5

-- Problem 10. Rank Employees by Salary
SELECT EmployeeID,FirstName,LastName,Salary,
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
	ORDER BY Salary DESC


-- Problem 11.	Find All Employees with Rank 2 *
SELECT * 
	FROM
		(SELECT EmployeeID,FirstName,LastName,Salary,
			DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
		FROM Employees
		WHERE Salary BETWEEN 10000 AND 50000
		) AS Ranked
	WHERE Ranked.Rank = 2
	ORDER BY Salary DESC
----------------------------------------------
USE Geography
GO

-- Problem 12.	Countries Holding ‘A’ 3 or More Times
SELECT CountryName,IsoCode
	FROM Countries
	WHERE (LEN(LOWER(CountryName)) - LEN(REPLACE(LOWER(CountryName), 'a', ''))) >= 3
 	ORDER BY IsoCode
	
 

-- Problem 13.	 Mix of Peak and River Names
SELECT * FROM
(SELECT p.PeakName,  r.RiverName,
	LOWER(CONCAT(p.PeakName,RIGHT(RiverName,LEN(r.RiverName)-1))) AS MIX
	 FROM Peaks AS p, RIVERS as r
	 ) AS j
	 WHERE RIGHT(PeakName,1) = LEFT(RiverName,1)
	 ORDER BY MIX
 
 -- -------------------
 USE Diablo
 GO
-- Problem 14.	Games from 2011 and 2012 year
SELECT TOP(50) [Name], FORMAT([Start],'yyyy-MM-dd') As [Start]
	FROM Games
	WHERE YEAR([Start]) IN (2011,2012) 
	ORDER BY [Start],[Name]

 
 -- Problem 15.	 User Email Providers
 SELECT Username,
		SUBSTRING(Email,CHARINDEX('@',Email)+1,LEN(Email)) AS [Email Provider]
	 FROM Users
	 ORDER BY [Email Provider],Username

-- !!!
SELECT Username,RIGHT(Email,LEN(Email) - CHARINDEX('@',Email)) AS [Email Provider]
	 FROM Users
	 ORDER BY [Email Provider],Username

-- Problem 16.	 Get Users with IPAdress Like Pattern
SELECT Username, IpAddress AS [IP Address]
	FROM Users
 WHERE IpAddress  LIKE '___.1_%._%.___'           
 ORDER BY Username


 -- Problem 17.	 Show All Games with Duration and Part of the Day
 SELECT [Name] AS Game,
'Part of the day'=
	CASE
		WHEN (DATEPART(HOUR,Start) >=0 AND DATEPART(HOUR,Start) <12) THEN 'Morning'
		WHEN (DATEPART(HOUR,Start) >=12 AND DATEPART(HOUR,Start) <18) THEN 'Afternoon'
		WHEN (DATEPART(HOUR,Start) >=18 AND DATEPART(HOUR,Start) <24) THEN 'Evening'
	END,
'Duration'=
	CASE
		WHEN Duration IS NULL THEN 'Extra Long'
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
	END
 FROM Games
 ORDER BY Game,Duration

 ---------------------
USE ORDERS
GO

-- Problem 18.	 Orders Table
 SELECT ProductName,OrderDate,
	DATEADD(day,3,OrderDate) AS 'Pay Due',
	DATEADD(month,1,OrderDate) AS 'Deliver Due'
 FROM Orders

 SELECT ProductName,OrderDate,
 'Pay Due'= DATEADD(DAY,3,OrderDate),
 'Deliver Due'= DATEADD(MONTH,1,OrderDate)
 FROM Orders

 -- Problem 19.	 People Table
CREATE TABLE People(
     Id INT PRIMARY KEY IDENTITY(1,1), 
     [Name] NVARCHAR(50),
     Birthdate DATETIME2
) 
INSERT INTO People
VALUES
	('Victor','2000-12-07 00:00:00.000'),
	('Steven','1992-09-10 00:00:00.000'),
    ('Stephen','1910-09-19 00:00:00.000'),
    ('John','2010-01-06 00:00:00.000')

SELECT Name,
	DATEDIFF(year, Birthdate,GETDATE()) AS 'Age in Years',
	DATEDIFF(month, Birthdate,GETDATE()) AS 'Age in Months',
	DATEDIFF(day, Birthdate,GETDATE()) AS 'Age in Days',
	DATEDIFF(minute, Birthdate,GETDATE()) AS 'Age in Minutes'
  FROM People


  
 SELECT [Name],
  'Age in Years' = DATEDIFF(year,Birthdate,GETDATE()),
  'Age in Months' =	DATEDIFF(month,Birthdate,GETDATE()),
  'Age in Days' = DATEDIFF(day,Birthdate,GETDATE()),
  'Age in Minutes' = DATEDIFF(minute,Birthdate,GETDATE())
 FROM People

 ----------------------Labs------------------------
 USE DEMO
GO
SELECT FirstName,
		LastName,
		STUFF(PaymentNumber, --old_str
					7, --start
					10, --length
					REPLICATE('*',LEN(PaymentNumber)-6) --new_str
	) AS PaymentNumber
FROM CUSTOMERS
GO

CREATE VIEW v_CustomersWithObfuscatedCardNumber AS
	SELECT FirstName,LastName,
		LEFT(PaymentNumber,6) + REPLICATE('*',LEN(PaymentNumber)-6) AS PaymentNumber
	FROM CUSTOMERS;

-- SELECT * FROM v_CustomersWithObfuscatedCardNumber

SELECT A,H, A * H / 2.0 AS Area, ROUND(A * H / 2.0 ,1,0)
FROM Triangles2

SELECT * ,
CEILING(Quantity*1.0/BoxCapacity) AS [Number of boxes],
CEILING(CEILING(Quantity*1.0/BoxCapacity)/PalletCapacity) AS [Number of pallets]
FROM Products

-- !!! Quantity * 1.0 -> float за да може да го закръгли CEILING

SELECT RAND(3),RAND(1)  -- RAND(seed)

-- !!!!!!!!!!!!
SET LANGUAGE Bulgarian
SELECT DATENAME(dw,'2020-12-31') 

SELECT DATENAME(month,'2020-12-31')

SET LANGUAGE English
SELECT DATENAME(month,'2020-12-31')

 -- To specify a language in Unicode, use "N'language'"

 
SELECT FORMAT(GETDATE(),'dddd','bg-BG')  -- day of week

 --!!!----- Ranking
 USE SoftUni
 GO
 SELECT 
		ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNo,
		RANK() OVER (ORDER BY Salary DESC) AS RankNo,
		DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRankNo,
		NTILE(30) OVER (ORDER BY Salary DESC) AS GroupRankNo,
		SUM(Salary) OVER (ORDER BY Salary DESC) AS SalarySum ,  -- s natrupvane
		MIN(Salary) OVER (ORDER BY DepartmentID) AS MinSum,
		Salary,EmployeeID,FirstName,LastName
 FROM Employees
 ORDER BY RowNo

SELECT *  FROM Employees
-- !!! PARTITION BY .... ORDER BY....
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
 

DECLARE @str NVARCHAR(100) ='abcdefghijKlM';
SELECT 
    UPPER(LEFT(@str, 5)) + 
    SUBSTRING(@str, 6, LEN(@str) - 10) + 
    LOWER(RIGHT(@str, 5)) 
AS modified_string;