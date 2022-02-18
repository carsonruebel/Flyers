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

---------------

DROP TABLE DIM_Industry_v3;
DROP TABLE DIM_Merchant_v3;
DROP TABLE DIM_Product_v3;
DROP TABLE FACT_Ad_v3;
DROP TABLE Staging_v3;

---------------

exec EmptyAllTables_v3

---------------

exec InsertNormalizedAd_v3


select count(*) from Staging_v3 where current_price is not null
select count(*) from FACT_Ad_v3
select count(*) from DIM_Industry_v3
select count(*) from DIM_Merchant_v3
select count(*) from DIM_Product_v3



--Unnormalize data back to entry spreadsheet
SELECT i.Industry, m.Merchant, p.Brand_Product, p.Category, p.pre_price_text, fact.LoadDate, fact.Price
FROM [dbo].[FACT_Ad_v3] fact
LEFT JOIN DIM_Industry_v3 i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant_v3 m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Product_v3 p on fact.ProductID = p.ProductID