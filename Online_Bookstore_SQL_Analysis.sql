-- =============================================================
-- REQUIREMENTS
-- =============================================================
-- Database: PostgreSQL
-- Client: psql
--
-- Run this script from the repository root directory.
-- The CSV files are located in the data/ folder.
-- =============================================================
-- =============================================================
-- ONLINE BOOKSTORE SQL ANALYSIS
-- PostgreSQL | Data Analyst Portfolio Project
-- =============================================================
-- Project workflow:
-- 1. Create database and relational tables
-- 2. Load CSV data
-- 3. Perform basic data exploration
-- 4. Answer business questions with aggregations and JOINs
-- 5. Perform advanced analysis using CTEs, subqueries, and window functions
-- =============================================================

-- =============================================================
-- 1. DATABASE SETUP
-- =============================================================

CREATE DATABASE OnlineBookstore;

-- Run the remaining commands after connecting to OnlineBookstore.
-- In psql, use: \c OnlineBookstore
\c OnlineBookstore;

-- =============================================================
-- 2. TABLE CREATION
-- =============================================================

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;

CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

-- =============================================================
-- 3. DATA IMPORT
-- =============================================================
-- Run this script from the repository root so the relative paths
-- below resolve to the CSV files in the data/ folder.

\copy Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
FROM 'data/Books.csv'
CSV HEADER;

\copy Customers(Customer_ID, Name, Email, Phone, City, Country)
FROM 'data/Customers.csv'
CSV HEADER;

\copy Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
FROM 'data/Orders.csv'
CSV HEADER;

-- =============================================================
-- 4. BASIC DATA EXPLORATION
-- =============================================================

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

-- =============================================================
-- 5. BASIC BUSINESS ANALYSIS
-- =============================================================

-- 1) Retrieve all books in the Fiction genre.
SELECT *
FROM Books
WHERE Genre = 'Fiction';

-- 2) Find books published after 1950.
SELECT *
FROM Books
WHERE Published_Year > 1950;

-- 3) List all customers from Canada.
SELECT *
FROM Customers
WHERE Country = 'Canada';

-- 4) Show orders placed in November 2023.
SELECT *
FROM Orders
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Calculate the total stock of books available.
SELECT SUM(Stock) AS Total_Stock
FROM Books;

-- 6) Find the most expensive book.
SELECT *
FROM Books
ORDER BY Price DESC
LIMIT 1;

-- 7) Show orders where more than one book was purchased.
SELECT *
FROM Orders
WHERE Quantity > 1;

-- 8) Retrieve orders where the total amount exceeds 20.
SELECT *
FROM Orders
WHERE Total_Amount > 20;

-- 9) List all unique book genres.
SELECT DISTINCT Genre
FROM Books;

-- 10) Find the book with the lowest stock.
SELECT *
FROM Books
ORDER BY Stock ASC
LIMIT 1;

-- 11) Calculate total revenue generated from all orders.
SELECT SUM(Total_Amount) AS Revenue
FROM Orders;

-- =============================================================
-- 6. ADVANCED BUSINESS ANALYSIS
-- =============================================================

-- 1) Retrieve the total number of books sold for each genre.
SELECT
    b.Genre,
    SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY Total_Books_Sold DESC;

-- 2) Find the average price of books in the Fantasy genre.
SELECT
    AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 3) List customers who have placed at least 2 orders.
SELECT
    o.Customer_ID,
    c.Name,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY o.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2
ORDER BY Order_Count DESC;

-- 4) Find the most frequently ordered book based on order count.
SELECT
    o.Book_ID,
    b.Title,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY o.Book_ID, b.Title
ORDER BY Order_Count DESC
LIMIT 1;

-- 5) Show the top 3 most expensive Fantasy books.
SELECT
    Book_ID,
    Title,
    Author,
    Price
FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author.
SELECT
    b.Author,
    SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY b.Author
ORDER BY Total_Books_Sold DESC;

-- 7) List cities containing customers whose total spending exceeds 30.
SELECT DISTINCT
    c.City
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.City
HAVING SUM(o.Total_Amount) > 30
ORDER BY c.City;

-- 8) Find the customer who spent the most on orders.
SELECT
    c.Customer_ID,
    c.Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Spent DESC
LIMIT 1;

-- 9) Calculate remaining stock after fulfilling all recorded orders.
SELECT
    b.Book_ID,
    b.Title,
    b.Stock,
    COALESCE(SUM(o.Quantity), 0) AS Ordered_Quantity,
    b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Quantity
