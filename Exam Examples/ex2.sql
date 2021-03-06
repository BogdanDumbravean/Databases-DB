
CREATE TABLE Customers(
	CID INT PRIMARY KEY,
	CName VARCHAR(50),
	DoB DATE)

CREATE TABLE BankAccs(
	BID INT PRIMARY KEY,
	IBAN INT,
	Balance INT,
	CID INT REFERENCES Customers(CID))

CREATE TABLE Cards(
	CID INT PRIMARY KEY,
	NR INT,
	CVV INT,
	BID INT REFERENCES BankAccs(BID))

CREATE TABLE ATMs(
	AID INT PRIMARY KEY,
	Addr VARCHAR(200))

CREATE TABLE Transactions(
	TID INT PRIMARY KEY,
	AID INT REFERENCES ATMs(AID),
	CID INT REFERENCES Cards(CID),
	TSUM INT,
	DTime DATETIME)


GO
CREATE OR ALTER PROCEDURE uspRemoveTransactions (@cnr INT) AS
	DECLARE @cid INT = (SELECT CID FROM Cards WHERE NR = @cnr)

	DELETE FROM Transactions
	WHERE TID IN 
		(SELECT T.TID 
		FROM Transactions T
		WHERE T.CID = @cid)
GO

EXEC uspRemoveTransactions 1234567

GO
CREATE OR ALTER VIEW vCardsAtAllATMs AS
	SELECT NR
	FROM Cards C
	WHERE NOT EXISTS
		(SELECT A.AID
		FROM ATMs A
		EXCEPT 
		SELECT T.AID
		FROM Transactions T
		WHERE T.CID=C.CID)
GO
SELECT * FROM vCardsAtAllATMs

GO
CREATE OR ALTER FUNCTION CardsTotalSum ()
RETURNS TABLE
RETURN 
	SELECT C.NR, C.CVV
	FROM Cards C
	WHERE 2000 <
		(SELECT SUM(TSUM)
		FROM Transactions T
		WHERE T.CID = C.CID)
GO

SELECT * FROM CardsTotalSum()

INSERT Customers VALUES (1, 'Alex', '1999-1-1')
INSERT BankAccs VALUES (1, 123456789, 1000, 1)
INSERT Cards VALUES (1, 1234567, 567, 1)
INSERT Cards VALUES (2, 234567, 567, 1)
INSERT ATMs VALUES (2, 'str a, nr 2')
INSERT Transactions VALUES (4, 1, 1, 1990, '2020-1-1 15:10')

SELECT * FROM Customers
SELECT * FROM BankAccs
SELECT * FROM Cards
SELECT * FROM ATMs
SELECT * FROM Transactions