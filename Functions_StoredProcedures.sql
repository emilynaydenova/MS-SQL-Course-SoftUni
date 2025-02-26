USE SoftUni
GO
-- Problem 1. Employees with Salary Above 35000
CREATE OR ALTER PROC usp_GetEmployeesSalaryAbove35000
   AS
    SELECT FirstName AS [First Name],
	       LastName  AS [Last Name]
	FROM Employees 
	WHERE Salary > 35000
	GO

EXEC usp_GetEmployeesSalaryAbove35000
GO

-- Problem 2. Employees with Salary Above Number
CREATE OR ALTER PROC usp_GetEmployeesSalaryAboveNumber(@limit DECIMAL(18,4))
   AS
    SELECT FirstName AS [First Name],
	       LastName  AS [Last Name]
	FROM Employees 
	WHERE Salary >= @limit

GO
EXEC usp_GetEmployeesSalaryAboveNumber 50000;


-- Problem 3. Town Names Starting With
USE SoftUni
GO
CREATE OR ALTER PROC usp_GetTownsStartingWith(@StartsWith varchar(50))
  AS
    SELECT [Name] AS Town
	FROM Towns 
	WHERE LEFT([name],1) = @StartsWith

GO

EXEC usp_GetTownsStartingWith N

GO
-- Problem 4. Employees from Town
CREATE OR ALTER PROC usp_GetEmployeesFromTown(@townName varchar(50))
  AS
    SELECT FirstName AS [First Name],
	       LastName  AS [Last Name]
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID=a.AddressID
	JOIN Towns AS t ON t.TownID=a.TownID
	WHERE t.[Name] = @townName

GO
EXEC usp_GetEmployeesFromTown Sofia

GO
-- Problem 5. Salary Level Function
CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
 RETURNS VARCHAR(10)
 AS
  BEGIN
  	RETURN
		CASE
		    WHEN @salary IS NULL Then Null
			WHEN @salary < 30000 THEN 'Low'
	        WHEN @salary <=50000 THEN 'Average'  
            ELSE 'High'
	   END;
 END;
 GO
 SELECT Salary, SoftUni.dbo.ufn_GetSalaryLevel(salary) AS [Salary Level]
 FROM Employees;

 GO

-- Problem 6. Employees by Salary Level
CREATE OR ALTER PROC usp_EmployeesBySalaryLevel(@Level varchar(10))
   AS
    SELECT FirstName AS [First Name],
	       LastName  AS [Last Name]
	FROM Employees 
	WHERE dbo.ufn_GetSalaryLevel(Salary)= @Level
GO

EXEC  usp_EmployeesBySalaryLevel 'High'
GO

 -- Problem 7.	Define Function
CREATE OR ALTER FUNCTION ufn_IsWordComprised(
	@setOfLetters varchar(50),
	@word varchar(50))
RETURNS BIT
AS
BEGIN
  DECLARE @i INT =1, @TRUE INT =1, @FALSE INT =0  
	 WHILE(@i <= LEN(@word))
	 BEGIN
	  DECLARE @currentLetter CHAR(1) = SUBSTRING(@word,@i,1)
	  DECLARE @CharIndex INT = CHARINDEX(@currentLetter,@setOfLetters)
	  
	   IF ( @CharIndex = 0)
	   BEGIN
	    RETURN @FALSE
	   END
	 
	   SET @i +=1
	 END  
RETURN @TRUE
END
GO

SELECT dbo.ufn_IsWordComprised('ptrjkemlevjepn','pleven') AS RESULT
 
SELECT FirstName FROM Employees
	WHERE dbo.ufn_IsWordComprised('oistmiahf', FirstName) = 1
 
 GO

-- Problem 8. * Delete Employees and Departments
CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
   DELETE FROM EmployeesProjects  --free from EmployeesProjects -
	  WHERE EmployeeID IN
	  (SELECT EmployeeID FROM Employees
		WHERE DepartmentID=@departmentId)
	 
	UPDATE Employees   -- free from ManagerID
    SET ManagerID = NULL
    WHERE MAnagerID IN
	   (SELECT EmployeeID FROM Employees
		WHERE DepartmentID=@departmentId)
 
	ALTER TABLE Departments    -- make NULLable in table Departments
		ALTER COLUMN ManagerId INT NULL;

	UPDATE Departments
	SET ManagerID = NULL
	WHERE DepartmentID=@departmentId

	DELETE FROM Employees      -- delete Employees
	  WHERE DepartmentID=@departmentId

	DELETE FROM Departments     -- delete the whole department
	  WHERE DepartmentID=@departmentId

   SELECT COUNT(*)
   FROM Employees
   WHERE DepartmentID=@departmentId ;
 
 GO

 -- Problem 9. Find Full Name
USE BANK
GO

CREATE PROC usp_GetHoldersFullName 
AS
	SELECT CONCAT(FirstName,' ',LastName) AS [Full Name]
	FROM AccountHolders 

 
 GO

EXEC usp_GetHoldersFullName
GO
-- Problem 10. People with Balance Higher Than

 CREATE PROC usp_GetHoldersWithBalanceHigherThan(@level DECIMAL(18,2))
 AS
	 SELECT dd.FirstName AS [First Name], dd.LastName AS [Last Name]
	 FROM
 		(SELECT FirstName , LastName ,SUM(Balance) AS SumBalance
		FROM AccountHolders ah
		JOIN Accounts a ON a.AccountHolderId = ah.Id
		GROUP BY ah.Id,FirstName,LastName) AS dd
	 WHERE dd.SumBalance > @level
	 ORDER BY FirstName ,LastName 

EXEC usp_GetHoldersWithBalanceHigherThan 30000

GO
 ---- Problem 11.	Future Value Function
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(
		@sum DECIMAL(18,4),
		@yearlyInterestRate FLOAT,
		@numberOfYears INT)
RETURNS DECIMAL(18,4)
AS
	BEGIN
	  DECLARE @result DECIMAL(18,4)
	  SET @result= @sum*POWER((1+@yearlyInterestRate),@numberOfYears)
      RETURN @result
    END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO
-- Problem 12. Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount (@AccountId int, @InterestRate float)
AS
	SELECT ah.Id, ah.FirstName AS [First Name], ah.LastName AS [Last Name],
			a.Balance AS [Current Balance],
			dbo.ufn_CalculateFutureValue(Balance,@InterestRate,5) AS [Balance in 5 years]
		FROM AccountHolders ah
		JOIN Accounts a ON ah.Id = a.AccountHolderId
		WHERE a.Id = @AccountId

EXEC usp_CalculateFutureValueForAccount 1, 0.1

GO
---- Problem 13.	*Scalar Function: Cash in User Games Odd Rows
USE DIABLO
GO

CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
  RETURN
  (
    SELECT SUM(k.Cash) AS SumCash
    FROM
    (
        SELECT g.[Name], 
               u.Cash AS Cash, 
               ROW_NUMBER() OVER(ORDER BY Cash DESC) AS ROW_NUM
        FROM Games AS g
         JOIN UsersGames AS u ON u.GameID = g.Id
        WHERE g.[Name] = @gameName
    ) AS k
    WHERE (ROW_NUM % 2) !=0
);
GO

SELECT * FROM Diablo.dbo.ufn_CashInUsersGames('Love in a mist');

 