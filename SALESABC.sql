CREATE TABLE SalesABC.dbo.sales_data (
   	[ProductID] [varchar](50) NULL,
	[ProductName] [varchar](50) NULL,
	[Price] [decimal](38, 0) NULL,
	[Quantity] [int] NULL,
	[Total] [decimal](38, 0) NULL,
	[Discount] [decimal](38, 0) NULL,
	[Tax] [decimal](38, 0) NULL,
	[Shipping] [decimal](38, 0) NULL,
	[Profit] [decimal](38, 0) NULL,
	[StaffName] [varchar](50) NULL,
	[OrderDate] [date] NULL
);

--TRUNCATE TABLE SalesABC.dbo.SALES_DATA;

-- Load data into the table using BULK INSERT with Microsoft OLE DB Provider for SQL Server
BULK INSERT SalesABC.dbo.sales_data
FROM 'C:\Users\User\Documents\Automation\sales_data.csv'
WITH 
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '0x0a',   --Use to shift the control to next row
    TABLOCK
);

ALTER TABLE SalesABC.dbo.SALES_DATA
ADD InsertUpdateDateTime DATETIME2 DEFAULT(GETDATE());

-- Update existing rows to set InsertUpdateDateTime to the current date and time
UPDATE SalesABC.dbo.SALES_DATA
SET InsertUpdateDateTime = GETDATE()
WHERE InsertUpdateDateTime IS NULL;

CREATE TABLE #TempSalesData (
   	[ProductID] [varchar](50) NULL,
	[ProductName] [varchar](50) NULL,
	[Price] [decimal](38, 0) NULL,
	[Quantity] [int] NULL,
	[Total] [decimal](38, 0) NULL,
	[Discount] [decimal](38, 0) NULL,
	[Tax] [decimal](38, 0) NULL,
	[Shipping] [decimal](38, 0) NULL,
	[Profit] [decimal](38, 0) NULL,
	[StaffName] [varchar](50) NULL,
	[OrderDate] [date] NULL
);


BULK INSERT #TempSalesData
FROM 'C:\Users\User\Documents\Automation\sales_data.csv'
WITH 
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '0x0a',   --Use to shift the control to next row
    TABLOCK
);


--MERGE INTO SalesABC.dbo.SALES_DATA AS target
--USING #TempSalesData AS source
--ON target.ProductID = source.ProductID -- Assuming ProductID is the primary key
--WHEN NOT MATCHED BY TARGET THEN
--    INSERT (
--        ProductID, ProductName, Price, Quantity, Total,
--        Discount, Tax, Shipping, Profit, StaffName, OrderDate, InsertUpdateDateTime
--    )
--    VALUES (
--        source.ProductID, source.ProductName, source.Price, source.Quantity, source.Total,
--        source.Discount, source.Tax, source.Shipping, source.Profit, source.StaffName, source.OrderDate, GETDATE()
--    );


INSERT INTO SalesABC.dbo.SALES_DATA (
    ProductID, ProductName, Price, Quantity, Total,
    Discount, Tax, Shipping, Profit, StaffName, OrderDate, InsertUpdateDateTime
)
SELECT
    source.ProductID, source.ProductName, source.Price, source.Quantity, source.Total,
    source.Discount, source.Tax, source.Shipping, source.Profit, source.StaffName, source.OrderDate, GETDATE()
FROM
    #TempSalesData AS source
WHERE
    source.ProductID NOT IN (SELECT ProductID FROM SalesABC.dbo.SALES_DATA);