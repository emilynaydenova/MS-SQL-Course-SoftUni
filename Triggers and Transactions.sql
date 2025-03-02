
-- Problem 1.	Create Table Logs using TRIGGER

USE Bank
GO

CREATE TABLE Logs 
 (LogId INT PRIMARY KEY IDENTITY,
  AccountId INT FOREIGN KEY REFERENCES Accounts(Id) ,
  OldSum DECIMAL(18,2),
  NewSum DECIMAL(18,2)
  );

GO
CREATE TRIGGER tr_Accounts ON Accounts FOR UPDATE
	AS
		DECLARE @newSum DECIMAL(18,2) = (SELECT Balance FROM inserted)
		DECLARE @oldSum DECIMAL(18,2) = (SELECT Balance FROM deleted)
		DECLARE @accountID INT = (SELECT id FROM inserted)

		INSERT INTO Logs(AccountID, OldSum, NewSum)
		VALUES (@accountID,@oldSum,@newSum)


 --SELECT * FROM inserted 
 --SELECT * FROM deleted
  
UPDATE Accounts
SET Balance+=100
WHERE id = 1
   
SELECT * FROM Accounts
	WHERE id = 1

SELECT * FROM Logs
GO

-- Problem 2.	Create Table Emails

USE BANK
GO

CREATE TABLE NotificationEmails
(
Id INT PRIMARY KEY IDENTITY,
Recipient INT FOREIGN KEY REFERENCES Accounts(Id), 
[Subject] VARCHAR(50),
Body VARCHAR(MAX)
 )

 GO
 ---- !!!! FOR INSERT !!!!------------
CREATE TRIGGER tr_LogEmail ON Logs FOR INSERT  
 AS
   DECLARE @accountID INT = (SELECT AccountID FROM inserted)
   DECLARE @newsum DECIMAL(18,2) = (SELECT NewSum FROM inserted)
   DECLARE @oldsum DECIMAL(18,2) = (SELECT OldSum FROM inserted)
  
   INSERT INTO NotificationEmails (Recipient,Subject,Body)
     VALUES (
	  @accountID,
	  CONCAT('Balance change for account: ', @accountID),
	  CONCAT('On ',GETDATE(),' your balance was changed from',@oldsum,' to ',@newsum)
    	 )

		 ---check result-----
  UPDATE Accounts
  SET Balance -=100
  WHERE id = 1
   
   SELECT * FROM Accounts
      WHERE id = 1

   SELECT * FROM Logs

 SELECT * FROM NotificationEmails 

 -- 3.	Deposit Money
 
 USE Bank
 GO

CREATE PROC usp_DepositMoney (@accountId INT,  @MoneyAmount DECIMAL(18,4))
	AS
	BEGIN TRANSACTION
		DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id=@accountID)
		 IF (@account IS NULL)
		  BEGIN
			ROLLBACK;
			RAISERROR('Invalid account!', 16, 1)
			RETURN
		  END
		 IF (@MoneyAmount < 0)
		  BEGIN
			ROLLBACK;
			RAISERROR('Negative Amount', 16, 1)
		  RETURN
		 END

		 UPDATE Accounts 
			SET Balance += @MoneyAmount
			WHERE Id = @accountId
		COMMIT
-----
SELECT * FROM Accounts
WHERE AccountHolderId = 1

EXEC usp_DepositMoney 1, 10.3456
GO
--4.	Withdraw Money Procedure
 
USE Bank
GO

CREATE PROC usp_WithdrawMoney  @accountId INT,  @MoneyAmount DECIMAL(18,4)
AS
	BEGIN TRANSACTION
    	 DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id=@accountID)
	     DECLARE @balance DEC(18,4) = (SELECT Balance FROM Accounts WHERE Id=@accountID)
		 IF (@account IS NULL)
		  BEGIN
		   ROLLBACK;
		   RAISERROR('Invalid account!', 16, 1)
		   RETURN
		  END
		 IF (@MoneyAmount < 0)
		  BEGIN
		   ROLLBACK;
		   RAISERROR('Negative Amount', 16, 1)
		   RETURN
		  END

		  IF (@balance- @MoneyAmount < 0)
		  BEGIN
		   ROLLBACK;
		   RAISERROR('Not enough funds', 16, 1)
		   RETURN
		  END

		 UPDATE Accounts 
			SET Balance -= @MoneyAmount
			WHERE Id = @accountId
		COMMIT;

SELECT * FROM Accounts
WHERE id=1

EXEC usp_WithdrawMoney 1,23

-- 5.	Money Transfer
GO 

