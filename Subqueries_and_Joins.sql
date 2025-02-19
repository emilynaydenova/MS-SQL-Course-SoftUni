USE SoftUni
GO
SELECT * FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID

---  1.	Employee Address
SELECT TOP(5) EmployeeID, JobTitle, e.AddressID,a.AddressText
	FROM Employees e
	JOIN [Addresses] a ON a.AddressID = e.AddressID
	ORDER BY e.AddressID

---- 2.	Addresses with Towns
SELECT TOP(50) FirstName, LastName, 
				t.[Name] AS Town,
				a.AddressText AS [Address] 
	FROM Employees e
	JOIN Addresses a ON a.AddressID = e.AddressID
	JOIN Towns t ON t.TownID = a.TownID
	ORDER BY FirstName, LastName


---- 3.	Sales Employee
	SELECT EmployeeID,FirstName,LastName,d.[Name] AS DepartmentName
		FROM Employees e
		JOIN Departments d ON d.DepartmentID = e.DepartmentID
		WHERE d.[Name] = 'Sales'
		ORDER BY EmployeeID


----4.	Employee Departments

SELECT TOP(5) EmployeeID, FirstName, 
	Salary, d.[Name] AS DepartmentName
	FROM Employees e
	JOIN Departments d ON d.DepartmentID = e.DepartmentID
	WHERE Salary > 15000
	ORDER BY e.DepartmentID ASC


---- 5.	Employees Without Project

SELECT TOP(3) e.EmployeeID,e.FirstName,ep.ProjectID
	FROM Employees e
	LEFT JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	WHERE ep.ProjectID IS NULL
	ORDER BY e.EmployeeID


---- 6.	Employees Hired After

SELECT FirstName, LastName,	HireDate,d.[Name] AS DeptName
	FROM Employees e
	JOIN Departments d ON d.DepartmentID = e.DepartmentID
	WHERE HireDate > '1999-01-01' AND d.[Name] IN ('Sales', 'Finance')
	ORDER BY HireDate


---- 7.	Employees with Project
 
SELECT TOP(5) e.EmployeeID,e.FirstName,p.[Name] AS ProjectName FROM Employees e
	JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects p ON p.ProjectID = ep.ProjectID
	WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
	ORDER BY e.EmployeeID


----8.	Employee 24

SELECT e.EmployeeID, e.FirstName, 
      IIF(YEAR(p.StartDate)>=2005,NULL,p.[Name]) AS ProjectName
	FROM Employees e
	JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects p ON p.ProjectID = ep.ProjectID
	WHERE e.EmployeeID = 24


----9.	Employee Manager
SELECT e1.EmployeeID, e1.FirstName, e1.ManagerID, e2.FirstName AS ManagerName
	FROM Employees e1
	JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID
	WHERE e1.ManagerId IN (3,7)
	ORDER BY e1.EmployeeID

--- 10. Employee Summary
SELECT TOP(50) e1.EmployeeID, 
		   CONCAT(e1.FirstName,' ',e1.LastName) AS EmployeeName,
           CONCAT(e2.FirstName,' ',e2.LastName) AS ManagerName,
		   d.[Name] AS DepartmentName
FROM Employees e1
JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID
JOIN Departments d ON d.DepartmentId = e1.DepartmentId
ORDER BY e1.EmployeeID


------11. Min Average Salary
SELECT TOP(1) AVG(Salary) AS MinAverageSalary
	FROM Employees e
	GROUP BY e.DepartmentID
	ORDER BY MinAverageSalary

USE Geography
GO
------12. Highest Peaks in Bulgaria

SELECT c.CountryCode, m.MountainRange, p.PeakName,p.Elevation
	FROM Countries c
	JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
	JOIN Mountains m ON m.Id = mc.MountainId
	JOIN Peaks p ON p.MountainId =m.Id
	WHERE c.CountryName = 'Bulgaria'  AND p.Elevation > 2835
	ORDER BY p.Elevation DESC


-----13. Count Mountain Ranges

SELECT c.CountryCode,COUNT(mc.MountainID) AS MountainRanges
	FROM Countries c
	JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
	WHERE c.CountryName IN ('Bulgaria','Russia','United States')
	GROUP BY c.CountryCode


----- 14. Countries with Rivers
SELECT TOP(5) c.CountryName,r.RiverName
	FROM Countries c
	LEFT JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers r ON r.Id = cr.RiverId
	LEFT JOIN Continents cc ON c.ContinentCode = cc.ContinentCode
	WHERE cc.ContinentName = 'Africa' 
	ORDER BY c.CountryName


 ----- 15. *Continents and Currencies
 /*Find all continents and their most used currency.
 Filter any currency that is used in only one country.
 Sort your results by ContinentCode. */
SELECT cs.ContinentCode,cs.CurrencyCode, cs.CurrencyUsage
FROM
	(SELECT cc.ContinentCode, c.CurrencyCode,
	COUNT(c.CurrencyCode) AS CurrencyUsage,
	RANK() OVER(PARTITION BY cc.ContinentCode ORDER BY COUNT(c.CurrencyCode)  DESC) AS RANK_VAL
	FROM Continents cc
	LEFT JOIN Countries c ON cc.ContinentCode = c.ContinentCode
	GROUP BY c.CurrencyCode,cc.ContinentCode 
	HAVING COUNT(c.CurrencyCode) > 1) AS cs
WHERE (RANK_VAL = 1)
ORDER BY ContinentCode

------ 16. Countries Without Any Mountains
 SELECT COUNT(c.CountryCode) AS [Count]
	FROM Countries c
	LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	WHERE mc.MountainId IS NULL


 ----- 17. Highest Peak and Longest River by Country

 SELECT TOP(5) c.CountryName , MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength
	 FROM Countries c
	 LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
	 LEFT JOIN Mountains m ON m.Id = mc.MountainId
	 LEFT JOIN Peaks p ON p.MountainId = m.Id

	 LEFT JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	 LEFT JOIN Rivers r ON r.Id = cr.RiverId
	 GROUP BY c.CountryName 
	 ORDER BY HighestPeakElevation DESC,LongestRiverLength DESC, c.CountryName



 ------- 18. Highest Peak Name and Elevation by Country

 SELECT TOP(5) pr.CountryName AS Country, 
       ISNULL(pr.PeakName,'(no highest peak)') AS [Highest Peak Name],
       ISNULL(pr.Elevation,0) AS [Highest Peak Elevation],
       ISNULL(pr.MountainRange,'(no mountain)')
 FROM(
    SELECT c.CountryName, 
	       p.PeakName,
		   p.Elevation,
		   m.MountainRange,
           RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS PeakRank
      FROM Countries c
 LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
 LEFT JOIN Mountains m ON m.Id = mc.MountainId
 LEFT JOIN Peaks p ON p.MountainId = m.Id
 ) AS pr
 WHERE PeakRank = 1
 ORDER BY pr.CountryName, pr.PeakName
 
 