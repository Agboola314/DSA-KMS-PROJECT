SELECT * from [KMS]
-----CGANGE PROFIT,UNIT PRICE, AND SHIPPINGCOST DATA
ALTER TABLE [KMS]
ALTER COLUMN Shipping_Cost DECIMAL (10, 3);

ALTER TABLE [KMS]
ALTER COLUMN Profit DECIMAL (10, 3);

ALTER TABLE [KMS]
ALTER COLUMN Unit_Price DECIMAL (10, 3);

ALTER TABLE [KMS Sql Case Study]
ALTER COLUMN float (10, 3)

SELECT * FROM [KMS]

SELECT Row_ID, Sales, Product_Category, Region, Product_Name, Province, Profit, Ship_Mode, Shipping_Cost FROM [KMS]

CREATE VIEW SUMMARY AS SELECT  Row_ID, Sales, Product_Category, Region, Product_Name, Province, Profit, Ship_Mode, Shipping_Cost FROM [KMS];

SELECT * FROM SUMMARY

-----1. PRODUCT CATEGORY WITH THE HIGHEST SALES.

SELECT Product_Category, SUM(Sales) AS sales
FROM SUMMARY
GROUP BY Product_Category
ORDER BY sales DESC

-----TECHNOLOGY 5984253

SELECT * FROM [KMS]

----Top 3 and Bottom 3 Region
SELECT top 3 Region, SUM (Sales) AS Sales
FROM SUMMARY
GROUP BY Region
ORDER BY Sales DESC

---- WEST, ONTARIO AND PRARIE
 

SELECT  top 3 Region, SUM (Sales) AS Sales
FROM SUMMARY
GROUP BY Region
ORDER BY Sales ASC
---- NUNAVUT, NORTHWEST TERRITORIES AND YUKON


----3. total sales of appliances in Ontario
----under region
Select Region, SUM (Sales) AS Tot_Sales_Of_App
FROM KMS
WHERE Region = 'Ontario' and Product_Sub_Category = 'Appliances'
group by Region;
----202350

SELECT * FROM SUMMARY

----5.KMS INCURRED THE MOST SHIPPING COST WITH WHICH SHIPPING METHOD

SELECT TOP 1 Ship_Mode,
SUM(Shipping_Cost) AS
total_shipping_cost
FROM SUMMARY
GROUP BY Ship_Mode
ORDER BY total_shipping_cost DESC

----- ANSWER IS DELIVERY TRUCK


SELECT * FROM [KMS]

-----6.THE are the MOST VALUABLE CUSTOMER AND WHAT ITEM THEY PURCHASED

SELECT TOP 3 Customer_Name,
SUM(Order_Quantity) AS Tot_Prod_Services,
SUM(Unit_Price) AS Total_Spent
FROM KMS
GROUP BY Customer_Name
ORDER BY Total_Spent DESC

SELECT DISTINCT Customer_Name, [Product_Name]
FROM KMS
WHERE Customer_Name = 'Roy Phan';
---- ROY PHAN HE PURCHASED A LOT OF ITEMS

-----7. WHICH SMALL BUSINESS CUSTOMER HAD THE HIGHEST SALES

SELECT TOP 1 Customer_Segment, Customer_Name, Sales
FROM KMS
WHERE Customer_Segment = 'Small Business'
ORDER BY Sales DESC
------DENNIS KANE WITH 33368 SALES

----8. WHAT CORPORATE CUSTOMER PLACED THE MOST NUMBER OF ORDERS IN 2009-2012

SELECT TOP 1 Customer_Name,
SUM(Order_Quantity) AS Total_Order
FROM KMS
WHERE Customer_Segment = 'Corporate'
    AND Order_Date BETWEEN '2009-01-01'
AND '2012-12-31'
GROUP BY Customer_Name
ORDER BY Total_Order DESC;
---- Roy Skaria 773 orders

 
 ------9.WHICH CONSUMER CUSTOMER WAS THE MOST PROFITABLES
SELECT TOP 1 Customer_Name,
SUM(Profit) AS Total_Profit
FROM KMS
WHERE Customer_Segment = 'Consumer'
GROUP BY Customer_Name
ORDER BY Total_Profit DESC;
---- EMILY PHAN 34005.440


SELECT TOP 1 Customer_Name,
SUM(Unit_Price) AS Total_Sales
FROM KMS
WHERE Customer_Segment = 'Small Business'
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;
----- Adrian Barton 6870.740

SELECT TOP 1 Customer_Name,
SUM(Order_Quantity * Unit_Price) AS Total_Sales
FROM KMS
WHERE Customer_Segment = 'Small Business'
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;
------ Emily Phan; 118906.330


SELECT * FROM [KMS]

SELECT * FROM dbo.Order_Status

------JOINING KMS AND ORDER_STATUS TABLE TOGETHER
SELECT KMS.*, os.Status
FROM KMS
INNER JOIN dbo.Order_Status AS os
ON KMS.Order_ID = os.Order_ID;

-----10. WHICH CUSTOMER RETURNED ITEMS, AND WHAT SEGMENT DO THEY BELONG TO---

SELECT DISTINCT KMS.Customer_Name,
KMS.Customer_Segment
FROM KMS
JOIN dbo.Order_Status AS os ON
KMS.Order_ID = os.Order_ID
WHERE os.Status = 'Returned';


