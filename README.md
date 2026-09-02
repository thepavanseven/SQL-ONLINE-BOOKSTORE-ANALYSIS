# Online Bookstore SQL Analysis

## Project Overview

This project analyzes an online bookstore database using PostgreSQL to answer business-oriented questions related to books, customers, orders, sales, revenue, and inventory.

The project demonstrates relational database design and practical SQL analysis using JOINs, aggregations, CTEs, subqueries, and window functions.

## Objectives

- Analyze bookstore sales and order performance
- Identify best-selling books and authors
- Analyze customer purchasing behavior
- Compare sales across genres
- Identify high-value customers
- Analyze book pricing and inventory
- Perform advanced analysis using CTEs, subqueries, and window functions

## Database Structure

The project uses three related tables:

### Books

Contains information about the books available in the bookstore.

- Book_ID
- Title
- Author
- Genre
- Published_Year
- Price
- Stock

### Customers

Contains customer information.

- Customer_ID
- Name
- Email
- Phone
- City
- Country

### Orders

Contains transaction-level order information.

- Order_ID
- Customer_ID
- Book_ID
- Order_Date
- Quantity
- Total_Amount

### Relationships

```text
Customers
    |
    | Customer_ID
    |
    v
  Orders
    |
    | Book_ID
    |
    v
  Books
