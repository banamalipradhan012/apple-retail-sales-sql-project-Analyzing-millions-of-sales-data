# Apple Retail Sales SQL Project – Analyzing Millions of Sales Rows

![Apple Retail](https://github.com/banamalipradhan012/apple-retail-sales-sql-project-Analyzing-millions-of-sales-data/blob/main/cover%20photo/apple_sales_cover_photo.jpg)

---

## Project Overview 

This project is designed to showcase advanced SQL querying techniques through the analysis of over **1 million rows of Apple retail sales data**. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally.


---

## Entity Relationship Diagram (ERD)

![ERD](https://github.com/banamalipradhan012/apple-retail-sales-sql-project-Analyzing-millions-of-sales-data/blob/main/ERD/apple_sales_ERD.png)


---

## Database Schema

The project consists of the following five tables:

### 1. stores
- `store_id`: Unique identifier for each store  
- `store_name`: Name of the store  
- `city`: City where the store is located  
- `country`: Country where the store is located  

---

### 2. category
- `category_id`: Unique identifier for each product category  
- `category_name`: Name of the category  

---

### 3. products
- `product_id`: Unique identifier for each product  
- `product_name`: Name of the product  
- `category_id`: References the category table  
- `launch_date`: Product launch date  
- `price`: Product price  

---

### 4. sales
- `sale_id`: Unique identifier for each sale  
- `sale_date`: Date of the sale  
- `store_id`: References the store table  
- `product_id`: References the product table  
- `quantity`: Number of units sold  

---

### 5. warranty
- `claim_id`: Unique identifier for each warranty claim  
- `claim_date`: Date the claim was filed  
- `sale_id`: References the sales table  
- `repair_status`: Warranty claim status  

---

## Objectives


1. Find the number of stores in each country  
2. Calculate the total number of units sold by each store  
3. Identify how many sales occurred in December 2023  
4. Determine how many stores have never had a warranty claim filed  
5. Calculate the percentage of warranty claims marked as "Warranty Void"  
6. Identify which store had the highest total units sold in the last year  
7. Count the number of unique products sold in the last year  
8. Find the average price of products in each category  
9. How many warranty claims were filed in 2020?  
10. For each store, identify the best-selling day based on highest quantity sold  
11. Identify the least selling product in each country for each year based on total units sold  
12. Calculate how many warranty claims were filed within 180 days of a product sale  
13. Determine how many warranty claims were filed for products launched in the last two years  
14. List the months in the last three years where sales exceeded 5,000 units in the USA  
15. Identify the product category with the most warranty claims filed in the last two years  
16. Determine the percentage chance of receiving warranty claims after each purchase for each country  
17. Analyze the year-by-year growth ratio for each store  
18. Calculate the correlation between product price and warranty claims for products sold in the last five years  
19. Identify the store with the highest percentage of "Paid Repaired" claims  
20. Calculate the monthly running total of sales for each store over the past four years  
21. Analyze product sales trends over time segmented into:
  - 0–6 months from launch  
  - 6–12 months  
  - 12–18 months  
  - Beyond 18 months  

---

## Project Focus

This project focuses on developing and showcasing:

- Complex joins and aggregations  
- Window functions  
- Time-based data segmentation  
- Correlation analysis  
- Real-world business problem solving  

---

## Dataset Details

- **Size**: 1M+ sales records  
- **Time Period**: Multiple years  
- **Coverage**: Apple retail stores across multiple countries



## Author
**Banamali Pradhan** — Aspiring Data Analyst  
Transitioning from Pharmaceutical Industry to Data Analytics  
[LinkedIn Profile](https://www.linkedin.com/in/banamali-pradhan)