SELECT TOP 10
KMS.Customer_Name,
KMS.Customer_Segment,
COUNT(*) AS Return_Count
FROM KMS
JOIN dbo.Order_Status AS os ON
KMS.Order_ID = os.Order_ID
WHERE os.Status = 'Returned'
GROUP BY KMS.Customer_Name,
KMS.Customer_Segment
ORDER BY Return_Count DESC;
----ANSWER DARREN BUDD, CONSUMER, RETURN COUNT 10.


-----TOP RETURNING CUSTOMER, THE PRODUCT THEY RETURNED THEIR SEGMENT

WITH Top_Returning_Customer AS (
   SELECT TOP 1
		KMS.Customer_Name,
		COUNT(*) AS Return_Count
	FROM KMS
	JOIN dbo.Order_Status AS os ON
KMS.Order_ID = os.Order_ID
	WHERE os.Status = 'Returned'
	GROUP BY KMS.Customer_Name
	ORDER BY Return_Count DESC
)

SELECT
	KMS.Customer_Name,
	KMS.Customer_Segment,
	KMS.[Product_Category]
FROM KMS
JOIN dbo.Order_Status AS os ON
KMS.Order_ID = os.Order_ID
JOIN Top_Returning_Customer trc ON 
KMS.Customer_Name = trc.Customer_Name
WHERE os.Status = 'Returned';

------QUESTION 4-------
------ADVISE MANAGEMENT ON WHAT TO DO TO INCREASE THE REVENUE FROM BOTTOM 10 CUSTOMERS
---TO GET BOTTOM 10 CUSTOMER BY REVENUE

SELECT TOP 10 Customer_Name,
SUM(Unit_Price * Order_Quantity) AS
Total_Revenue
FROM KMS
GROUP BY Customer_Name
ORDER BY Total_Revenue ASC;
----CREATE A CTE FOR BOTTOM 10
WITH  Bottom_Customers AS (
	SELECT TOP 10 Customer_Name
	FROM KMS
	GROUP BY Customer_Name
	ORDER BY SUM(Unit_Price * Order_Quantity) ASC
	)
	SELECT
	KMS.Customer_Name,
	KMS.Customer_Segment,
	KMS.Region,
	KMS.[Product_Name],
	COUNT(KMS.Order_ID) AS
Order_Count,
	SUM(CASE WHEN os.Status = 'Returned' THEN 1 ELSE 0 END) AS
	Returns_Count
	FROM KMS
	JOIN Bottom_Customers bc ON
	KMS.Customer_Name = bc.Customer_Name
	LEFT JOIN dbo.Order_Status os ON
	KMS.Order_ID = os.Order_ID
	GROUP BY
	KMS.Customer_Name,
	KMS.Customer_Segment,
	KMS.Region,
	KMS.[Product_Name]
ORDER BY KMS.Customer_Name,
Order_Count DESC

----5 OF THE 10 CUSTOMERS ARE FROM THE WEST REGION, THIS INDICATES A REGIONAL PATTERN 
----IN UNDERPERFORMANCE. THE MANAGEMENT CAN CONDUCT A REGIONAL EXPERIENCE AUDIT
-- LAUNCH A WEST REGION LOYALTY OR WIN BACK CAMPAIGN
---ASSESS FULFILMENT EFFICIENCY IN THE WEST
---BOOSTS BRAND TOUCHPOINTS IN THE WEST.



-------QUESTION 11-----
-----IF DELIVERY TRUCK WAS THE MOST ECONOMICAL BUT THE SLOWEST SHIPPING METHOD AND AIR EXPRESS THE FASTEST
----TO CHECK HOW MANY LOW PRIORITY ORDERS USED AIR EXPRESS

SELECT Order_Priority,
Ship_Mode, COUNT(*) AS
Order_Quantity
from KMS
GROUP BY Order_Priority,
Ship_Mode
ORDER BY Order_Priority,
Ship_Mode;

SELECT KMS.*, os.Status
FROM KMS
INNER JOIN dbo.Order_Status AS os
ON KMS.Order_ID = os.Order_ID;

-----TOTAL SHIPPING COST BY PRIORITY+METHOD
SELECT Order_Priority,
Ship_Mode, SUM(Shipping_Cost)
AS Total_Shipping_Spent
FROM KMS
GROUP BY Order_Priority,
Ship_Mode
ORDER BY Order_Priority,
Ship_Mode;

---CONCLUSION ON QUESTION 11
--THE ANALYSIS OF TOTAL SHIPPING COSTS BY ORDER PRIORITY AND METHOD REVEALS A PARTIAL 
---MISALIGNMENT BETWEEN SHIPPING COST AND ORDER URGENCY.
---WHILE SOME HIGH PRIORITY ORDERS WERE APPROPRIATELY SHIPPED USING AIR EXPRESS, A NOTABLE
-- PERCENTAGE OF LOW PRIORITY AND MEDIUM PRIORITY ORDERS WERE ALSO SHIPPED VIA AIR EXPRESS, 
--INCURRING HIGHER SHIPPING COSTS UNNECESSARILY.
--RECOMMENDATION FOR THE COMPANY
---IMPLEMENT ORDER PRIORITY BASED SHIPPING RULES IN THE SYSTEM.
---USE DELIVERY TRUCK FOR ALL LOW PRIORITY ORDERS UNLESS THE CUSTOMER PAYS FOR AN UPGRADE
---TRACK AND REVIEW SHIPPING METHOD USAGE MONTHLY TO CONTROL COSTS.