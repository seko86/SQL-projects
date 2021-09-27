SELECT 
  C.CategoryName, 
  S.Country AS SupplierCountry, 
  CUS.Country AS CustomerCountry, 
  CASE -- CASE used for indicating which NULL is represented by lack of data in Customer Region column - these records are listed as 'Not provided'
	WHEN CUS.Region IS NULL  AND GROUPING(CUS.Region)= 0 THEN 'Not provided'  
	ELSE CUS.Region 
	END CustomerRegion, 
  ROUND(SUM(OD.UnitPrice * OD.Quantity), 2) AS OrdersValue, -- Order Values are sum of multiplication UnitPrice and Quantity columns from OrderDetails table
  CASE  -- CASE describes particular levels of multiple grouping 
	GROUPING_ID(C.CategoryName, S.Country, CUS.Country, CUS.Region) 
	WHEN 7 THEN 'Category' 
	WHEN 11 THEN 'Country - Supplier' 
	WHEN 12 THEN 'Country & Region-Customer' 
	END GroupingLevel 
FROM 
  Customers CUS -- Table Customes inner joined with 5 other tables 
  JOIN Orders O ON CUS.CustomerID = O.CustomerID 
  JOIN [Order Details] OD ON OD.OrderID = O.OrderID 
  JOIN Products P ON OD.ProductID = P.ProductID 
  JOIN Suppliers S ON P.SupplierID = S.SupplierID 
  JOIN Categories C ON C.CategoryID = P.CategoryID 
GROUP BY  -- Group by Grouping Sets function in order to multiple grouping by 3 sets
  GROUPING SETS (
    C.CategoryName, 
    S.Country, 
    (CUS.Country, CUS.Region)
  ) 
ORDER BY
  GroupingLevel, 
  OrdersValue DESC
