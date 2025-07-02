# RetailSalesDB - MSSQL Retail Sales Management System

## Overview
This project is a Microsoft SQL Server database designed to simulate a retail sales system, showcasing my skills in database design, querying, and optimization. It manages 500 customers, 100 products, and over 10,000 orders, providing a scalable dataset for analysis. The project includes a stored procedure, a view, an index, and 15 queries (basic to light advanced) to deliver insights like sales trends, customer behavior, and inventory management.

### Objectives
- Demonstrate proficiency in MSSQL for database creation and management.
- Handle large datasets (10,000+ orders) to showcase scalability.
- Provide actionable business insights for retail operations.
- Present a professional project for resume and interviews.

## Database Schema
The database consists of four tables:
- **Customers**: Stores customer details (CustomerID, FirstName, LastName, Email, Phone, Address).
- **Products**: Contains product info (ProductID, ProductName, Category, UnitPrice, StockQuantity).
- **Orders**: Tracks order headers (OrderID, CustomerID, OrderDate, TotalAmount).
- **OrderDetails**: Links orders to products (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice).

![ERD](ERD.png)

- **Constraints**: Primary/foreign keys ensure relationships; CHECK constraints enforce data integrity (e.g., non-negative stock).
- **Index**: On `Orders.OrderDate` for faster date-based queries.

## Project Components
- **Data Generation**: Automated script inserts 500 customers, 100 products, and 10,000 orders (2023–2025) using WHILE loops, RAND(), and NEWID() for realism.
- **Stored Procedure**: `GetSalesByCategory` reports sales by category for a given date range.
- **View**: `CustomerOrderSummary` precomputes customer order counts and spending.
- **Queries**: 15 queries for analysis:
  1. Total Sales by Category (Stored Procedure)
  2. Top 5 Customers by Total Spending
  3. Monthly Sales Summary
  4. Products with Low Stock
  5. Customer Order Details
  6. Average Order Value
  7. Top 5 Products by Sales Volume
  8. Customers with Above-Average Spending
  9. Sales Contribution by Category
  10. Orders with High Value (Above 90th Percentile)
  11. Product Sales by Quarter
  12. Customers with No Orders in Last 6 Months
  13. Top 3 Products per Category by Revenue
  14. Orders with Multiple Categories
  15. Stock Replenishment Priority

- **Sample Outputs**: See `SampleOutput.xlsx` for results of Queries 3, 9, 13, and 15.
- **Sample Data**: `customers.csv` and `products.csv` show data structure (note: data is generated via SQL script).

## Setup Instructions
1. **Environment**: Install SQL Server and SQL Server Management Studio (SSMS).
2. **Run Script**:
   - Open `RetailSalesProject_10K_Complete.sql` in SSMS.
   - Execute the script to create the database, tables, and populate data (~1–2 minutes).
3. **View ERD**: Open `ERD.png` or generate in SSMS (Database Diagrams).
4. **Run Queries**: Execute queries in SSMS to analyze data.
5. **Import CSVs (Optional)**: Use `BULK INSERT` to load `customers.csv` and `products.csv` if needed.

## Business Value
- **Sales Analysis**: Identifies top categories (Query 9) and trends (Query 3, 11) for strategic planning.
- **Customer Insights**: Targets high-value (Query 2, 8) and inactive customers (Query 12) for marketing.
- **Inventory Management**: Prioritizes restocking (Query 4, 15) to prevent stockouts.
- **Cross-Selling**: Analyzes diverse purchases (Query 14) for product bundling.

## Challenges Faced
- Optimized data generation for 10,000 orders to run efficiently.
- Ensured data integrity with constraints and tested queries.
- Learned to explain technical concepts (e.g., subqueries, ranking) clearly.

## Future Enhancements
- Add a trigger to update stock on order placement.
- Develop a web interface (e.g., Python Flask) for reports.
- Include regional sales analysis with location data.

## Skills Demonstrated
- MSSQL
- Database Design
