
CREATE TABLE Ta
	(aid INT PRIMARY KEY IDENTITY(1,1),
	a2 INT UNIQUE,
	a3 INT)

CREATE TABLE Tb
	(bid INT PRIMARY KEY IDENTITY(1,1),
	b2 INT,
	b4 INT,
	b5 INT)

DROP TABLE Tb
CREATE TABLE Tc
	(cid INT PRIMARY KEY IDENTITY(1,1),
	aid INT REFERENCES Ta(aid),
	bid INT REFERENCES Tb(bid))


-- cl seek
SELECT * 
FROM Tc
WHERE aid = 10
-- cl scan
SELECT * 
FROM Ta
WHERE a3 = 'a'
-- ncl index scan
SELECT a2
FROM Ta
ORDER BY a2
-- ncl index seek + key lookup
SELECT * 
FROM Ta
WHERE a2=20


DECLARE @C INT = 0
WHILE @C < 1000
BEGIN
	INSERT INTO Tc
	VALUES (FLOOR(RAND()*(1000)), FLOOR(RAND()*(1000)))
	SET @C = @C + 1
END

SELECT * FROM Tc

SELECT b2
FROM Tb
WHERE b2 = 5

DROP INDEX IDX_Nc_b2 ON Tb
CREATE NONCLUSTERED INDEX IDX_Nc_b2 ON Tb(b2)




GO
CREATE OR ALTER VIEW vJoinTaTb AS
	SELECT A.aid, A.a2, C.cid
	FROM Tc C INNER JOIN Ta A ON A.aid = C.aid
	WHERE A.a3 = 10
GO

SELECT * FROM vJoinTaTb

select * from ta where a3 = 'a'




sp_helpindex Ta
EXEC sp_helpindex Tc


SELECT A.aid, A.a2, C.cid
FROM Tc C INNER JOIN Ta A ON A.aid = C.aid
WHERE A.a3 = 10

CREATE NONCLUSTERED INDEX IDX_NC_I ON Ta(a3) INCLUDE(a2)

DROP INDEX IDX_NC_I  ON Ta