CREATE PROC usp_TransferMoney
(@SenderId INT , @ReceiverId INT , @Amount  DECIMAL(18,4))
	AS
	  BEGIN TRANSACTION
		DECLARE @SenderAccount INT = (SELECT Id FROM Accounts WHERE Id=@SenderID)
		DECLARE @ReceiverAccount INT = (SELECT Id FROM Accounts WHERE Id=@ReceiverID)
		DECLARE @balanceS DEC(18,4) = (SELECT Balance FROM Accounts WHERE Id=@SenderID)
		DECLARE @balanceR DEC(18,4) = (SELECT Balance FROM Accounts WHERE Id=@ReceiverID)

		IF (@SenderAccount IS NULL)
		  BEGIN
		   ROLLBACK
		   RAISERROR('Invalid Sender account!', 16, 1)
		   RETURN
		  END

		IF (@ReceiverAccount IS NULL)
		  BEGIN
		   ROLLBACK
		   RAISERROR('Invalid Receiver account!', 16, 1)
		   RETURN
		  END

		 IF (@Amount < 0)
		  BEGIN
		   ROLLBACK
		   RAISERROR('Negative Amount', 16, 1)
		   RETURN
		  END

		IF (@balanceS - @Amount < 0)
		  BEGIN
		   ROLLBACK
		   RAISERROR('Not enough Sender_s funds', 16, 1)
		   RETURN
		  END

		 UPDATE Accounts 
		   SET Balance -= @Amount
		 WHERE Id = @SenderId
		  UPDATE Accounts 
		   SET Balance += @Amount
		 WHERE Id = @ReceiverId

		COMMIT;

SELECT * FROM Accounts

EXEC usp_TransferMoney 5,1,25

-- 6.	Trigger
GO
USE Diablo
GO

-- SELECT u.UserName,g.[Name],ug.[Level],ug.Cash,i.[Name] AS [Item Name]
SELECT *
	FROM Users AS u
    JOIN UsersGames AS ug ON ug.Id=u.ID

SELECT * FROM Items;
GO
 CREATE TRIGGER tr_RestrictItems ON UserGameItems 
	INSTEAD OF INSERT
	AS
		 DECLARE @itemID INT = (SELECT ItemID FROM inserted)
		 DECLARE @userGameID INT = (SELECT UserGameID FROM inserted)
		 DECLARE @ItemLevel INT = (SELECT MinLevel FROM Items WHERE Id=@ItemId)
		 DECLARE @userGameLevel INT = (SELECT [Level] FROM UsersGames WHERE Id=@userGameId)

		 IF(@userGameLevel >= @ItemLevel)
		 BEGIN
			INSERT INTO UserGameItems (ItemID,UserGameID) 
			  VALUES (@itemID,@userGameID)
		 END
		 GO

 SELECT *  FROM Users AS u
 JOIN UsersGames AS ug ON ug.Id=u.ID
 JOIN Games AS g ON g.ID=ug.GameID
   WHERE u.UserName IN ('baleremuda', 'loosenoise', 'inguinalself','buildingdeltoid', 'monoxidecos')

   WHERE g.[Name] = 'Bali' AND u.UserName IN ('baleremuda', 'loosenoise', 'inguinalself','buildingdeltoid', 'monoxidecos')

 JOIN UserGameItems AS ugi ON ug.ID=ugi.UserGameID
 JOIN Items As i ON ugi.ItemId=i.id
  WHERE g.[Name] = 'Bali'
  ORDER BY u.UserName,i.[Name]


CREATE TRIGGER tr_UserGameItems_LevelRestriction ON UserGameItems
INSTEAD OF UPDATE
AS
BEGIN
    IF (
             (SELECT [Level] FROM UsersGames
               WHERE Id =(SELECT UserGameId FROM inserted)
			  ) <
               (SELECT MinLevel FROM Items  
			    WHERE Id =(SELECT ItemId FROM inserted)
              )
             )
             BEGIN
                 RAISERROR('Your current level is not enough', 16, 1)
				 RETURN
              END;

         INSERT INTO UserGameItems
         VALUES( (SELECT ItemId FROM inserted),(SELECT UserGameId FROM inserted));
     END;
	 
UPDATE ug
   SET ug.Cash += 50000
   FROM UsersGames ug
       JOIN Users AS u ON ug.UserID=u.Id
       JOIN Games AS g ON ug.GameID= g.Id
   WHERE g.[Name] = 'Bali' AND u.UserName IN ('baleremuda', 'loosenoise', 'inguinalself','buildingdeltoid', 'monoxidecos')
       

SELECT ug.Cash FROM UsersGames AS ug
JOIN Users AS u ON ug.UserID=u.Id
JOIN Games AS g ON ug.GameID= g.Id
WHERE g.[Name] = 'Bali' AND u.UserName IN ('baleremuda', 'loosenoise', 'inguinalself','buildingdeltoid', 'monoxidecos')

  UPDATE a
   SET a.[updated_column] = updatevalue
  FROM articles a
       JOIN classification c
         ON a.articleID = c.articleID
 WHERE c.classID = 1

 -- 7.	*Massive Shopping

