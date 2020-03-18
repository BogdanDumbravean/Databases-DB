CREATE TABLE CrtVersion (v INT);
INSERT CrtVersion VALUES(0);
UPDATE CrtVersion SET v = 5

-----------------------------OPERATIONS

GO
CREATE OR ALTER PROCEDURE uspAddProfitToInvestor
AS
  ALTER TABLE Investor
  ADD Profit INT
GO
CREATE OR ALTER PROCEDURE uspRemoveProfitFromInvestor
AS
  ALTER TABLE Investor
  DROP COLUMN Profit
GO


GO
CREATE OR ALTER PROCEDURE uspModifyInvestorAgeToString
AS
  ALTER TABLE Investor
  ALTER COLUMN Age VARCHAR(50)
GO
CREATE OR ALTER PROCEDURE uspModifyInvestorAgeToInt
AS
  ALTER TABLE Investor
  ALTER COLUMN Age INT
GO


GO
CREATE OR ALTER PROCEDURE uspAddInvestorDfAge
AS
  ALTER TABLE Investor
  ADD CONSTRAINT df_Age
  DEFAULT '18' FOR Age;
GO
CREATE OR ALTER PROCEDURE uspRemoveInvestorDfAge
AS
  ALTER TABLE Investor
  DROP CONSTRAINT df_Age;
GO


GO
CREATE OR ALTER PROCEDURE uspAddAnalysisPrimaryKey
AS
  ALTER TABLE Analysis
  DROP CONSTRAINT OldPKey

  ALTER TABLE Analysis
  ADD pkey INT IDENTITY; -- add new id for key

  ALTER TABLE Analysis
  ADD CONSTRAINT NewPKey
  PRIMARY KEY(aid,pkey);
GO
CREATE OR ALTER PROCEDURE uspRemoveAnalysisPrimaryKey
AS
  ALTER TABLE Analysis
  DROP CONSTRAINT NewPKey

  ALTER TABLE Analysis
  DROP COLUMN pkey

  ALTER TABLE Analysis
  ADD CONSTRAINT OldPKey
  PRIMARY KEY(aid);
GO
--EXEC uspRemoveAnalysisPrimaryKey
--select OBJECT_NAME(OBJECT_ID) AS NameofConstraint
--FROM sys.objects
--where OBJECT_NAME(parent_object_id)='Analysis'
--and type_desc LIKE '%CONSTRAINT'


GO
CREATE OR ALTER PROCEDURE uspAddAnalysisUniqueKey
AS
  ALTER TABLE Analysis
  ADD ukey INT;

  ALTER TABLE Analysis
  ADD CONSTRAINT NewUKey UNIQUE (ukey);
GO
CREATE OR ALTER PROCEDURE uspRemoveAnalysisUniqueKey
AS
  ALTER TABLE Analysis
  DROP CONSTRAINT NewUKey

  ALTER TABLE Analysis
  DROP COLUMN ukey
GO


GO
CREATE OR ALTER PROCEDURE uspAddAnalysisForeignKey
AS
  ALTER TABLE Analysis ADD iid INT NOT NULL;
  ALTER TABLE Analysis ADD CONSTRAINT FKey FOREIGN KEY (iid) REFERENCES Investor(iid);
GO
CREATE OR ALTER PROCEDURE uspRemoveAnalysisForeignKey
AS
  ALTER TABLE Analysis
  DROP CONSTRAINT FKey

  ALTER TABLE Analysis
  DROP COLUMN iid
GO


GO
CREATE OR ALTER PROCEDURE uspAddAnalystTable
AS
  CREATE TABLE Analyst (aid INT PRIMARY KEY IDENTITY, AName VARCHAR(50), Popularity INT)
GO
CREATE OR ALTER PROCEDURE uspRemoveAnalystTable
AS
  DROP TABLE Analyst
GO

-----------------------------VERSIONS

CREATE TABLE Versions(SPName VARCHAR(100), RSPName VARCHAR(100), TVers INT)
INSERT Versions VALUES ('uspModifyInvestorAgeToString', 'uspModifyInvestorAgeToInt', 1)
INSERT Versions VALUES ('uspAddProfitToInvestor', 'uspRemoveProfitFromInvestor', 2)
INSERT Versions VALUES ('uspAddInvestorDfAge', 'uspRemoveInvestorDfAge', 3)
INSERT Versions VALUES ('uspAddAnalysisPrimaryKey', 'uspRemoveAnalysisPrimaryKey', 4)
INSERT Versions VALUES ('uspAddAnalysisUniqueKey', 'uspRemoveAnalysisUniqueKey', 5)
INSERT Versions VALUES ('uspAddAnalysisForeignKey', 'uspRemoveAnalysisForeignKey', 6)
INSERT Versions VALUES ('uspAddAnalystTable', 'uspRemoveAnalystTable', 7)

--DROP PROC VersionManagement 

GO
CREATE OR ALTER PROCEDURE uspVersionManagement (@TVers INT)
AS
	DECLARE @SPName VARCHAR(100)
	DECLARE @RSPName VARCHAR(100)
	DECLARE @CVers INT
	DECLARE @CrtVers INT
	SELECT @CrtVers = v FROM CrtVersion

	IF @CrtVers<@TVers
		DECLARE myCursor CURSOR FOR
		  SELECT * FROM Versions
		  ORDER BY TVers ASC
	ELSE
		DECLARE myCursor CURSOR FOR
		  SELECT * FROM Versions
		  ORDER BY TVers DESC

	OPEN myCursor
	FETCH NEXT FROM myCursor INTO @SPName, @RSPName, @CVers 

	IF @CrtVers != 0		-- Get with the cursor to the next version (asc or desc)
	BEGIN
		WHILE @@FETCH_STATUS = 0 AND (@CVers != @CrtVers)	
		BEGIN
			FETCH NEXT FROM myCursor INTO @SPName, @RSPName, @CVers
		END
		IF @CrtVers<@TVers
			FETCH NEXT FROM myCursor INTO @SPName, @RSPName, @CVers
	END

	-- Go up or down in the table to get to target version
	WHILE @@FETCH_STATUS = 0 AND (@CrtVers != @TVers)
	BEGIN
		IF @CrtVers<@TVers
		BEGIN
			EXEC(@SPName)
			SET @CrtVers = @CrtVers+1
		END
		ELSE
		BEGIN
			EXEC(@RSPName)
			SET @CrtVers = @CrtVers-1
		END

		UPDATE CrtVersion SET v = @CrtVers
		FETCH NEXT FROM myCursor INTO @SPName, @RSPName, @CVers
	END
	
	CLOSE myCursor
	DEALLOCATE myCursor
GO


--------------------------------- EXECUTE

EXEC uspVersionManagement @TVers=0

exec sp_help Investor
exec sp_help Analysis

SELECT * FROM Analyst

ALTER TABLE Analysis
DROP CONSTRAINT DF__Analysis__iid__7D4E87B5

SELECT * FROM CrtVersion
SELECT * FROM Versions
SELECT * FROM Investor
SELECT * FROM Analysis

ALTER TABLE Analysis
DROP COLUMN cid 

SELECT * FROM Analyst