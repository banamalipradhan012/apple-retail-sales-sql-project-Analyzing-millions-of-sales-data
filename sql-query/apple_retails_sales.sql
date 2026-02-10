create database appledb;

CREATE TABLE category (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category_id VARCHAR(10),
    launch_date DATE,
    price INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE sales (
    sale_id VARCHAR(15) PRIMARY KEY,
    sale_date DATE,
    store_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE warranty (
    claim_id VARCHAR(15) PRIMARY KEY,
    claim_date DATE,
    sale_id VARCHAR(15),
    repair_status VARCHAR(20),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/category.csv'
INTO TABLE category
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/warranty.csv'
INTO TABLE warranty
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

select count(sale_id) from sales;
explain analyze
select * from category;

-- BUSINESS PROBLEMS:
-- 1. Find the number of stores in each country.

select country,
       count(store_id) as store_counts
from stores 
group by country;

-- 2. Calculate the total number of units sold by each store.

select s.store_name,
       sum(s1.quantity) as units_sold
from stores s 
join sales s1 on s.store_id = s1.store_id
group by s.store_name
order by units_sold desc;

-- 3. Identify how many sales occurred in December 2023.

select count(sale_id) as total_sales
from sales
where year(sale_date) = 2023 and monthname(sale_date) = 'December';

-- 4. Determine how many stores have never had a warranty claim filed.

select count(*)
from stores
where store_id not in (
                   select distinct s.store_id
                   from sales s 
                   join warranty w on s.sale_id = w.sale_id);
       
-- 5. Calculate the percentage of warranty claims marked as "Rejected".

select 
       round(count(claim_id)/(select count(*) from warranty)*100,2) as claim_rejected_percentage
from warranty 
where repair_status = 'Rejected';

-- 6. Identify which store had the highest total units sold in the last year.

select s.store_id,
       s.store_name,
       sum(s1.quantity) as total_units
from stores s 
join sales s1 on s.store_id = s1.store_id
where year(sale_date) = 2024
group by s.store_id,s.store_name
limit 1;

-- 7. Count the number of unique products sold in the last year.

select distinct product_name
from products p 
join sales s on p.product_id = s.product_id
where year(sale_date) = 2024;

-- 8. Find the average price of products in each category.

select category_name,
	   round(avg(price)) as avg_price
from category c 
join products p on c.category_id = p.category_id 
group by category_name
order by avg_price desc;

-- 9. How many warranty claims were filed in 2020?

select count(*)
from warranty 
where year(claim_date) = 2020;

-- 10. For each store, identify the best-selling day based on highest quantity sold.

with daily_sales as(
select store_id,
       sale_date,
       sum(quantity) as total_qty
from sales 
group by store_id,sale_date
),
ranked_sales as (
select *,
       rank() over(partition by store_id order by total_qty desc) as rnk
from daily_sales
)
select store_id,
       sale_date as best_selling_date,
       total_qty
from ranked_sales
where rnk = 1
order by store_id;

-- 11. Identify the least selling product in each country for each year based on total units sold.

with yearly_product_sales as(
select s1.country,
       year(s.sale_date) as year_sale,
       s.product_id,
       sum(s.quantity) as total_qty
from sales s 
join stores s1 on s.store_id = s1.store_id
group by s1.country,year_sale,s.product_id
),
ranked_products as(
select *,
       rank() over(partition by country,year_sale order by total_qty asc) as rnk
from yearly_product_sales
)
select country,
       year_sale,
       product_id,
       total_qty as least_selling_product
from ranked_products
where rnk = 1
order by country,year_sale,product_id;

-- 12. Calculate how many warranty claims were filed within 180 days of a product sale.

select count(*) as claims_within_180_days
from sales s 
join warranty w on s.sale_id = w.sale_id
where datediff(w.claim_date,s.sale_date) between 0 and 180;

-- 13. Determine how many warranty claims were filed for products launched in the last two years.

select count(*) as claims_for_recent_products
from products p 
join sales s on p.product_id = s.product_id
join warranty w on s.sale_id = w.sale_id
where p.launch_date >= date_sub(curdate(),interval 2 year);

-- 14. List the months in the last three years where sales exceeded 5,000 units in the USA.

select month(s.sale_date) as sales_month,
       sum(s.quantity) as total_units
from sales s 
join stores s1 on s.store_id = s1.store_id 
where s1.country = 'United States' and s.sale_date >= date_sub(curdate(),interval 3 year)
group by sales_month
having total_units > 5000
order by sales_month;

-- 15. Identify the product category with the most warranty claims filed in the last two years.

select c.category_name ,
       count(*) as most_warranty_claims
from category c 
join products p on c.category_id = p.category_id
join sales s on p.product_id = s.product_id 
join warranty w on s.sale_id = w.sale_id 
where w.claim_date>=date_sub(curdate(),interval 2 year)
group by c.category_name
order by most_warranty_claims desc
limit 1;

-- 16. Analyze the year-by-year growth ratio for each store.

with yearly_sales as(
select store_id,
       year(sale_date) as sales_year,
       sum(quantity) as total_units
from sales 
group by store_id,sales_year
),
growth_cal as (
select store_id,
       sales_year,
       total_units,
       lag(total_units) over(partition by store_id order by sales_year) as prev_year_units 
from yearly_sales 
)
select store_id,
       sales_year,
       total_units,
       prev_year_units,
       round((total_units-prev_year_units)/prev_year_units,2) as growth_ratio 
from growth_cal
where prev_year_units is not null
order by store_id,sales_year;

/* 17. Analyze product sales trends over time, segmented into key periods: 
from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.*/

with product_lifecycle as(
select p.product_id,
       p.product_name,
       s.sale_date,
       p.launch_date,
       s.quantity,
       timestampdiff(month,p.launch_date,s.sale_date) as months_since_launch
from products p 
join sales s on p.product_id = s.product_id 
),
sales_bucket as (
select product_id,
	   product_name,
       case 
           when months_since_launch between 0 and 5 then '0 to 6 months'
           when months_since_launch between 6 and 11 then '6 to 12 months'
           when months_since_launch between 12 and 17 then '12 to 18 months'
           else '18+ months'
           end as lifecycle_stage,
           sum(quantity) as total_units 
from product_lifecycle 
group by product_id,product_name,lifecycle_stage
)
select *
from sales_bucket
order by product_id,lifecycle_stage;

-- 18. Which stores are underperforming compared to company average revenue?

select s1.store_id,
       sum(s.quantity*p.price) as total_revenue
from products p 
join sales s on s.product_id = p.product_id 
join stores s1 on s.store_id = s1.store_id
group by s1.store_id
having sum(s.quantity*p.price) < (
       select avg(store_total)
       from (
             select sum(s.quantity*p.price) as store_total
             from sales s 
             join products p on s.product_id = p.product_id
             group by s.store_id) as t)
order by total_revenue;
       
-- 19. Revenue contribution % by each category.

select c.category_name,
       round(sum(s.quantity*p.price)*100 /
       (select sum(s1.quantity*p1.price)
       from sales s1 
       join products p1 on s1.product_id = p1.product_id
       ),2) as revenue_percentage
from category c 
join products p on c.category_id = p.category_id
join sales s on p.product_id = s.product_id
group by c.category_name
order by revenue_percentage desc;

-- 20. Detect seasonal patterns in Apple product sales.

select month(sale_date) as sales_month,
       sum(quantity) as total_units_sold
from sales 
group by sales_month
order by sales_month;

-- 21. Which product launch period performed best in first 3 months?

with launch_sales as(
select p.product_id,
       p.product_name,
       sum(s.quantity) as first_3_month_units 
from products p 
join sales s on p.product_id = s.product_id
where s.sale_date between p.launch_date and date_add(p.launch_date,interval 3 month)
group by p.product_id,p.product_name
)
select product_id,
       product_name,
       first_3_month_units
from launch_sales 
order by first_3_month_units desc
limit 1;

-- 22. Store-wise productivity (revenue per product sold).

select s.store_id,
       round(sum(s1.quantity*p.price) / sum(s1.quantity),2) as revenue_per_units
from stores s 
join sales s1 on s.store_id = s1.store_id
join products p on s1.product_id = p.product_id
group by s.store_id
order by revenue_per_units desc;

-- 23. Which city shows highest warranty issues per 1,000 units sold?

WITH city_sales AS (
    SELECT 
        st.city,
        SUM(sa.quantity) AS total_units
    FROM sales sa
    JOIN stores st 
        ON sa.store_id = st.store_id
    GROUP BY st.city
),
city_claims AS (
    SELECT 
        st.city,
        COUNT(*) AS total_claims
    FROM warranty w
    JOIN sales sa 
        ON w.sale_id = sa.sale_id
    JOIN stores st 
        ON sa.store_id = st.store_id
    GROUP BY st.city
)
SELECT 
    cs.city,
    cs.total_units,
    cc.total_claims,
    ROUND(
        cc.total_claims * 1000.0 / cs.total_units,
        2
    ) AS claims_per_1000_units
FROM city_sales cs
JOIN city_claims cc 
    ON cs.city = cc.city
ORDER BY claims_per_1000_units DESC
LIMIT 1;