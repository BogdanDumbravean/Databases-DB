USE ExamModel
GO

IF OBJECT_ID('RoutesStations', 'U') IS NOT NULL
	DROP TABLE RoutesStations
IF OBJECT_ID('Stations', 'U') IS NOT NULL
	DROP TABLE Stations
IF OBJECT_ID('Routes', 'U') IS NOT NULL
	DROP TABLE Routes
IF OBJECT_ID('Trains', 'U') IS NOT NULL
	DROP TABLE Trains
IF OBJECT_ID('TrainTypes', 'U') IS NOT NULL
	DROP TABLE TrainTypes
GO

CREATE TABLE TrainTypes
	(TTID TINYINT PRIMARY KEY IDENTITY(1,1),
	Description VARCHAR(300))
CREATE TABLE Trains
	(TID SMALLINT PRIMARY KEY IDENTITY(1,1),
	TName VARCHAR(300),
	TTID TINYINT REFERENCES TrainTypes(TTID))
CREATE TABLE Routes
	(RID SMALLINT PRIMARY KEY IDENTITY(1,1),
	RName VARCHAR(100),
	TID SMALLINT REFERENCES Trains(TID))
CREATE TABLE Stations
	(SID SMALLINT PRIMARY KEY IDENTITY(1,1),
	SName VARCHAR(100))
CREATE TABLE RoutesStations
	(RID SMALLINT REFERENCES Routes(RID),
	SID SMALLINT REFERENCES Stations(SID),
	ArrivalTime TIME,
	DepartureTime TIME,
	PRIMARy KEY(RID, SID))
GO


CREATE OR ALTER PROCEDURE uspStationOnRoute (@RName VARCHAR(100), @SName VARCHAR (100), @ArrivalTime TIME, @DepartureTime TIME) 
AS
	DECLARE @RID SMALLINT = (SELECT RID FROM Routes WHERE RName = @RName),
		@SID SMALLINT = (SELECT SID FROM Stations WHERE SName = @SName)

	IF @RID IS NULL OR @SID IS NULL
	BEGIN
		RAISERROR('no such station / route', 16, 1)
		RETURN -1
	END

	IF EXISTS (SELECT * FROM RoutesStations WHERE SID = @SID AND RID = @RID)
		UPDATE RoutesStations
		SET ArrivalTime = @ArrivalTime, DepartureTime = @DepartureTime
		WHERE SID = @SID AND RID = @RID
	ELSE
		INSERT RoutesStations(RID, SID, ArrivalTime, DepartureTime)
		VALUES (@RID, @SID, @ArrivalTime, @DepartureTime)
GO

INSERT TrainTypes VALUES('regio'), ('interregio')
INSERT Trains VALUES('t1', 1), ('t2', 1), ('t3', 1)
INSERT Routes VALUES('r1', 1), ('r2', 2), ('r3', 3)
INSERT Stations VALUES('s1'), ('s2'), ('s3')

SELECT * FROM TrainTypes
SELECT * FROM Trains
SELECT * FROM Routes
SELECT * FROM Stations
SELECT * FROM RoutesStations

EXEC uspStationOnRoute 'r1', 's1', '6:00', '6:10'
EXEC uspStationOnRoute 'r1', 's2', '6:20', '6:30'
EXEC uspStationOnRoute 'r1', 's3', '6:40', '6:50'
EXEC uspStationOnRoute 'r2', 's3', '6:40', '6:50'

GO
CREATE OR ALTER VIEW vRoutesWithAllStations 
AS
	SELECT R.RName
	FROM Routes R
	WHERE NOT EXISTS
		(SELECT S.SID
		FROM Stations S
		EXCEPT
		SELECT RS.SID
		FROM RoutesStations RS
		WHERE RS.RID = R.RID)
GO

SELECT * FROM vRoutesWithAllStations


GO
CREATE OR ALTER FUNCTION ufStationsFilteredByNumOfRoutes (@R INT) 
RETURNS TABLE
RETURN 
	SELECT S.SName
	FROM Stations S
	WHERE S.SID IN 
		(SELECT RS.SID
		FROM RoutesStations RS
		GROUP BY RS.SID
		HAVING COUNT(*) >= @R)
GO

SELECT * FROM RoutesStations

SELECT * 
FROM ufStationsFilteredByNumOfRoutes(3)