-- Creating the Retail Sales Database
use master
IF DB_ID('RetailSalesDB') IS NOT NULL
    DROP DATABASE RetailSalesDB;
GO

CREATE DATABASE RetailSalesDB;
GO

USE RetailSalesDB;
GO

--tables
select * from customers;
select * from products;
select * from orders;
select * from orderdetails;


-- Creating Tables
-- Customers: Stores customer information
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Address VARCHAR(200)
);

-- Products: Stores product details
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    CONSTRAINT CHK_StockQuantity CHECK (StockQuantity >= 0)
);

-- Orders: Stores order headers
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails: Stores items in each order
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0)
);

-- Create Index for Performance
-- Index on OrderDate to speed up date-based queries
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);

-- Generating Sample Data
-- 1. Insert 500 Customers
DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Customers (FirstName, LastName, Email, Phone, Address)
    VALUES (
        'Customer' + CAST(@i AS VARCHAR(3)),
        'Last' + CAST(@i AS VARCHAR(3)),
        'customer' + CAST(@i AS VARCHAR(3)) + '@email.com',
        '555-0' + RIGHT('000' + CAST(@i AS VARCHAR(3)), 3),
        CAST(@i AS VARCHAR(3)) + ' Street, City' + CAST((@i % 5) + 1 AS VARCHAR(1))
    );
    SET @i = @i + 1;
END;

-- 2. Insert 100 Products
DECLARE @j INT = 1;
DECLARE @Categories TABLE (Category VARCHAR(50));
INSERT INTO @Categories VALUES ('Electronics'), ('Clothing'), ('Accessories'), ('Home'), ('Books');
WHILE @j <= 100
BEGIN
    INSERT INTO Products (ProductName, Category, UnitPrice, StockQuantity)
    SELECT 
        'Product' + CAST(@j AS VARCHAR(3)),
        (SELECT Category FROM @Categories ORDER BY NEWID() OFFSET 0 ROWS FETCH FIRST 1 ROW ONLY),
        ROUND(RAND() * 4950 + 50, 2), -- Random price between 50 and 5000
        CAST(RAND() * 1000 AS INT) -- Random stock between 0 and 1000
    SET @j = @j + 1;
END;

-- 3. Insert 10,000 Orders (Spread over 2023-2025)
DECLARE @k INT = 1;
WHILE @k <= 10000
BEGIN
    DECLARE @CustomerID INT = (SELECT TOP 1 CustomerID FROM Customers ORDER BY NEWID());
    DECLARE @OrderDate DATE = DATEADD(DAY, -CAST(RAND() * 1095 AS INT), '2025-06-24'); -- Random date in last 3 years
    DECLARE @TotalAmount DECIMAL(10,2) = 0;
    
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (@CustomerID, @OrderDate, @TotalAmount);
    
    DECLARE @OrderID INT = SCOPE_IDENTITY();
    DECLARE @NumItems INT = 1 + CAST(RAND() * 5 AS INT); -- 1 to 5 items per order
    DECLARE @m INT = 1;
    
    WHILE @m <= @NumItems
    BEGIN
        DECLARE @ProductID INT = (SELECT TOP 1 ProductID FROM Products ORDER BY NEWID());
        DECLARE @Quantity INT = 1 + CAST(RAND() * 10 AS INT); -- 1 to 10 units
        DECLARE @UnitPrice DECIMAL(10,2) = (SELECT UnitPrice FROM Products WHERE ProductID = @ProductID);
        
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);
        
        SET @TotalAmount = @TotalAmount + (@Quantity * @UnitPrice);
        SET @m = @m + 1;
    END;
    
    -- Update TotalAmount in Orders
    UPDATE Orders
    SET TotalAmount = @TotalAmount
    WHERE OrderID = @OrderID;
    
    SET @k = @k + 1;
END;