USE DIABLO
GO

DECLARE @UserName VARCHAR(50) = 'Stamat'
DECLARE @GameName VARCHAR(50) = 'Safflower'
DECLARE @UserID int = (SELECT Id FROM Users WHERE Username = @UserName)
DECLARE @GameID int = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney money = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
DECLARE @ItemsTotalPrice money
DECLARE @UserGameID int = (SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name]

GO
-- 8.	Employees with Three Projects
USE SoftUni
GO
CREATE PROC usp_AssignProject(@employeeID INT, @projectID INT)
AS
 BEGIN
     DECLARE @maxEmployeeProjectsCount INT = 3
     DECLARE @employeeProjectsCount INT
	 SET @employeeProjectsCount =
          (SELECT COUNT(*) 
				FROM EmployeesProjects AS ep
				WHERE ep.EmployeeId = @employeeID)
	 --
	 BEGIN TRANSACTION
	    INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
           VALUES (@employeeID, @projectID)
		  IF(@employeeProjectsCount >= @maxEmployeeProjectsCount)
			BEGIN
				 RAISERROR('The employee has too many projects!', 16, 1)
				 ROLLBACK;
			 END;
		 ELSE
			COMMIT
		END
 GO
 ---9.	Delete Employees
 USE SoftUni
 GO

 -- DROP TABLE Deleted_Employees
 CREATE TABLE Deleted_Employees
 (
 EmployeeId int PRIMARY KEY IDENTITY,
 FirstName varchar,
 LastName varchar,
 MiddleName varchar,
 JobTitle varchar,
 DepartmentId int,
 Salary DECIMAL(18,2)
 ) 
 GO
 CREATE TRIGGER tr_DeletedEmployees ON Employees FOR DELETE
	AS
     INSERT INTO Deleted_Employees
     (FirstName, 
      LastName, 
      MiddleName, 
      JobTitle, 
      DepartmentId, 
      Salary
     )
            SELECT FirstName, 
                   LastName, 
                   MiddleName, 
                   JobTitle, 
                   DepartmentId, 
                   Salary
            FROM deleted;


SELECT * FROM Employees
DELETE FROM Employees
WHERE EmployeeID = 13


SELECT * FROM Deleted_Employees 




-----------------------------------

----!!!----ERROR MESSAGES---------TRY... CATCH--------

BEGIN TRY 
   SELECT 1/0
END TRY
  ----ако възникне грешка влиза в CATCH ---
BEGIN CATCH
	  SELECT
		  ERROR_NUMBER() AS ErrorNumber,
		  ERROR_SEVERITY() AS ErrorSeverity,
		  ERROR_STATE() AS ErrorState,
		  ERROR_PROCEDURE() AS ErrorProcedure,
		  ERROR_LINE() AS ErrorLine,
		  ERROR_MESSAGE() AS ErrorMessage
	   END CATCH;
GO
USE Bank
GO

-------TRANSACTION SYNTAX-----------------

CREATE PROC usp_Withdraw @withdrawAmount DECIMAL(18,2), @accountId INT
AS
BEGIN TRANSACTION
	UPDATE Accounts 
	SET Balance = Balance - @withdrawAmount
	WHERE Id = @accountId;

	IF @@ROWCOUNT <> 1 -- Didn’t affect exactly one row
	BEGIN
        ROLLBACK;
        RAISERROR('Invalid account!', 16, 1);
		RETURN
	 END
	COMMIT;

GO
-------------TRIGGERS--------------
USE SoftUni
GO

--------- AFTER TRIGGER---------------
CREATE TRIGGER tr_TownsUpdate ON Towns FOR UPDATE
AS
  IF (EXISTS(
        SELECT * FROM inserted  ---- временна таблица inserted
        WHERE Name IS NULL OR LEN(Name) = 0))
  BEGIN
    RAISERROR('Town name cannot be empty.', 16, 1)
    ROLLBACK
    RETURN
  END
  GO

UPDATE Towns SET Name='' WHERE TownId=1

-------- INSTEAD OF DELETE TRIGGER ---------------------------

CREATE TABLE Accounts(
  Username varchar(10) NOT NULL PRIMARY KEY,
  [Password] varchar(20) NOT NULL,
  Active char(1) NOT NULL DEFAULT 'Y'
         )
GO

CREATE TRIGGER tr_AccountsDelete ON Accounts
	INSTEAD OF DELETE
	AS
		UPDATE a SET Active = 'N'
		  FROM Accounts AS a JOIN DELETED d 
			ON d.Username = a.Username
		 WHERE a.Active = 'Y'  
 GO
 