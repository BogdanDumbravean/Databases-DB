
------------------------------------------ RUN TESTS

--------------------------TABLES

GO
CREATE OR ALTER PROCEDURE uspDeleteRows (@tid as INT) AS
	-- Variable with tables from @test (and other info)
	DECLARE @TestTs TABLE
	(
	  TableID int, 
	  Pos int,
	  Num int
	)
	INSERT INTO @TestTs (TableID, Pos, Num)
		SELECT TableID, Position, NoOfRows
		FROM TestTables
		WHERE TestID = @tid
		ORDER BY Position ASC

	-- Remove all rows from tables
	DECLARE MyCursor CURSOR FOR
		(SELECT Name FROM Tables WHERE TableID IN (SELECT TableID FROM @TestTs))

	DECLARE @TName VARCHAR(50)
	DECLARE @DeleteStatement VARCHAR(100)
	SET @DeleteStatement = 'DELETE FROM '

	OPEN MyCursor
	FETCH NEXT FROM MyCursor INTO @TName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@DeleteStatement + @TName)
		FETCH NEXT FROM MyCursor INTO @TName
	END
	CLOSE MyCursor
	DEALLOCATE MyCursor


GO
CREATE OR ALTER PROCEDURE uspAddOneRow (@TName AS VARCHAR(50)) AS
	DECLARE @CName VARCHAR(50)
	DECLARE @CType VARCHAR(50)

	DECLARE @Values VARCHAR(200) = ''

	-- Check for keys
	IF (@TName = 'Analysis') 
	BEGIN
		SET @Values = STR(FLOOR(RAND()*(5)) + 101)
	END
	ELSE IF (@TName = 'NewTable')
	BEGIN 
		DECLARE @pid INT = 101
		DECLARE @cid INT = 1
		WHILE (EXISTS (SELECT PKey1, PKey2 FROM NewTable WHERE PKey1 = @pid AND PKey2 = @cid))
		BEGIN
			IF (@cid < 106)
			BEGIN
				SET @cid = @cid + 1
			END
			ELSE 
			BEGIN
				SET @cid = 1
				SET @pid = @pid + 1
			END
		END
		SET @Values = CAST(@pid AS VARCHAR(5)) + ', ' + CAST(@cid AS VARCHAR(5))
	END

	-- Get other values
	OPEN TableCursor
	FETCH NEXT FROM TableCursor INTO @CName, @CType
	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF ((SELECT COUNT(COLUMN_NAME)
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE TABLE_NAME = @TName AND COLUMN_NAME = @CName) = 0)
		BEGIN
			IF (@Values != '')
			BEGIN
				SET @Values = (@Values + ', ')
			END
			IF (@CType = 'int')
			BEGIN
				SET @Values = (@Values + STR(FLOOR(RAND()*(100))))
			END
			ELSE IF (@CType = 'varchar')
			BEGIN
				SET @Values = (@Values + ' '' ' + SUBSTRING(CONVERT(varchar(40), NEWID()),0,9) + ' '' ')
			END
			ELSE IF (@CType = 'bit') 
			BEGIN 
				SET @Values = (@Values + '1')
			END
		END
		FETCH NEXT FROM TableCursor INTO @CName, @CType
	END
	CLOSE TableCursor

	SET @Values = 'INSERT INTO ' + @TName + ' VALUES(' + @Values + ')'
	EXEC (@Values)



GO
CREATE OR ALTER PROCEDURE uspAddRows (@TName AS VARCHAR(50), @Num AS INT, @trid AS INT) AS
	DECLARE @StartTime DATETIME = GETDATE()

	DECLARE @Count INT = 0
	WHILE (@Count < @Num)
	BEGIN
		SET @Count = @Count + 1

		EXEC uspAddOneRow @TName
	END

	INSERT INTO TestRunTables VALUES (@trid, (SELECT TableID FROM TABLES WHERE Name = @TName), @StartTime, GETDATE())