FROM Books b
LEFT JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
ORDER BY b.Book_ID;

-- =============================================================
-- 7. CTE ANALYSIS
-- =============================================================

-- 1) Compare revenue and units sold across genres.
WITH Genre_Performance AS (
    SELECT
        b.Genre,
        SUM(o.Quantity) AS Units_Sold,
        SUM(o.Total_Amount) AS Revenue
    FROM Books b
    JOIN Orders o
        ON b.Book_ID = o.Book_ID
    GROUP BY b.Genre
)
SELECT
    Genre,
    Units_Sold,
    Revenue
FROM Genre_Performance
ORDER BY Revenue DESC;

-- 2) Identify customers whose spending is above the average customer spend.
WITH Customer_Spending AS (
    SELECT
        c.Customer_ID,
        c.Name,
        SUM(o.Total_Amount) AS Total_Spent
    FROM Customers c
    JOIN Orders o
        ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Customer_ID, c.Name
)
SELECT
    Customer_ID,
    Name,
    Total_Spent
FROM Customer_Spending
WHERE Total_Spent > (
    SELECT AVG(Total_Spent)
    FROM Customer_Spending
)
ORDER BY Total_Spent DESC;

-- =============================================================
-- 8. SUBQUERY ANALYSIS
-- =============================================================

-- 1) Find books whose price is above the average book price.
SELECT
    Book_ID,
    Title,
    Genre,
    Price
FROM Books
WHERE Price > (
    SELECT AVG(Price)
    FROM Books
)
ORDER BY Price DESC;

-- 2) Find the customer with the highest total spending.
SELECT
    c.Customer_ID,
    c.Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING SUM(o.Total_Amount) = (
    SELECT MAX(Customer_Total)
    FROM (
        SELECT
            Customer_ID,
            SUM(Total_Amount) AS Customer_Total
        FROM Orders
        GROUP BY Customer_ID
    ) AS Customer_Spending
);

-- =============================================================
-- 9. WINDOW FUNCTION ANALYSIS
-- =============================================================

-- 1) Rank books by total quantity sold.
SELECT
    b.Book_ID,
    b.Title,
    b.Genre,
    SUM(o.Quantity) AS Total_Books_Sold,
    RANK() OVER (
        ORDER BY SUM(o.Quantity) DESC
    ) AS Sales_Rank
FROM Books b
JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Genre
ORDER BY Sales_Rank;

-- 2) Rank authors by total quantity of books sold.
SELECT
    b.Author,
    SUM(o.Quantity) AS Total_Books_Sold,
    DENSE_RANK() OVER (
        ORDER BY SUM(o.Quantity) DESC
    ) AS Author_Rank
FROM Books b
JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Author
ORDER BY Author_Rank;

-- 3) Rank Fantasy books by price and return the top 3.
WITH Fantasy_Books AS (
    SELECT
        Book_ID,
        Title,
        Author,
        Price
    FROM Books
    WHERE Genre = 'Fantasy'
), Ranked_Fantasy_Books AS (
    SELECT
        Book_ID,
        Title,
        Author,
        Price,
        ROW_NUMBER() OVER (
            ORDER BY Price DESC
        ) AS Price_Rank
    FROM Fantasy_Books
)
SELECT
    Book_ID,
    Title,
    Author,
    Price,
    Price_Rank
FROM Ranked_Fantasy_Books
WHERE Price_Rank <= 3
ORDER BY Price_Rank;

-- 4) Show each customer's orders with a running total of spending.
SELECT
    o.Customer_ID,
    c.Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    SUM(o.Total_Amount) OVER (
        PARTITION BY o.Customer_ID
        ORDER BY o.Order_Date, o.Order_ID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Spent
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
ORDER BY o.Customer_ID, o.Order_Date, o.Order_ID;

-- =============================================================
-- 10. FINAL BUSINESS INSIGHTS QUERIES
-- =============================================================

-- Top 5 books by revenue.
SELECT
    b.Book_ID,
    b.Title,
    b.Genre,
    SUM(o.Quantity) AS Units_Sold,
    SUM(o.Total_Amount) AS Revenue
FROM Books b
JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Genre
ORDER BY Revenue DESC
LIMIT 5;

-- Revenue by month.
SELECT
    DATE_TRUNC('month', Order_Date)::DATE AS Month,
    SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY DATE_TRUNC('month', Order_Date)
ORDER BY Month;

-- =============================================================
-- END OF PROJECT
-- =============================================================
