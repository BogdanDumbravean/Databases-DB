SELECT *, SharesNr*SharePrice AS TotalSharesPrice
FROM Company
WHERE SharePrice < 300
UNION
SELECT *, SharesNr*SharePrice AS TotalSharesPrice
FROM Company
WHERE SharesNr < 1500 AND SharePrice > 1000

SELECT *, SharesNr*SharePrice AS TotalSharesPrice
FROM Company
WHERE SharePrice < 300 OR (SharesNr < 1500 AND SharePrice > 1000)


SELECT *, NetWorth/SharesNr AS ValuePerShare
FROM Company
WHERE SharePrice < 1500
INTERSECT
SELECT*, NetWorth/SharesNr AS ValuePerShare
FROM Company
WHERE SharesNr < 2000

SELECT *
FROM Company C
WHERE C.SharePrice < 1500 AND C.CID IN 
  (SELECT C2.CID
  FROM Company C2
  WHERE C2.SharesNr < 2000)


SELECT DISTINCT FName
FROM Investor
EXCEPT
SELECT DISTINCT FName
FROM Investor
WHERE Age = 25

SELECT DISTINCT FName
FROM Investor
WHERE Age NOT IN (25)


--------------------------------------------- JOINS

SELECT *
FROM Portofolio P
INNER JOIN 
  (SELECT *
  FROM Investor) t1
  ON P.pid = t1.pid

SELECT C.cid, C.MaxSharesNr, t1.iid, C.wid
FROM CompanyWatchlist C
FULL JOIN
  (SELECT iid, wid
  FROM InvestorWatchlist) t1
  ON C.wid=t1.wid

-- Find for each company the number of shares bought and whether that portofolio is positive (+ company net worth and platform)
SELECT C.Cname, C.NetWorth, PC.SharesNr, P.IsPositive, I.PlatformName
FROM Company C
LEFT JOIN
  (SELECT *
  FROM PortofolioCompany) PC
  ON C.cid=PC.cid
LEFT JOIN
  (SELECT *
  FROM Portofolio) P
  ON PC.pid=P.pid
LEFT JOIN
  (SELECT *
  FROM InvestingPlatform) I
  ON I.pid=P.plid


SELECT CW.wid, CName
FROM CompanyWatchlist CW
RIGHT JOIN
  (SELECT *
  FROM Company) C
  ON CW.cid = C.cid

  --------------------------------------------- IN

SELECT *
FROM Company C
WHERE C.cid IN 
  (SELECT CW.cid
  FROM CompanyWatchlist CW
  WHERE MaxSharesNr >= 1000)

-- Companies from watchlists that cointain foreign companies
SELECT *
FROM Company C
WHERE C.cid IN 
  (SELECT CW.cid
  FROM CompanyWatchlist CW
  WHERE CW.wid IN 
    (SELECT W.wid
	FROM Watchlist W
	WHERE W.ContainsForeign=1))

--------------------------------------------- EXISTS

SELECT *
FROM Company C
WHERE EXISTS
  (SELECT CW.cid
  FROM CompanyWatchlist CW
  WHERE C.cid=CW.cid AND MaxSharesNr >= 1000)

SELECT *
FROM InvestorWatchlist W
WHERE EXISTS
  (SELECT *
  FROM Investor I
  WHERE W.iid = I.iid AND I.Age=25)

--------------------------------------------- Subquery in FROM

SELECT wid, AverageShareNr
FROM (SELECT wid, AVG(MaxSharesNr) AS AverageShareNr
	FROM CompanyWatchlist
	GROUP BY wid
	) AS WatchlistInfo
ORDER BY AverageShareNr

SELECT TOP 50 PERCENT NetWorth
FROM (SELECT DISTINCT NetWorth
	FROM Company
	) AS DistinctWorth
ORDER BY NetWorth DESC
--------------------------------------------- GROUP BY

SELECT C.CName, SUM(DISTINCT CW.MaxSharesNr) AS ShareTotal
FROM CompanyWatchlist CW INNER JOIN Company C ON CW.cid = C.cid
WHERE CW.MaxSharesNr>=1000 AND (CW.cid = 101 OR CW.cid = 103)
GROUP BY C.CName

SELECT C.CName, MAX(CW.MaxSharesNr) AS ShareNrMax
FROM CompanyWatchlist CW INNER JOIN Company C ON CW.cid = C.cid
GROUP BY C.CName
HAVING MAX(CW.MaxSharesNr) > 
  (SELECT AVG(CW2.MaxSharesNr)
  FROM CompanyWatchlist CW2)

SELECT NetWorth, MIN(SharePrice) AS MinSharePrice
FROM Company 
GROUP BY NetWorth
HAVING NOT (MIN(SharePrice) < 1000 OR MAX(SharePrice) > 2000) 

SELECT Age - 18
FROM Investor 
GROUP BY Age
HAVING Age < (SELECT MAX(Age) FROM Investor)

--------------------------------------------- ANY ALL

SELECT TOP 2 *
FROM Investor
WHERE pid = ANY 
  (SELECT pid
  FROM Portofolio
  WHERE IsPositive = 1)
ORDER BY Age

SELECT TOP 2 *
FROM Investor
WHERE pid IN
  (SELECT pid
  FROM Portofolio
  WHERE IsPositive = 1)
ORDER BY Age


SELECT *
FROM PortofolioCompany
WHERE SharesNr < ALL
  (SELECT MaxSharesNr
  FROM CompanyWatchlist)
  
SELECT PC.*
FROM PortofolioCompany PC
WHERE PC.SharesNr < 
  (SELECT MIN(MaxSharesNr)
  FROM CompanyWatchlist)



SELECT *
FROM PortofolioCompany 
WHERE cid != ALL
  (SELECT cid
  FROM Company
  WHERE NetWorth > 15000)
ORDER BY SharesNr

SELECT *
FROM PortofolioCompany 
WHERE cid NOT IN
  (SELECT cid
  FROM Company
  WHERE NetWorth > 15000)
ORDER BY SharesNr



SELECT *
FROM CompanyWatchlist 
WHERE MaxSharesNr < ALL
  (SELECT SharesNr
  FROM Company
  WHERE SharesNr > 1500)

SELECT *
FROM CompanyWatchlist 
WHERE MaxSharesNr <
  (SELECT MIN(SharesNr)
  FROM Company
  WHERE SharesNr > 1500)