GO
CREATE OR ALTER PROCEDURE uspInsertInTables (@tid AS INT, @trid AS INT) AS
	-- Insert in tables
	DECLARE @TestTs TABLE
	(
	  TableID int, 
	  Pos int,
	  Num int
	)
	INSERT INTO @TestTs (TableID, Pos, Num)
		SELECT TableID, Position, NoOfRows
		FROM TestTables
		WHERE TestID = @tid
		ORDER BY Position DESC

	DECLARE MyCursor CURSOR FOR
		(SELECT T1.Name, T2.Num FROM Tables T1, @TestTs T2 WHERE T1.TableID = T2.TableID)

	OPEN MyCursor
	
	DECLARE @TName VARCHAR(50)
	DECLARE @Num INT
	FETCH NEXT FROM MyCursor INTO @TName, @Num
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE TableCursor CURSOR FOR
			(SELECT c.name, t.name
			FROM sys.objects o INNER JOIN sys.columns c ON o.object_id = c.object_id
				INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
			WHERE o.name = @TName)-- Analysis, PortofolioCompany)

		EXEC uspAddRows @TName, @Num, @trid

		DEALLOCATE TableCursor
		FETCH NEXT FROM MyCursor INTO @TName, @Num

	END
	CLOSE MyCursor
	DEALLOCATE MyCursor


--------------------------VIEWS

GO
CREATE OR ALTER PROCEDURE uspCallViews (@tid AS INT, @trid AS INT) AS
	DECLARE MyCursor CURSOR FOR
		(SELECT ViewID FROM TestViews WHERE TestID = @tid)

	DECLARE @vid INT
	OPEN MyCursor
	FETCH NEXT FROM MyCursor INTO @vid
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @StartTime DATETIME = GETDATE()

		DECLARE @view VARCHAR(50)
		SELECT @view = Name FROM Views WHERE ViewID=@vid
		DECLARE @call VARCHAR(200) = 'SELECT * FROM ' + @view
		PRINT('exec ' + @call)
		EXEC (@call)
		
		INSERT INTO TestRunViews VALUES (@trid, @vid, @StartTime, GETDATE())

		FETCH NEXT FROM MyCursor INTO @vid
	END

	CLOSE MyCursor
	DEALLOCATE MyCursor

--------------------------OTHER STUFF

GO
CREATE OR ALTER PROCEDURE uspExecTest (@test AS VARCHAR(50)) AS
	DECLARE @tid INT
	SELECT @tid=TestID FROM Tests WHERE @test=Name

	-- Remove from tables
	EXEC uspDeleteRows @tid

	-- Get id of TestRuns
	DECLARE @trid INT
	INSERT INTO TestRuns(StartAt) VALUES (GETDATE())
	SELECT @trid=MAX(TestRunID) FROM TestRuns
	PRINT('insert')
	-- Insert in tables
	EXEC uspInsertInTables @tid, @trid
	Print('views')
	-- Call Views
	EXEC uspCallViews @tid, @trid

	-- Update TestRuns with finish time
	UPDATE TestRuns
	SET EndAt = (SELECT EndAt FROM TestRunViews WHERE TestRunID=@trid AND ViewID=(SELECT MAX(ViewID) FROM TestRunViews))
	WHERE TestRunID = @trid
	


EXEC uspCreateTest 'test7','Analyst.1000.1;Analysis.1000.2;NewTable.1000.3','vSelectAnalyst;vAPC;vCountRisingOnPortofolios'
SELECT * FROM (SELECT Name FROM Views WHERE ViewID=4)
EXEC uspExecTest 'test6'

INSERT INTO Analyst
VALUES ('ab', 20)

-- Just some testing selects
SELECT * FROM Tables
SELECT * FROM Views
SELECT * FROM Tests
SELECT * FROM TestTables
SELECT * FROM TestViews

SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews

SELECT * FROM Analyst
SELECT * FROM Analysis
SELECT * FROM NewTable
SELECT * FROM PortofolioCompany
SELECT * FROM Company
SELECT * FROM Portofolio

DELETE FROM TestRuns
WHERE TestID=1

INSERT INTO Company
VALUES (104,'a', 1, 1, 1)