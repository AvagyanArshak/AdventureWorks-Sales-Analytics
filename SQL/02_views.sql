-- 1. Sales Summary
CREATE VIEW vw_SalesSummary AS
SELECT 
    YEAR(soh.OrderDate)               AS OrderYear,
    MONTH(soh.OrderDate)              AS OrderMonth,
    st.Name                           AS Territory,
    st.CountryRegionCode              AS Country,
    COUNT(DISTINCT soh.SalesOrderID)  AS TotalOrders,
    SUM(soh.SubTotal)                 AS SubTotal,
    SUM(soh.TaxAmt)                   AS TaxAmount,
    SUM(soh.TotalDue)                 AS TotalRevenue
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st 
    ON soh.TerritoryID = st.TerritoryID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    st.Name,
    st.CountryRegionCode;

SELECT * FROM vw_SalesSummary;


-- 2. Top Products
CREATE VIEW vw_TopProducts AS
SELECT 
    pc.Name                     AS Category,
    ps.Name                     AS Subcategory,
    p.Name                      AS ProductName,
    p.ListPrice,
    SUM(sod.OrderQty)           AS TotalQuantitySold,
    SUM(sod.LineTotal)          AS TotalRevenue,
    COUNT(DISTINCT sod.SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p 
    ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps 
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc 
    ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY 
    pc.Name,
    ps.Name,
    p.Name,
    p.ListPrice;

SELECT * FROM vw_TopProducts;


-- 3. Customer Analysis
CREATE VIEW vw_CustomerAnalysis AS
SELECT 
    c.CustomerID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS CustomerName,
    st.Name                                AS Territory,
    st.CountryRegionCode                   AS Country,
    COUNT(DISTINCT soh.SalesOrderID)       AS TotalOrders,
    SUM(soh.TotalDue)                      AS TotalSpent,
    MIN(soh.OrderDate)                     AS FirstOrderDate,
    MAX(soh.OrderDate)                     AS LastOrderDate
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp 
    ON c.PersonID = pp.BusinessEntityID
JOIN Sales.SalesTerritory st 
    ON soh.TerritoryID = st.TerritoryID
GROUP BY 
    c.CustomerID,
    pp.FirstName,
    pp.LastName,
    st.Name,
    st.CountryRegionCode;

SELECT * FROM vw_CustomerAnalysis;


-- 4. SalesPerson Performance
CREATE VIEW vw_SalesPersonPerformance AS
SELECT 
    CONCAT(pp.FirstName, ' ', pp.LastName) AS SalesPersonName,
    st.Name                                AS Territory,
    YEAR(soh.OrderDate)                    AS OrderYear,
    COUNT(DISTINCT soh.SalesOrderID)       AS TotalOrders,
    SUM(soh.TotalDue)                      AS TotalSales,
    sp.SalesQuota,
    SUM(soh.TotalDue) - sp.SalesQuota      AS QuotaDifference
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp 
    ON soh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person pp 
    ON sp.BusinessEntityID = pp.BusinessEntityID
JOIN Sales.SalesTerritory st 
    ON soh.TerritoryID = st.TerritoryID
GROUP BY 
    pp.FirstName,
    pp.LastName,
    st.Name,
    YEAR(soh.OrderDate),
    sp.SalesQuota;


SELECT * FROM vw_SalesPersonPerformance;
