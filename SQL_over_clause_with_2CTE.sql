WITH SumAndAvg -- First CTE for calculating Ranking, Running Sum, Maximum Unit Price and Moving Average Unit Price in windows
AS 
(
SELECT  P.ProductID, 
		C.CategoryName, 
		P.UnitPrice, 
		RANK() OVER( -- Calculating Olympic Ranking using OVER clause with partition on category names ordered by unit price descending
				PARTITION BY C.CategoryName 
				ORDER BY P.UnitPrice DESC) AS Ranking,
	    SUM(P.UnitPrice) OVER (   -- Calculating Running Sum using OVER clause on whole data (full window) with partition on category names 
				PARTITION BY C.CategoryName 
				ORDER BY P.UnitPrice DESC
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunSum,
		MAX(P.UnitPrice) OVER (   -- Calculating Maximum Unit Price using OVER clause on window with 2 preceding and following rows with partition on category names
				PARTITION BY C.CategoryName 
				ORDER BY P.UnitPrice DESC
				ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS MaxUnitPrice,
		ROUND(AVG(P.UnitPrice) OVER ( -- Calculating Moving Average Unit Price using OVER clause on window with 2 preceding rows with partition on category names
				PARTITION BY C.CategoryName 
				ORDER BY P.UnitPrice DESC
				ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS MovAvg
FROM Products P
JOIN Categories C ON P.CategoryID=C.CategoryID
),
SumAndAvg2  -- Second CTE for calculating Difference between Moving Average for current row and next row with partition on category names
AS 
(
SELECT  ProductID, 
		CategoryName, 
		UnitPrice, 
		Ranking,
		RunSum, 
		MaxUnitPrice,
		MovAvg,
		MovAvg - LEAD(MovAvg, 1) OVER ( -- Calculating Difference between Moving Average for current row and next row with partition on category names
				PARTITION BY CategoryName 
				ORDER BY UnitPrice DESC) AS MovAvgDiff
FROM SumAndAvg
)
SELECT  ProductID, 
		CategoryName, 
		UnitPrice, 
		Ranking,
		RunSum, 
		MaxUnitPrice,
		MovAvg, 
		ISNULL(MovAvgDiff, 0) AS MovAvgDiff -- Changing NULL's to 0 as a difference
FROM SumAndAvg2
ORDER BY CategoryName, Ranking