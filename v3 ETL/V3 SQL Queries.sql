/*
	5 queries to create 5 tables
*/


CREATE TABLE Staging_v3 (
    AdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Load_Date DATE NOT NULL,
	Industry VARCHAR(255) NULL,
	_L1 VARCHAR(255) NULL,
	_L2 VARCHAR(255) NULL,
	clean_image_url VARCHAR(255) NULL,
	clipping_image_url VARCHAR(255) NULL,
	current_price DECIMAL(10,2) NULL,
	flyer_id INT NULL,
	flyer_item_id INT NULL,
	id INT NULL,
	item_type VARCHAR(255) NULL,
	merchant_id VARCHAR(255) NULL,
	merchant_logo VARCHAR(255) NULL,
	merchant_name VARCHAR(255) NULL,
	name VARCHAR(255) NULL,
	original_price INT NULL,
	post_price_text VARCHAR(255) NULL,
	pre_price_text VARCHAR(255) NULL,
	sale_story VARCHAR(255) NULL,
	valid_from VARCHAR(255) NULL,
	valid_to VARCHAR(255) NULL
);

CREATE TABLE DIM_Industry_v3 (
    IndustryID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Industry VARCHAR(50) NOT NULL,
);

CREATE TABLE DIM_Merchant_v3 (
    MerchantID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Merchant VARCHAR(100) NOT NULL
);

CREATE TABLE DIM_Product_v3 (
    ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Brand_Product VARCHAR(100) NOT NULL,
	Category VARCHAR(100) NULL,
	pre_price_text VARCHAR(100) NULL,
	URI VARCHAR(255) NOT NULL
);

CREATE TABLE FACT_Ad_v3 (
    AdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LoadDate DATE NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	IndustryID INT FOREIGN KEY REFERENCES DIM_Industry_v3(IndustryID) NOT NULL,
	MerchantID INT FOREIGN KEY REFERENCES DIM_Merchant_v3(MerchantID) NOT NULL,
	ProductID INT FOREIGN KEY REFERENCES DIM_Product_v3(ProductID) NOT NULL,
	Price DECIMAL(10,2) NOT NULL
);

--------------------------------------------------------------------------------------

/*
	creates stored procedure to clear all data from 4 tables and reseed ID
	Also contains exec command to execute the stored proc
*/


CREATE PROCEDURE EmptyAllTables_v3
AS
    DELETE FROM FACT_Ad_v3;
    DBCC CHECKIDENT ('FACT_Ad_v3', RESEED, 0);
    DELETE FROM DIM_Industry_v3;
    DBCC CHECKIDENT ('DIM_Industry_v3', RESEED, 0);
    DELETE FROM DIM_Merchant_v3;
    DBCC CHECKIDENT ('DIM_Merchant_v3', RESEED, 0);
    DELETE FROM DIM_Product_v3;
    DBCC CHECKIDENT ('DIM_Product_v3', RESEED, 0);
    DELETE FROM Staging_v3;
    DBCC CHECKIDENT ('Staging_v3', RESEED, 0);
GO

exec EmptyAllTables_v3

--------------------------------------------------------------------------------------

/*
	Creates stored procedure used to insert data into dim & fact tables
*/


CREATE PROCEDURE InsertNormalizedAd_v3
AS
BEGIN
	--declare input attributes and cursor
	DECLARE @industry VARCHAR(50)
	DECLARE @merchant VARCHAR(100)
	DECLARE @brandproduct VARCHAR(100)
	DECLARE @productcategory VARCHAR(100)
	DECLARE @prepricetext VARCHAR(100)
	DECLARE @uri VARCHAR(255)
	DECLARE @startdate DATE
	DECLARE @enddate DATE
	DECLARE @price DECIMAL(10,2)
	DECLARE @loaddate DATE
	DECLARE c CURSOR FOR
	--iterate through staging table
	SELECT Industry, merchant_name, name, _L2, pre_price_text, clean_image_url, valid_from, valid_to, current_price, Load_Date
	FROM Staging_v3
	WHERE current_price IS NOT NULL
	--map staging attributes to declarations
	OPEN c
	FETCH NEXT FROM c INTO @industry, @merchant, @brandproduct, @productcategory, @prepricetext, @uri, @startdate, @enddate, @price, @loaddate
	--iterate through each record
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--check if industry exists
		DECLARE @industryid INT;
		SET @industryid = (
			SELECT IndustryID FROM DIM_Industry_v3
			WHERE Industry = @industry
		);
		IF @industryid IS NULL
		BEGIN
		--insert into dim_industry_v3
			INSERT INTO DIM_Industry_v3
				VALUES (@industry);
		--set @industryid to newly created industryID 
			SET @industryid = (
				SELECT IndustryID FROM DIM_Industry_v3
				WHERE Industry = @industry
			);
		END
	--check if merchant exists
		DECLARE @merchantid INT;
		SET @merchantid = (
			SELECT MerchantID FROM DIM_Merchant_v3
			WHERE Merchant = @merchant
		);
		IF @merchantid IS NULL
		BEGIN
		--insert into dim_merchant_v3
			INSERT INTO DIM_Merchant_v3
				VALUES (@merchant);
		--set @merchantid to newly created merchantID 
			SET @merchantid = (
				SELECT MerchantID FROM DIM_Merchant_v3
				WHERE Merchant = @merchant
			);
		END
	--check if product exists
		DECLARE @productid INT;
		SET @productid = (
			SELECT ProductID FROM DIM_Product_v3
			WHERE Brand_Product = @brandproduct
		);
		IF @productid IS NULL
		BEGIN
		--insert into dim_product_v3
			INSERT INTO DIM_Product_v3
				VALUES (@brandproduct, @productcategory, @prepricetext, @uri);
		--set @productid to newly created productID 
			SET @productid = (
				SELECT ProductID FROM DIM_Product_v3
				WHERE Brand_Product = @brandproduct
			);
		END
	--insert fact entry
		INSERT INTO FACT_Ad_v3
			VALUES (@loaddate, @startdate, @enddate, @industryid, @merchantid, @productid, @price);
	--fetch new row from cursor
		FETCH NEXT FROM c INTO @industry, @merchant, @brandproduct, @productcategory, @prepricetext, @uri, @startdate, @enddate, @price, @loaddate
	END;
	--close and deallocate the cursor
	CLOSE c
	DEALLOCATE c
	--wipe and reset staging table for next day's load
	DELETE FROM Staging_v3;
	DBCC CHECKIDENT ('Staging_v3', RESEED, 0);
END
GO

--------------------------------------------------------------------------------------

/*
	Query to convert the data stored in dim & fact tables back to spreadsheet format from python history spreadsheet
*/


SELECT i.Industry, m.Merchant, p.Brand_Product, p.Category, p.pre_price_text, fact.LoadDate, fact.Price
FROM [dbo].[FACT_Ad_v3] fact
LEFT JOIN DIM_Industry_v3 i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant_v3 m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Product_v3 p on fact.ProductID = p.ProductID