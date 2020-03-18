CREATE TABLE ChampionshipCategories(
	CCID INT PRIMARY KEY,
	CName VARCHAR(50))

CREATE TABLE Championships(
	CID INT PRIMARY KEY,
	CName VARCHAR(50),
	CCID INT REFERENCES ChampionshipCategories(CCID))

CREATE TABLE Affiliations(
	AID INT PRIMARY KEY,
	AName VARCHAR(50),
	Descr VARCHAR(50))

CREATE TABLE Gymnasts(
	GID INT PRIMARY KEY,
	LName VARCHAR(50),
	FNAME VARCHAR(50),
	DoB DATE,
	AID INT REFERENCES Affiliations(AID))

CREATE TABLE GymChamp(
	GID INT REFERENCES Gymnasts(GID),
	CID INT REFERENCES Championships(CID),
	NrMedals INT)
	
GO
CREATE OR ALTER PROCEDURE uspAddGymnastToChampionship (@cname varchar(50), @fname varchar(50), @lname varchar(50), @n int) AS
	DECLARE @cid INT = (SELECT CID FROM Championships WHERE CName=@cname)
	DECLARE @gid INT = (SELECT GID FROM Gymnasts WHERE FName=@fname AND LName=@lname)

	IF EXISTS (SELECT * FROM GymChamp WHERE CID=@cid AND GID=@gid)
		UPDATE GymChamp
		SET NrMedals=@n
		WHERE CID=@cid AND GID=@gid
	ELSE
		INSERT GymChamp(CID, GID, NrMedals) VALUES (@cid, @gid, @n)
GO

EXEC uspAddGymnastToChampionship 'ufc2', 'Alexandru', 'Popescu', 1

GO
CREATE OR ALTER VIEW vGymnastInAll AS
	SELECT G.LName, G.FName
	FROM Gymnasts G
	WHERE NOT EXISTS
		(SELECT C.CID
		FROM Championships C
		EXCEPT 
		SELECT GC.CID
		FROM GymChamp GC
		WHERE G.GID = GC.GID)
GO

SELECT * FROM vGymnastInAll

GO
CREATE OR ALTER FUNCTION GymnastsWhoWon (@m INT, @c int)
RETURNS TABLE
RETURN
	SELECT G.LName, G.FName
	FROM Gymnasts G
	WHERE @m <= (SELECT SUM(GC.NrMedals) FROM GymChamp GC WHERE GC.GID = G.GID)
		AND @c <= (SELECT COUNT(*) FROM GymChamp GC WHERE GC.GID = G.GID)
GO

SELECT * FROM GymnastsWhoWon(3, 3)

INSERT INTO ChampionshipCategories VALUES(1, 'cat1')
INSERT INTO Championships VALUES(1, 'ufc', 1)
INSERT INTO Championships VALUES(2, 'ufc2', 1)
INSERT INTO Affiliations VALUES(1, 'a1', 'some aff')
INSERT INTO Gymnasts VALUES(1, 'Pop', 'Alex', '1999-1-1', 1)
INSERT INTO Gymnasts VALUES(2, 'Popescu', 'Alexandru', '1990-2-1', 1)

SELECT * FROM ChampionshipCategories
SELECT * FROM Championships
SELECT * FROM GymChamp
SELECT * FROM Gymnasts
SELECT * FROM Affiliations


