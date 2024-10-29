Create database Bike_Store;
use bike_store;

select * from brands;
select * from categories;
select * from customers;
select * from order_items;
select * from orders; 
select * from products;
select * from staffs;
select * from stocks;
select * from stores;

-- Brand Wise Quantity Sold
with sales_report as (
select 
	o. order_id, 
    o. item_id,
    o. product_id,
    o. quantity, 
    o. list_price,
    p. brand_id,
    p. category_id,
    c. category_name, 
    b. brand_name
from 
	order_items as o 
inner join
	products as p
on
	o. product_id = p. product_id
inner join
	categories as c 
on
	p.category_id = c.category_id
inner join
	brands as b
on
	b. brand_id = p. brand_id)

select 
	brand_name,
    sum(quantity) as total_QTY_sold
from sales_report
group by brand_name
order by total_QTY_sold desc
; 

-- Category Wise Quantity Sold
with sales_report as (
select 
	o. order_id, 
    o. item_id,
    o. product_id,
    o. quantity, 
    o. list_price,
    p. brand_id,
    p. category_id,
    c. category_name, 
    b. brand_name
from 
	order_items as o 
inner join
	products as p
on
	o. product_id = p. product_id
inner join
	categories as c 
on
	p.category_id = c.category_id
inner join
	brands as b
on
	b. brand_id = p. brand_id)
select 
	category_name,
    sum(quantity) as total_QTY_sold
    from sales_report
group by category_name
order by total_QTY_sold desc
;

-- Year wise orders 
select 
	year(order_date) as order_year,
    count(order_id) as total_received_orders
from orders 
group by order_year 
order by order_year
;

-- Month Wise Orders for a Particular Year
select
	month (order_date) as order_month,
    count(order_id) as received_order
from orders
where 
	order_date = 2016
group by 
	order_month
order by 
	order_month asc;

-- Average delay between required date and shipping date
with delay_analysis as (
select 
	order_id,
    order_date, 
    required_date,
    shipped_date,
	datediff(required_date, shipped_date) as time_difference 
from orders)
select 
	avg(time_difference) as Days_Delay
    from delay_analysis
;

-- Top 10 Highest Purchasing Customers
with top_customers as (
select
	o. order_id,
    o. customer_id,
    c. first_name,
    c. last_name 
from
	orders o
join
	customers c 
on
	o. customer_id = c. customer_id)

select 
    first_name,
    count(order_id) as totalOrders
from top_customers
group by first_name
order by totalOrders desc  
limit 10
    ;																							

-- Staff performance analysis based on orders handling, avg. delay, sales 
with staff_performance as (
select 
	o. order_id,
    o. customer_id,
    o. order_date,
    o. required_date,
    o. shipped_date,
    o. staff_id,
    s. first_name,
    s. last_name,
    i. product_id,
    i. quantity,
    i. list_price
from
	orders o
join
	staffs s 
on
	o.staff_id = s.staff_id
join
	order_items i 
on
	o.order_id = i.order_id )
select 
	staff_id,
    first_name,
    last_name,
	avg(datediff(order_date, shipped_date))	as Avg_Delay_OrderToShipment,
    avg(datediff(required_date, shipped_date)) as Avg_Delay_RequiredToShipment,
    count(order_id) as OrderHandling, 
	round(sum(list_price),2) as TotalSales,
	round(round(sum(list_price),2)/ count(order_id),2) as SalesPerOrder
	from staff_performance
group by staff_id, first_name, last_name
order by orderHandling desc
    ;
    
-- Inventory stock analysis by category wise
with stocks_analysis as (
select
	s. store_id,
    s. product_id,
    s. quantity,
    t. store_name,
    p. product_name,
    p. category_id,
    c. category_name
from
	stocks s
join
	stores t 
on
	s.store_id= t.store_id
join
	products p
on
	s.product_id= p.product_id
join
	categories c 
on
	p. category_id= c.category_id)
    
select 
category_name,
count(category_name) as inTotal
from stocks_analysis
group by category_name
order by inTotal desc
;

-- Inventory stock analysis product wise
with stocks_analysis as (
select
	s. store_id,
    s. product_id,
    s. quantity,
    t. store_name,
    p. product_name,
    p. category_id,
    c. category_name
from
	stocks s
join
	stores t 
on
	s.store_id= t.store_id
join
	products p
on
	s.product_id= p.product_id
join
	categories c 
on
	p. category_id= c.category_id)
    
select 
	product_name, 
    count(product_name) as InStock
		from stocks_analysis
group by product_name
order by InStock desc
;

-- Inventory stock analysis by Outlet Wise
with stocks_analysis as (
select
	s. store_id,
    s. product_id,
    s. quantity,
    t. store_name,
    p. product_name,
    p. category_id,
    c. category_name
from
	stocks s
join
	stores t 
on
	s.store_id= t.store_id
join
	products p
on
	s.product_id= p.product_id
join
	categories c 
on
	p. category_id= c.category_id)

select 
	Category_Name,
    count(category_name) as No_of_QTY
    from stocks_analysis
WHERE
		store_name = "Baldwin Bikes"
group by
	category_name
order by
	No_of_QTY desc
    ;

-- Volume of Customers by City Wise
select 
	city,
    count(city) No_of_Customers
 from customers
 group by city
 order by No_of_Customers desc
 ;
 
 -- Bike model wise product sales
 with Bike_ModelSales as (
 select
	o. order_id,
    o. item_id,
    o. product_id,
    o. quantity,
    o. list_price,
    p. model_year
from
	order_items o
join
	products p
on
	o.product_id= p.product_id)
select 
	model_year,
	round(sum(list_price),0) as Sales
    from bike_ModelSales
group by model_year
order by Sales desc
    ;

-- Total discount by product wise 
with discount_analysis as (
select 
    o. product_id,
    o. quantity,
    o. list_price,
    o. discount,
    p. product_name
from
	order_items o
join
	products p
on
	o.product_id=p.product_id)
select 
	product_name,
	round(sum(discount),2)	 as Total_Discount_Percentage
		from discount_analysis
group by product_name
order by Total_Discount_Percentage desc
    ;
