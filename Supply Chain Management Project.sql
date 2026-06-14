

create database scdb;
use  scdb;


#1.total_Revenue
select sum(revenue) AS Total_Revenue
FROM Fact_orders;

#2.On_Time_Orders
select count(order_id) as on_time_orders
from fact_orders 
where delivery_status = 'on-time';

#3.Delayed_Orders_Count
select count(order_id) as Delayed_Orders
from Fact_orders
where delivery_status =' Delayed';


#4.Gross_Profit
select sum(revenue - cogs) as gross_profit
from fact_orders;

#5.Gross_Margin
select round((sum(revenue - cogs)/sum(revenue))*100,2) as Gross_Margin_Percentage
from fact_orders;

#6.monthly_Revenue_Trend
select year(order_date) as Year,
month(order_date) as Month,
sum(revenue) as Total_Revenue
from fact_orders 
group by 
year(order_date),
month(order_date)
order by Year,Month;

#7.revenue by customer segment
select customer_segment,
sum(f.Revenue) as total_Revenue
from fact_Orders f 
join dim_customer c
on f.Customer_ID = C.Customer_ID
Group by customer_segment
order by Total_Revenue Desc;

#8.Revenue by Region & Product Category
select
c.customer_Region,
p.category,
sum(f.revenue)as Revenue
From fact_orders f
join dim_customer c
on f.customer_id = c.customer_id

join dim_product p 
on f.product_id = p.product_id

group by 
c.customer_region,
p.category

order by Revenue desc;

#9 Delayed orders analysis - CTE

WITH Delayed_Orders AS (

    SELECT 
        f.Order_ID,
        c.Customer_Region,
        f.Carrier,
        f.Delivery_Status

    FROM fact_orders f

    JOIN dim_customer c
    ON f.Customer_ID = c.Customer_ID

    WHERE f.Delivery_Status = 'Delayed'
)

SELECT 
    Customer_Region,
    COUNT(Order_ID) AS Total_Delayed_Orders

FROM Delayed_Orders

GROUP BY Customer_Region

ORDER BY Total_Delayed_Orders DESC;

#10. top performing carrier
SELECT 
    Carrier,
    COUNT(Order_ID) AS Total_Orders

FROM fact_orders

GROUP BY Carrier

ORDER BY Total_Orders DESC;

#11. Most Profitable product Category
SELECT 
    p.Category,

    SUM(f.Revenue - f.COGS)
    AS Profit

FROM fact_orders f

JOIN dim_product p
ON f.Product_ID = p.Product_ID

GROUP BY p.Category

ORDER BY Profit DESC;

#12. Rank regions by Revenue

WITH Region_Revenue AS (

    SELECT 
        c.Customer_Region,
        SUM(f.Revenue) AS Revenue

    FROM fact_orders f

    JOIN dim_customer c
    ON f.Customer_ID = c.Customer_ID

    GROUP BY c.Customer_Region
)

SELECT 
    Customer_Region,
    Revenue,

    DENSE_RANK() OVER(
        ORDER BY Revenue DESC
    ) AS Revenue_Rank

FROM Region_Revenue;

#13. Top 5 Customers by Revenue

SELECT 
    c.Customer_ID,

    SUM(f.Revenue) AS Total_Revenue

FROM fact_orders f

JOIN dim_customer c
ON f.Customer_ID = c.Customer_ID

GROUP BY c.Customer_ID

ORDER BY Total_Revenue DESC

LIMIT 5;

#top customer segment by revenue

SELECT 
    c.Customer_Segment,

    SUM(f.Revenue) AS Total_Revenue

FROM fact_orders f

JOIN dim_customer c
ON f.Customer_ID = c.Customer_ID

GROUP BY c.Customer_Segment

ORDER BY Total_Revenue DESC;


#14 Top 5 product wise order count & inventory
SELECT 
    f.Product_ID,

    COUNT(f.Order_ID) AS Total_Orders,

    AVG(i.Days_Of_Supply) AS Avg_DOS

FROM fact_orders f

JOIN fact_inventory i
ON f.Product_ID = i.Product_ID

GROUP BY f.Product_ID

ORDER BY Total_Orders DESC
limit 5;
# 15. supplier Delay Percentage

SELECT 
    s.Supplier_Name,

    COUNT(*) AS Total_Orders,

    COUNT(
        CASE
            WHEN f.Delivery_Status = 'Delayed'
            THEN 1
        END
    ) AS Delayed_Orders,

    ROUND(
        COUNT(
            CASE
                WHEN f.Delivery_Status = 'Delayed'
                THEN 1
            END
        ) * 100.0
        /
        COUNT(*),
        2
    ) AS Delay_Percentage

FROM fact_orders f

JOIN dim_supplier s
ON f.Supplier_ID = s.Supplier_ID

GROUP BY s.Supplier_Name

ORDER BY Delay_Percentage DESC;