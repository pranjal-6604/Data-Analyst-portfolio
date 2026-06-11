-- BASIC ANALYTICS
CREATE DATABASE Ecommerce_project;
USE Ecommerce_project;

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
name VARCHAR(50),
city VARCHAR(50),
signup_date date
);

CREATE TABLE products (
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50)
);

CREATE TABLE orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
status VARCHAR(20)
);

CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
price DECIMAL(10,2)
);

CREATE TABLE payments (
payment_id INT PRIMARY KEY,
order_id INT,
payment_date DATE,
amount DECIMAL(10,2)
);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


INSERT INTO customers VALUES
('1','Amit Sharma','Delhi','2023-01-10'),
('2','Neha Verma','Mumbai','2023-02-15'),
('3','Ravi Kumar','Banglore','2023-03-20'),
('4','Priya Singh','Chennai','2023-04-05'),
('5','Arjun Mehta','Pune','2023-05-12');

SELECT * FROM customers;

INSERT INTO products VALUES
('101','Laptop','Electronics'),
('102','Mobile','Electronics'),
('103','Shoes','Fashion'),
('104','Watch','Accessories'),
('105','Headphones','Electronics');

SELECT * FROM products;

INSERT INTO orders VALUES
('1001','1','2023-06-01','Delivered'),
('1002','2','2023-06-05','Pending'),
('1003','3','2023-06-10','Shipped'),
('1004','4','2023-06-15','Delivered'),
('1005','5','2023-06-20','Cancelled');

SELECT * FROM orders;

DROP TABLE order_items;

CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
price DECIMAL(10,2)
);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);


INSERT INTO order_items VALUES
(1,1001,101,1,60000),
(2,1001,105,2,2000),
(3,1002,102,1,25000),
(4,1003,103,2,3000),
(5,1004,104,1,5000);

SELECT * FROM order_items
select database();
set foreign_key_checks = 0;
truncate table payments;
set foreign_key_checks =1;

INSERT  INTO payments(payment_id,order_id,payment_date,amount) VALUES
(1,1001,'2023-06-02',64000),
(2,1002,'2023-06-06',25000),
(3,1003,'2023-06-11',6000),
(4,1004,'2023-06-16',5000);

SELECT * FROM payments;
USE ecommerce_project;

-- Question: Get all orders with customer name and city
SELECT o.order,c.name,c.city,o.order_date,o.status
FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id;

-- Question: Find all orders and their payment details(including unpaid orders)
SELECT o.order_id,p.amount,p.payment_date
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id;

-- Question: Calculate total revenue
SELECT SUM(amount) AS total_revenue
FROM payments;

-- Question: Find total revenue per customer
SELECT c.name, SUM(amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.name

-- Question: Find customers who spent more than 10000
SELECT c.name, SUM(amount) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.name
HAVING SUM(p.amount)>10000;

-- Question: Find orders that are not paid
SELECT o.order_id
from orders o
LEFT JOIN payments p on o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- DATA CLEANING

-- CREATING DIRTY DATA
INSERT INTO customers VALUES (6,'amit sharma','delhi','2023-06-01'), -- duplicate name,wrong case,extra space
(7,'Neha Verma',NULL,'2023-06-01'),   -- NULL city
(8, 'Ravi Kumar','Banglore',NULL);    -- NULL date

SELECT * FROM customers;

-- HANDLING NULL VALUES
UPDATE customers
SET city = 'Unknown'
WHERE city is NULL;

-- FIXING INCONSISTENT TEXT
UPDATE customers
SET signup_date = '2023-01-01'
WHERE signup_date is NULL;

UPDATE customers 
SET city = 'Delhi'
WHERE LOWER(TRIM(city)) = 'delhi';

-- HANDLING DUPLICATES
SELECT name,city,count(*)
from customers
group by name,city
Having count(*)>1;

DELETE FROM customers
WHERE customer_id =6;

SELECT COUNT(*) FROM customers;

USE ecommerce_project;

-- CORE + ADVANCED SQL

-- Question: find the customer who spent the highest total amount
SELECT c.customer_id, c.name,SUM(p.amount)AS total_spent
FROM customers c
JOIN orders o on c.customer_id = o.customer_id
join payments p on o.order_id = p.order_id
GROUP BY customer_id,c.name
order by total_spent DESC
LIMIT 1;

-- Question: Calculate total revenue per month
select DATE_FORMAT(payment_date,'%Y-%m') AS month,
sum(amount) as monthly_revenue
from payments
group by month;

-- Question: Find products that were never ordered
select p.product_id,p.product_name
from products p
left join order_items oi on p.product_id = oi.product_id
where oi.product_id is null;

-- Question: Find average order value
select avg(order_total) as avg_order_value
from(select order_id,sum(quantity*price) as order_total
from order_items
group by order_id
) as order_summary;

-- Question: find customers who never placed any order
select c.customer_id,c.name
from customers c
left join orders o
on c.customer_id = o.customer_id
where o.customer_id is null;

-- Question: Rank customers based on total spending
select c.customer_id, c.name,sum(p.amount)as total_spent,
rank()over(order by sum(p.amount)desc) as rank_position
from customers c
join orders o on c.customer_id = o.customer_id
join payments p on o.order_id = p.order_id
group by c.customer_id,c.name;

-- Question: find total revenue generated per product category 
select pr.category, sum(oi.quantity*oi.price)as revenue 
from order_items oi
join products pr on oi.product_id = pr.product_id
group by pr.category;

SELECT *FROM customers;
select *from orders;
select*from order_items;
select*from products;
select*from payments;

use ecommerce_project;

-- adding coulumn
ALTER TABLE order_items
ADD column cost_price decimal(10,2)default 0;

-- cleaning data cost price data
update order_items
set cost_price = 0
where cost_price is null;

-- ADVANCED ANALYTICS

-- PROFIT 
select order_id,quantity*price as revenue,quantity*cost_price as cost,
(quantity*price)-(quantity*cost_price)as profit
from order_items;


-- CLV(CUSTOMER VALUE)
select c.customer_id,c.name, sum((oi.price-oi.cost_price)*oi.quantity)as lifetime_value
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_id,c.name;

-- MONTHLY PROFIT
select date_format (o.order_date,'%y-%m')as month,
sum((oi.price-oi.cost_price)*oi.quantity)as profit
from orders o
join order_items oi on o.order_id = oi.order_id
group by month
order by month;







