CREATE TABLE TrainTypes(
	TTID INT PRIMARY KEY,
	Descr VARCHAR(500))

CREATE TABLE Trains(
	TID INT PRIMARY KEY,
	TName VARCHAR(50),
	TType INT REFERENCES TrainTypes(TTID))

CREATE TABLE Stations(
	SID INT PRIMARY KEY,
	SName VARCHAR(50) UNIQUE)

CREATE TABLE Routes(
	RID INT PRIMARY KEY,
	RName VARCHAR(50) UNIQUE,
	TID INT REFERENCES Trains(TID))

CREATE TABLE RoutesStations(
	RID INT REFERENCES Routes(RID),
	SID INT REFERENCES Stations(SID),
	ArrTime TIME,
	DepTime TIME,
	PRIMARY KEY(RID, SID))



GO
CREATE PROCEDURE uspAddStation (@route varchar(50), @station varchar(50), @arr time, @dep time) AS
	DECLARE @rid INT = (SELECT RID FROM Routes WHERE RName=@route)
	DECLARE @sid INT = (SELECT SID FROM Stations WHERE SName=@station)

	IF EXISTS (SELECT * FROM RoutesStations WHERE RID=@rid AND SID=@sid)
		UPDATE RoutesStations
		SET ArrTime=@arr, DepTime=@dep
		WHERE RID=@rid AND SID=@sid
	ELSE
		INSERT RoutesStations(RID, SID, ArrTime, DepTime) VALUES (@rid, @sid, @arr, @dep)
GO

INSERT Stations VALUES(1, '1')
INSERT Stations VALUES(2, '2')
INSERT Stations VALUES(3, '3')
INSERT Routes VALUES(1, '1', 1)
INSERT Routes VALUES(2, '2', 2)
INSERT Routes VALUES(3, '3', 3)

EXEC uspAddStation '1', '1', '14:10', '14:20'
EXEC uspAddStation '1', '2', '12:10', '12:20'
EXEC uspAddStation '1', '3', '13:10', '13:20'
EXEC uspAddStation '2', '2', '12:10', '12:30'

GO
CREATE OR ALTER VIEW vNames AS
	SELECT RName
	FROM Routes R JOIN RoutesStations RS ON R.RID=RS.RID
		JOIN Stations S ON RS.SID=S.SID
	GROUP BY RName
	HAVING COUNT(*) = (SELECT COUNT(*) FROM Routes)
GO

SELECT * FROM vNames

GO
CREATE FUNCTION ListNames(@R INT) 
RETURNS TABLE
RETURN
	SELECT SName
	FROM Stations S 
	WHERE @R < 
		(SELECT COUNT (*)
		FROM RoutesStations RS
		WHERE RS.SID = S.SID)

GO

SELECT * FROM ListNames(1)

SELECT * FROM TrainTypes
SELECT * FROM Trains
SELECT * FROM Stations
SELECT * FROM Routes
SELECT * FROM RoutesStations