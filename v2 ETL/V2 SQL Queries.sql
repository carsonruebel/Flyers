/*
	4 queries to create 4 tables
*/


CREATE TABLE DIM_Industry_v2 (
    IndustryID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Industry VARCHAR(50) NOT NULL,
);

CREATE TABLE DIM_Merchant_v2 (
    MerchantID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Merchant VARCHAR(100) NOT NULL
);

CREATE TABLE DIM_Product_v2 (
    ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Brand_Product VARCHAR(100) NOT NULL,
	Category VARCHAR(100) NULL,
	pre_price_text VARCHAR(100) NULL,
	URI VARCHAR(255) NOT NULL
);

CREATE TABLE FACT_Ad_v2 (
    AdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	IndustryID INT FOREIGN KEY REFERENCES DIM_Industry_v2(IndustryID) NOT NULL,
	MerchantID INT FOREIGN KEY REFERENCES DIM_Merchant_v2(MerchantID) NOT NULL,
	ProductID INT FOREIGN KEY REFERENCES DIM_Product_v2(ProductID) NOT NULL,
	Price DECIMAL(10,2) NOT NULL
);


--------------------------------------------------------------------------------------

/*
	creates stored procedure to clear all data from 4 tables
	Also contains exec command to execute the stored proc
*/


CREATE PROCEDURE EmptyAllTables_v2
AS
    DELETE FROM FACT_Ad_v2;
    DBCC CHECKIDENT ('FACT_Ad_v2', RESEED, 0);
    DELETE FROM DIM_Industry_v2;
    DBCC CHECKIDENT ('DIM_Industry_v2', RESEED, 0);
    DELETE FROM DIM_Merchant_v2;
    DBCC CHECKIDENT ('DIM_Merchant_v2', RESEED, 0);
    DELETE FROM DIM_Product_v2;
    DBCC CHECKIDENT ('DIM_Product_v2', RESEED, 0);
GO

exec EmptyAllTables_v2

--------------------------------------------------------------------------------------

/*
	Creates stored procedure used to insert data into dim & fact tables
*/


CREATE PROCEDURE InsertNormalizedAd_v2
	@Industry VARCHAR(50),
	@Merchant VARCHAR(100),
	@Brand_Product VARCHAR(100),
	@Category VARCHAR(100),
	@pre_price_text VARCHAR(100),
	@URI VARCHAR(255),
	@StartDate DATE,
	@EndDate DATE,
	@Price DECIMAL(10,2)
AS   
	INSERT INTO DIM_Industry_v2 (Industry) VALUES (@Industry);
	INSERT INTO DIM_Merchant_v2 (Merchant) VALUES (@Merchant);
	INSERT INTO DIM_Product_v2 (Brand_Product, Category, pre_price_text, URI) VALUES (@Brand_Product, @Category, @pre_price_text, @URI);
	INSERT INTO FACT_Ad_v2 (StartDate, EndDate, IndustryID, MerchantID, ProductID, Price)
		VALUES (
			@StartDate, @EndDate,
			(SELECT MAX(IndustryID) from DIM_Industry_v2),
			(SELECT MAX(MerchantID) FROM DIM_Merchant_v2),
			(SELECT MAX(ProductID) FROM DIM_Product_v2),
			@Price); 
GO  

--------------------------------------------------------------------------------------

/*
	Query to convert the data stored in dim & fact tables back to spreadsheet format from python history spreadsheet
*/


SELECT i.Industry, m.Merchant, p.Brand_Product, p.Category, p.pre_price_text, fact.StartDate, fact.EndDate, fact.Price
FROM [dbo].[FACT_Ad_v2] fact
LEFT JOIN DIM_Industry_v2 i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant_v2 m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Product_v2 p on fact.ProductID = p.ProductID