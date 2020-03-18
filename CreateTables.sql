DROP TABLE Post
DROP TABLE PortofolioCompany
DROP TABLE CompanyWatchlist
DROP TABLE Analysis
DROP TABLE Company
DROP TABLE InvestorWatchlist
DROP TABLE Watchlist
DROP TABLE Investor 
DROP TABLE Portofolio
DROP TABLE InvestingPlatform


CREATE TABLE InvestingPlatform ( 
	pid int PRIMARY KEY, 
	PlatformName varchar(255)
);
CREATE TABLE Portofolio ( 
	pid int PRIMARY KEY, 
	plid int FOREIGN KEY REFERENCES InvestingPlatform (pid),
	IsPositive bit
);
CREATE TABLE Investor ( 
	iid int PRIMARY KEY, 
	pid int UNIQUE FOREIGN KEY REFERENCES Portofolio (pid),
	FName varchar(50),
	LName varchar(50),
	Age int
);
CREATE TABLE Watchlist ( 
	wid int PRIMARY KEY, 
	pid int FOREIGN KEY REFERENCES InvestingPlatform (pid),
	ContainsForeign bit
);
CREATE TABLE InvestorWatchlist ( 
	iid int FOREIGN KEY REFERENCES Investor(iid), 
	wid int FOREIGN KEY REFERENCES Watchlist(wid) 
	PRIMARY KEY ( iid, wid )
);
--CREATE TABLE GlobalIndex ( iid int PRIMARY KEY);
--CREATE TABLE IndexPlatform ( iid int FOREIGN KEY REFERENCES GlobalIndex(iid), pid int FOREIGN KEY REFERENCES Platform(pid) );
--CREATE TABLE Director ( did int PRIMARY KEY);
--CREATE TABLE Specialist ( sid int PRIMARY KEY);
CREATE TABLE Company ( 
	cid int PRIMARY KEY,
	CName varchar(50),
	SharePrice int,
	SharesNr int,
	NetWorth int
);
DROP TABLE Analysis
CREATE TABLE Analysis ( 
	aid int PRIMARY KEY IDENTITY (1,1), 
	cid int FOREIGN KEY REFERENCES Company(cid),
	AnalystName varchar(50),
	Grade int,
	IsRising bit
);
CREATE TABLE CompanyWatchlist ( 
	cid int FOREIGN KEY REFERENCES Company(cid), 
	wid int FOREIGN KEY REFERENCES Watchlist(wid)
	PRIMARY KEY ( cid, wid ),
	MaxSharesNr int
);
CREATE TABLE PortofolioCompany ( 
	pid int FOREIGN KEY REFERENCES Portofolio(pid), 
	cid int FOREIGN KEY REFERENCES Company(cid)
	PRIMARY KEY ( pid, cid ),
	SharesNr int
);
CREATE TABLE Post( 
	iid int FOREIGN KEY REFERENCES Investor(iid), 
	pid int FOREIGN KEY REFERENCES InvestingPlatform (pid), 
	cid int FOREIGN KEY REFERENCES Company(cid)
	PRIMARY KEY ( iid, pid, cid ),
	TextMessage text,
	UpvotesNr int
);