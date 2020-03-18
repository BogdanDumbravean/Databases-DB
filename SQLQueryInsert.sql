INSERT INTO Company VALUES (101, 'Apple', 243, 2000, 9000)
INSERT INTO Company VALUES (102, 'Google', 1260, 1000, 20000)
INSERT INTO Company VALUES (103, 'Amazon', 1780, 1500, 18000)
INSERT INTO Company VALUES (104, 'Amazon', 140, 10500, 15000)
INSERT INTO Company VALUES (105, 'Tesla', 303, 1500, 18000)
INSERT INTO Company VALUES (106, 'B''z Games', 130, 4200, 10000)

INSERT INTO InvestingPlatform VALUES (11, 'eToro')
INSERT INTO InvestingPlatform VALUES (12, 'eToro')

INSERT INTO Portofolio VALUES (1001, 11, 1)
INSERT INTO Portofolio VALUES (1002, 11, 0)
INSERT INTO Portofolio VALUES (1003, 12, 1)
INSERT INTO Portofolio VALUES (1004, 12, 0)
--INSERT INTO Portofolio VALUES (1005, 11, 2)

INSERT INTO Investor VALUES (1010, 1001, 'Bogdan', 'Dumbravean', 20)
INSERT INTO Investor VALUES (1020, 1002, 'Ilie', 'Popescu', 25)
INSERT INTO Investor VALUES (1030, 1003, 'Iustin', 'Ionescu', 27)
INSERT INTO Investor VALUES (1050, 1004, 'Alex', 'Alexandrescu', 19)
INSERT INTO Investor(iid, FName, Age) VALUES (1013, 'Bogdan', 31)

INSERT INTO Watchlist VALUES (1, 11, 1)
INSERT INTO Watchlist VALUES (2, 12, 0)

INSERT INTO InvestorWatchlist VALUES (1010, 1)
INSERT INTO InvestorWatchlist VALUES (1010, 2)
INSERT INTO InvestorWatchlist VALUES (1020, 1)
INSERT INTO InvestorWatchlist VALUES (1030, 2)

INSERT INTO CompanyWatchlist VALUES (101, 1, 1000)
INSERT INTO CompanyWatchlist VALUES (102, 1, 500)
INSERT INTO CompanyWatchlist VALUES (101, 2, 700)
INSERT INTO CompanyWatchlist VALUES (103, 2, 2000)
INSERT INTO CompanyWatchlist VALUES (105, 2, 1200)

INSERT INTO PortofolioCompany VALUES (1001, 101, 100)
INSERT INTO PortofolioCompany VALUES (1002, 101, 50)
INSERT INTO PortofolioCompany VALUES (1001, 102, 7)
INSERT INTO PortofolioCompany VALUES (1003, 103, 20)
INSERT INTO PortofolioCompany VALUES (1002, 105, 12)
INSERT INTO PortofolioCompany VALUES (1004, 101, 1000)

DELETE FROM Company
WHERE CName='Amazon' AND SharePrice < 1000
DELETE FROM Investor
WHERE LName IS NULL

UPDATE InvestingPlatform
SET PlatformName='Robinhood'
WHERE pid=11
UPDATE Company
SET NetWorth=13000
WHERE SharePrice BETWEEN 100 AND 500
UPDATE Investor
SET FName='Ion'
WHERE FName LIKE 'I%'
UPDATE Investor
SET Age=25
WHERE LName IN ('Ionescu', 'Popescu')


SELECT *
FROM Company
SELECT *
FROM InvestingPlatform
SELECT *
FROM Investor
SELECT *
FROM Portofolio
SELECT *
FROM Watchlist
SELECT *
FROM InvestorWatchlist
SELECT *
FROM CompanyWatchlist
SELECT *
FROM PortofolioCompany