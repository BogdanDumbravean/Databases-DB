-- Inserts
--DELETE FROM Tables
INSERT INTO Tables
SELECT name FROM sys.tables
WHERE name NOT IN
('Tables', 'Tests', 'Views', 'TestTables', 'TestViews', 'TestRuns', 'TestRunTables', 'TestRunViews', 'sysdiagrams', 'CrtVersion', 'Versions')

DELETE FROM Views
INSERT INTO Views
SELECT name FROM sys.views


-- Insert in Tests, TestTables and TestViews
GO
CREATE OR ALTER PROCEDURE uspCreateTest (@name AS VARCHAR(50), @tables AS VARCHAR(200), @views AS VARCHAR(200)) AS
	--INSERT INTO TestTables
	DECLARE @t VARCHAR(200)

	IF NOT EXISTS (SELECT * FROM Tests WHERE Name = @name)
	BEGIN
		INSERT INTO Tests VALUES (@name)
	END

	DECLARE @id INT
	SELECT @id = TestID FROM Tests WHERE Name = @name
		

	--Cursor for tables
	DECLARE myCursor CURSOR FOR
		(SELECT value FROM STRING_SPLIT(@tables, ';'))

	OPEN myCursor
	FETCH NEXT FROM myCursor INTO @t 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @n VARCHAR(50)
		SELECT @n=TableID FROM Tables WHERE Name=Parsename(@t,3)
		INSERT INTO TestTables VALUES (@id, @n,Parsename(@t, 2),Parsename(@t, 1))

		FETCH NEXT FROM myCursor INTO @t
	END

	CLOSE myCursor
	DEALLOCATE myCursor

	--Cursor for views
	DECLARE myCursor CURSOR FOR
		(SELECT value FROM STRING_SPLIT(@views, ';'))

	OPEN myCursor
	FETCH NEXT FROM myCursor INTO @t 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @n=ViewID FROM Views WHERE Name=Parsename(@t,1)
		INSERT INTO TestViews VALUES (@id, @n)

		FETCH NEXT FROM myCursor INTO @t
	END

	CLOSE myCursor
	DEALLOCATE myCursor


--sys.columns
--sys.types

--------------------------------New Table
CREATE TABLE NewTable (
	PKey1 INT,
	PKey2 INT,
	Value1 INT,
	Value2 VARCHAR(10),
	PRIMARY KEY(PKey1, PKey2))
--------------------------------Views

--Analyst Analysis PortofolioCompany

GO
CREATE OR ALTER VIEW vSelectAnalyst AS
	SELECT * FROM Analyst

GO
CREATE OR ALTER VIEW vAPC AS
	SELECT A.aid, A.cid, A.Grade, T.PKey1
	FROM Analysis A INNER JOIN NewTable T ON A.cid=T.PKey1

GO
CREATE OR ALTER VIEW vCountRisingOnPortofolios AS
	SELECT T.PKey1, COUNT(*) AS 'Count'
	FROM Analysis A INNER JOIN NewTable T ON A.cid=T.PKey1
	WHERE A.IsRising=1
	GROUP BY T.PKey1
GO

SELECT * FROM vCountRisingOnPortofolios

--GO
--CREATE OR ALTER VIEW vCompanyTotalSharePrice AS
--SELECT CName, SharesNr*SharePrice AS TotalSharesPrice
--FROM Company
--WHERE SharePrice < 300 OR (SharesNr < 1500 AND SharePrice > 1000)

--GO
--CREATE OR ALTER VIEW vCompanyOnWatchlist AS
--	SELECT CW.wid, CName
--	FROM CompanyWatchlist CW
--	RIGHT JOIN
--	  (SELECT *
--	  FROM Company) C
--	  ON CW.cid = C.cid

--GO
--CREATE OR ALTER VIEW vCompanyMaxShareSum AS
--	SELECT C.CName, SUM(DISTINCT CW.MaxSharesNr) AS ShareTotal
--	FROM CompanyWatchlist CW INNER JOIN Company C ON CW.cid = C.cid
--	WHERE CW.MaxSharesNr>=1000 AND (CW.cid = 101 OR CW.cid = 103)
--	GROUP BY C.CName