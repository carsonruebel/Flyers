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

---------------

DROP TABLE DIM_Industry_v2;
DROP TABLE DIM_Merchant_v2;
DROP TABLE DIM_Product_v2;
DROP TABLE FACT_Ad_v2;

---------------

exec EmptyAllTables_v2

---------------



--Unnormalize data back to entry spreadsheet
SELECT i.Industry, m.Merchant, p.Brand_Product, p.Category, p.pre_price_text, fact.StartDate, fact.EndDate, fact.Price
FROM [dbo].[FACT_Ad_v2] fact
LEFT JOIN DIM_Industry_v2 i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant_v2 m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Product_v2 p on fact.ProductID = p.ProductID