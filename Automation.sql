USE Data_SK

-- Firstly I created empty Raw_Data_GDP Table where I will store all my data from CSV file

DROP TABLE IF EXISTS Raw_Data_GDP

CREATE TABLE Raw_Data_GDP
(
[IND] NVARCHAR(50),
[INDICATOR] NVARCHAR (200),
[LOCATION] NVARCHAR(5),
[COUNTRY] NVARCHAR(200),
[TIME] NVARCHAR(4),
[VALUE] FLOAT,
[FLAG CODES] NVARCHAR(20),
[FLAGS] NVARCHAR(200)
)

-- Then I copied all data from CSV Table to newly created Raw_Data_GDP Table

BULK INSERT Raw_Data_GDP
FROM 'C:\Users\Sebastian\Downloads\gdp_raw_data.csv'
WITH (FORMAT='CSV', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A');

--SELECT TOP 20 * FROM Raw_Data_GDP

-- Then I created the view to select only columns that I am interested about

CREATE VIEW Excel_Data_GDP AS 

SELECT t1.*, t2.GDP_Value_Per_Capita 
FROM
(SELECT Country, [Time] AS [Year], [Value] AS GDP_Value
FROM Raw_Data_GDP
WHERE Indicator = 'GDP (current US$)') t1
LEFT JOIN
(SELECT Country, [Time] AS [Year], [Value] AS GDP_Value_Per_Capita
FROM Raw_Data_GDP
WHERE Indicator = 'GDP per capita (current US$)') t2
ON t1.COUNTRY=t2.COUNTRY AND t1.Year=t2.Year

--SELECT * FROM Excel_Data_GDP

--  In next step I created procedure that will automatically copy data from csv file to sql table 'Raw_Data_GDP' (I can set monthly job to update data every month by executing procedure)

--DROP PROCEDURE GDP_Excel_Monthly_Update
CREATE PROCEDURE GDP_Excel_Monthly_Update AS 

DROP TABLE IF EXISTS Raw_Data_GDP

CREATE TABLE Raw_Data_GDP
(
[IND] NVARCHAR(50),
[INDICATOR] NVARCHAR (200),
[LOCATION] NVARCHAR(5),
[COUNTRY] NVARCHAR(200),
[TIME] NVARCHAR(4),
[VALUE] FLOAT,
[FLAG CODES] NVARCHAR(20),
[FLAGS] NVARCHAR(200)
)

BULK INSERT Raw_Data_GDP
FROM 'C:\Users\Sebastian\Downloads\gdp_raw_data.csv'
WITH (FORMAT='CSV', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A' );

-- In the end I run the procedure to see results 

EXEC GDP_Excel_Monthly_Update