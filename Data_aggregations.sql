USE Gringotts
GO
SELECT *
FROM Gringotts.INFORMATION_SCHEMA.TABLES;
SELECT  * 
FROM WizzardDeposits

-- Table WizzardDeposits

-- Problem 1. Records’ Count

SELECT Count(*) AS [Count]
	FROM WizzardDeposits 

-- Problem 2. Longest Magic Wand

SELECT MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits 

-- Problem 3. Longest Magic Wand Per Deposit Groups

SELECT DepositGroup,MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits
	GROUP BY DepositGroup

-- Problem 4. Smallest Deposit Group Per Magic Wand Size
SELECT TOP(2) d.DepositGroup
	FROM 
	   (SELECT DepositGroup, AVG(MagicWandSize) AS LongestMagicWand
		FROM WizzardDeposits
		GROUP BY DepositGroup) AS d
	ORDER BY d.LongestMagicWand 
-- !! or
SELECT  TOP(2) DepositGroup 
	FROM WizzardDeposits
	GROUP BY DepositGroup
	ORDER BY AVG(MagicWandSize);


--  Problem 5. Deposits Sum
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	GROUP BY DepositGroup

-- Problem 6. Deposits Sum for Ollivander Family
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
	GROUP BY DepositGroup
 

-- Problem 7. Deposits Filter
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
	GROUP BY DepositGroup
	HAVING SUM(DepositAmount) < 150000
	ORDER BY TotalSum DESC

-- Problem 8.  Deposit Charge
 SELECT DepositGroup, MagicWandCreator,MIN(DepositCharge) AS MinDepositCharge
	FROM WizzardDeposits
	GROUP BY DepositGroup,MagicWandCreator
    ORDER BY MagicWandCreator, DepositGroup

 -- Problem 9. Age Groups
 
SELECT AgeGroup,COUNT(*) AS [WizardCount]   
	FROM
	 	   (SELECT 
				CASE
					WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
					WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
					WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
					WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
					WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
					WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
					ELSE '[61+]'
				 END  AS AgeGroup
				 FROM WizzardDeposits
			 ) AS t
	GROUP BY AgeGroup
	ORDER BY AgeGroup
-- new table t with added new column Range where age is displayed as [....],
-- then group in t by Range

-- Problem 10. First Letter
SELECT LEFT(FirstName,1) AS FirstLetter
    FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
	GROUP BY LEFT(FirstName,1)
	ORDER BY FirstLetter

-- or
SELECT DISTINCT LEFT(FirstName,1) AS FirstLetter
	FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
	ORDER BY FirstLetter

-- PROBLEM 11. Average Interest 
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
	FROM WizzardDeposits
	WHERE DepositStartDate > '1985-01-01'
	GROUP BY DepositGroup,IsDepositExpired
	ORDER BY DepositGroup DESC, IsDepositExpired


-- PROBLEM 12. Rich Wizard, Poor Wizard ***
-- self-join

 SELECT SUM(prv.DepositAmount-nxt.DepositAmount) AS SumDifference
	FROM WizzardDeposits AS prv
	JOIN WizzardDeposits AS nxt ON prv.id+1 = nxt.id


 -----
 SELECT SUM(p)
	FROM (
			SELECT DepositAmount - (LEAD(DepositAmount,1) OVER (ORDER BY id)) AS p
			FROM WizzardDeposits ) s
 
 USE SoftUni
 GO
 -- Problem 13. Departments Total Salaries
 
 SELECT DepartmentID,SUM(Salary) AS TotalSalary 
	FROM Employees
	GROUP by DepartmentID
	ORDER BY DepartmentID

 -- Problem 14. Employees Minimum Salaries
 SELECT DepartmentID, MIN(Salary) AS MinimumSalary
	FROM Employees
	WHERE DepartmentID IN (2,5,7) AND HireDate > '2000-01-01'
	GROUP BY DepartmentID


 -- Problem 15. Employees Average Salaries
/* прехвърляне към tmp таблица    !!!!!!
 SELECT *
 INTO newtable [IN externaldb]
 FROM oldtable
 WHERE condition; */

SELECT *
	INTO #TempEmployees
	FROM Employees
	WHERE Salary > 30000   -- 29 rows


DELETE FROM #TempEmployees WHERE ManagerID = 42;   -- 3 rows

--SELECT * FROM #TempEmployees -- 26 rows

UPDATE #TempEmployees
	SET Salary += 5000
	WHERE DepartmentID = 1;

SELECT DepartmentID, AVG(Salary) AS AverageSalary
	FROM #TempEmployees
	GROUP BY DepartmentID

--DROP TABLE #TempEmployees

-- Problem 16. Employees Maximum Salaries

SELECT DepartmentID,MAX(Salary) AS MaxSalary
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000


-- Problem 17. Employees Count Salaries
SELECT COUNT(Salary) As Count
	FROM Employees
	WHERE ManagerID IS NULL


-- Problem 18. 3rd Highest Salary  ***

SELECT DepartmentID, Salary AS [ThirdHighestSalary]
FROM
	(
		SELECT DepartmentID, Salary, 
		   DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS [Salary_rank]
		FROM Employees
		GROUP BY DepartmentID,Salary
	) AS [RankTable]
	WHERE [Salary_rank] = 3;


-- PROBLEM 19. Salary Challenge ***

SELECT TOP(10) FirstName, LastName, DepartmentID
	FROM Employees AS e
	WHERE Salary >
		(SELECT AVG(Salary)
			FROM Employees AS s
			WHERE e.DepartmentID = s.DepartmentID  -- !!!! - connect 2 Selects
			)  
	ORDER BY DepartmentID


--- with #Temporary table to store average salaries per department

CREATE TABLE #DepartmentAvgSalary (
    DepartmentID INT,
    AvgSalary DECIMAL(18,2)
);

-- Insert average salaries for each department
INSERT INTO #DepartmentAvgSalary (DepartmentID, AvgSalary)
	SELECT DepartmentID, AVG(Salary) AS AvgSalary
	FROM Employees
	GROUP BY DepartmentID;

-- Select the top 10 employees who earn more than their department's average salary
SELECT TOP(10) e.FirstName, e.LastName, e.DepartmentID
	FROM Employees AS e
	JOIN #DepartmentAvgSalary AS d ON e.DepartmentID = d.DepartmentID
	WHERE e.Salary > d.AvgSalary
	ORDER BY e.DepartmentID;

-- Drop the temporary table (optional, as it will be automatically deleted after the session ends)
DROP TABLE #DepartmentAvgSalary;
 