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

---------------

DROP TABLE DIM_Industry;
DROP TABLE DIM_Merchant;
DROP TABLE DIM_Brand;
DROP TABLE DIM_Product;
DROP TABLE DIM_Flyer;
DROP TABLE FACT_Ad;

---------------




exec EmptyAllTables



--Unnormalize data back to entry spreadsheet
SELECT i.Industry, m.Merchant, b.Brand, p.Product, p.ProductDescription, p.Category, p.GeneralProduct, f.URI, fact.StartDate, fact.EndDate, fact.Distinction, fact.Amount, fact.MinQuantity, fact.MaxQuantity, fact.Price
FROM [dbo].[FACT_Ad] fact
LEFT JOIN DIM_Industry i on fact.IndustryID = i.IndustryID
LEFT JOIN DIM_Merchant m on fact.MerchantID = m.MerchantID
LEFT JOIN DIM_Brand b on fact.BrandID = b.BrandID
LEFT JOIN DIM_Product p on fact.ProductID = p.ProductID
LEFT JOIN DIM_Flyer f on fact.FlyerID = f.FlyerID

select top 5 * from FACT_Ad