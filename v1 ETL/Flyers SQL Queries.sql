/*
	6 queries to create 6 tables
*/


CREATE TABLE DIM_Industry (
    IndustryID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Industry VARCHAR(50) NOT NULL,
);

CREATE TABLE DIM_Merchant (
    MerchantID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Merchant VARCHAR(100) NOT NULL
);

CREATE TABLE DIM_Brand (
    BrandID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Brand VARCHAR(100) NOT NULL
);

CREATE TABLE DIM_Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Product VARCHAR(100) NOT NULL,
	ProductDescription VARCHAR(255),
	Category VARCHAR(100) NOT NULL,
	GeneralProduct VARCHAR(100) NOT NULL
);

CREATE TABLE DIM_Flyer (
    FlyerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    URI VARCHAR(255) NOT NULL
);

CREATE TABLE FACT_Ad (
    AdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	IndustryID INT FOREIGN KEY REFERENCES DIM_Industry(IndustryID) NOT NULL,
	MerchantID INT FOREIGN KEY REFERENCES DIM_Merchant(MerchantID) NOT NULL,
	BrandID INT FOREIGN KEY REFERENCES DIM_Brand(BrandID) NOT NULL,
	ProductID INT FOREIGN KEY REFERENCES DIM_Product(ProductID) NOT NULL,
	FlyerID INT FOREIGN KEY REFERENCES DIM_Flyer(FlyerID),
	Distinction VARCHAR(50) NOT NULL,
	Amount VARCHAR(50) NOT NULL,
	MinQuantity INT,
	MaxQuantity INT,
	Price DECIMAL(10,2) NOT NULL
);

--------------------------------------------------------------------------------------

/*
	creates stored procedure to clear all data from 6 tables
	Also contains exec command to execute the stored proc
*/


CREATE PROCEDURE EmptyAllTables
AS
    DELETE FROM FACT_Ad;
    DBCC CHECKIDENT ('FACT_Ad', RESEED, 0);
    DELETE FROM DIM_Industry;
    DBCC CHECKIDENT ('DIM_Industry', RESEED, 0);
    DELETE FROM DIM_Merchant;
    DBCC CHECKIDENT ('DIM_Merchant', RESEED, 0);
    DELETE FROM DIM_Brand;
    DBCC CHECKIDENT ('DIM_Brand', RESEED, 0);
    DELETE FROM DIM_Product;
    DBCC CHECKIDENT ('DIM_Product', RESEED, 0);
    DELETE FROM DIM_Flyer;
    DBCC CHECKIDENT ('DIM_Flyer', RESEED, 0);
GO

exec EmptyAllTables

--------------------------------------------------------------------------------------

/*
	Creates stored procedure used to insert data into dim & fact tables
*/


CREATE PROCEDURE InsertNormalizedAd
	@Industry VARCHAR(50),
	@Merchant VARCHAR(100),
	@Brand VARCHAR(100),
	@Product VARCHAR(100),
	@ProductDescription VARCHAR(255),
	@Category VARCHAR(100),
	@GeneralProduct VARCHAR(100),
	@URI VARCHAR(255),
	@StartDate DATE,
	@EndDate DATE,
	@Distinction VARCHAR(50),
	@Amount VARCHAR(50),
	@MinQuantity INT,
	@MaxQuantity INT,
	@Price DECIMAL(10,2)
AS   
	INSERT INTO DIM_Industry (Industry) VALUES (@Industry);
	INSERT INTO DIM_Merchant (Merchant) VALUES (@Merchant);
	INSERT INTO DIM_Brand (Brand) VALUES (@Brand);
	INSERT INTO DIM_Product (Product, ProductDescription, Category, GeneralProduct) VALUES (@Product, @ProductDescription, @Category, @GeneralProduct);
	INSERT INTO DIM_Flyer (URI) VALUES (@URI);
	INSERT INTO FACT_Ad (StartDate, EndDate, IndustryID, MerchantID, BrandID, ProductID, FlyerID, Distinction, Amount, MinQuantity, MaxQuantity, Price)
		VALUES (
			@StartDate, @EndDate,
			(SELECT MAX(IndustryID) from DIM_Industry),
			(SELECT MAX(MerchantID) FROM DIM_Merchant),
			(SELECT MAX(BrandID) FROM DIM_Brand),
			(SELECT MAX(ProductID) FROM DIM_Product),
			(SELECT MAX(FlyerID) FROM DIM_Flyer),
			@Distinction, @Amount, @MinQuantity, @MaxQuantity, @Price); 
GO  

--------------------------------------------------------------------------------------

/*
	Query to convert the data stored in dim & fact tables back to spreadsheet format from manual data entry
*/


SELECT i.Industry, m.Merchant, b.Brand, p.Product, p.ProductDescription, p.Category, p.GeneralProduct, f.URI, fact.StartDate, fact.EndDate, fact.Distinction, fact.Amount, fact.MinQuantity, fact.MaxQuantity, fact.Price
FROM [dbo].[FACT_Ad] fact
LEFT JOIN DIM_Industry i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Brand b on fact.BrandID = b.BrandID
LEFT JOIN DIM_Product p on fact.ProductID = p.ProductID
LEFT JOIN DIM_Flyer f on fact.FlyerID = f.FlyerID