-- Create a Simple Stored Procedure for Sales by Category
CREATE PROCEDURE GetSalesByCategory
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        p.Category,
        COUNT(od.OrderDetailID) AS TotalItemsSold,
        SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
    GROUP BY p.Category
    ORDER BY TotalRevenue DESC;
END;
GO

-- Create a View for Customer Orders
CREATE VIEW CustomerOrderSummary AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO

-- Queries for Analysis

-- 1. Total Sales by Category (Using Stored Procedure)
EXEC GetSalesByCategory '2023-01-01', '2025-06-24';

-- 2. Top 5 Customers by Total Spending
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FirstName, c.LastName
ORDER BY TotalSpent DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 3. Monthly Sales Summary
SELECT 
    FORMAT(o.OrderDate, 'yyyy-MM') AS Month,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSales
FROM Orders o
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY Month;

-- 4. Products with Low Stock
SELECT 
    ProductName,
    Category,
    StockQuantity
FROM Products
WHERE StockQuantity < 50
ORDER BY StockQuantity;

-- 5. Customer Order Details
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    (od.Quantity * od.UnitPrice) AS LineTotal
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '2025-01-01'
ORDER BY o.OrderDate;

-- 6. Average Order Value
SELECT 
    AVG(TotalAmount) AS AverageOrderValue
FROM Orders;

-- 7. Top 5 Products by Sales Volume
SELECT 
    p.ProductName,
    p.Category,
    SUM(od.Quantity) AS TotalUnitsSold
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY TotalUnitsSold DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 8. Customers with Above-Average Spending
SELECT 
    CustomerName,
    TotalSpent
FROM CustomerOrderSummary
WHERE TotalSpent > (SELECT AVG(TotalSpent) FROM CustomerOrderSummary)
ORDER BY TotalSpent DESC;

-- 9. Sales Contribution by Category
SELECT 
    p.Category,
    SUM(od.Quantity * od.UnitPrice) AS CategoryRevenue,
    ROUND((SUM(od.Quantity * od.UnitPrice) * 100.0) / 
          (SELECT SUM(Quantity * UnitPrice) FROM OrderDetails), 2) AS PercentOfTotalSales
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.Category
ORDER BY CategoryRevenue DESC;

-- Additional Queries (Intermediate to Light Advanced)

-- 10. Product Sales by Quarter
-- Purpose: Analyzes seasonal sales patterns for inventory planning
SELECT 
    p.Category,
    DATEPART(YEAR, o.OrderDate) AS SalesYear,
    DATEPART(QUARTER, o.OrderDate) AS SalesQuarter,
    SUM(od.Quantity) AS TotalUnitsSold,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY p.Category, DATEPART(YEAR, o.OrderDate), DATEPART(QUARTER, o.OrderDate)
ORDER BY SalesYear, SalesQuarter, TotalRevenue DESC;

-- 11. Customers with No Orders in Last 6 Months
-- Purpose: Identifies inactive customers for re-engagement campaigns
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Email
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID
    AND DATEDIFF(MONTH, o.OrderDate, '2025-06-24') <= 6
)
ORDER BY c.CustomerID;

-- 12. Top 3 Products per Category by Revenue
-- Purpose: Highlights best-performing products within each category
SELECT 
    Category,
    ProductName,
    TotalRevenue
FROM (
    SELECT 
        p.Category,
        p.ProductName,
        SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY p.Category ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS Rank
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    GROUP BY p.Category, p.ProductName
) RankedProducts
WHERE Rank <= 3
ORDER BY Category, TotalRevenue DESC;

-- 13. Orders with Multiple Categories
-- Purpose: Identifies orders with products from different categories for cross-selling analysis
SELECT 
    o.OrderID,
    o.OrderDate,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(DISTINCT p.Category) AS CategoryCount
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, o.OrderDate, c.FirstName, c.LastName
HAVING COUNT(DISTINCT p.Category) > 2
ORDER BY CategoryCount DESC, o.OrderDate;

