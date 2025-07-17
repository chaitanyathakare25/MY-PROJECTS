-- Create customers table
create database ecommerce;
show databases;
use ecommerce;

CREATE TABLE customers (
  CustomerID INT PRIMARY KEY,
  Name VARCHAR(100),
  Email VARCHAR(100),
  City VARCHAR(50),
  RegistrationDate DATE
);

-- Insert customers
INSERT INTO customers VALUES 
  (1, 'Amit Sharma', 'amit@example.com', 'Delhi',     '2023-01-10'),
  (2, 'Priya Mehta', 'priya@example.com', 'Mumbai',    '2023-01-12'),
  (3, 'Rahul Verma', 'rahul@example.com', 'Bangalore','2023-02-05'),
  (4, 'Sneha Rao',   'sneha@example.com', 'Hyderabad','2023-03-01'),
  (5, 'Ankit Jain',  'ankit@example.com', 'Chennai',   '2023-03-10');

-- Create products table
CREATE TABLE products (
  ProductID INT PRIMARY KEY,
  ProductName VARCHAR(100),
  Category VARCHAR(50),
  Price DECIMAL(10,2),
  Stock INT
);

-- Insert products
INSERT INTO products VALUES 
  (1, 'Bluetooth Speaker', 'Electronics', 1500.00, 50),
  (2, 'Wireless Mouse',    'Electronics',  600.00,100),
  (3, 'Cotton T-Shirt',    'Clothing',     400.00,200),
  (4, 'Jeans',             'Clothing',    1200.00, 80),
  (5, 'Notebook',          'Stationery',    50.00,500);

-- Create orders table
CREATE TABLE orders (
  OrderID    INT PRIMARY KEY,
  CustomerID INT,
  OrderDate  DATE,
  Status     VARCHAR(20),
  FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);

-- Insert orders
INSERT INTO orders VALUES 
  (1, 1, '2023-03-15', 'Delivered'),
  (2, 2, '2023-03-16', 'Cancelled'),
  (3, 3, '2023-03-17', 'Delivered'),
  (4, 4, '2023-03-18', 'Pending'),
  (5, 5, '2023-03-19', 'Delivered');

-- Create order details table
CREATE TABLE orderdetails (
  OrderDetailID INT PRIMARY KEY,
  OrderID       INT,
  ProductID     INT,
  Quantity      INT,
  FOREIGN KEY (OrderID)   REFERENCES orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

-- Insert order details
INSERT INTO orderdetails VALUES
  (1, 1, 1, 2),
  (2, 1, 2, 1),
  (3, 3, 3, 3),
  (4, 5, 4, 1),
  (5, 5, 5,10);

-- Create payments table
CREATE TABLE payments (
  PaymentID   INT PRIMARY KEY,
  OrderID     INT,
  Amount      DECIMAL(10,2),
  PaymentMode VARCHAR(20),
  PaymentDate DATE,
  FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

-- Insert payments
INSERT INTO payments VALUES
  (1, 1, 3600.00, 'Credit Card', '2023-03-15'),
  (2, 3, 1200.00, 'UPI',         '2023-03-17'),
  (3, 5, 1700.00, 'Wallet',      '2023-03-19');
  
  
 -- 1 List all customers and their city.
 select name , city from customers;
  
-- 2 Display all products with price less than ₹1000.
select productname, price from products where price < 1000;

-- 3 Find all orders placed in March 2023.
select orderid,orderdate from orders where orderdate between "2023-03-01" and "2023-03-31";


-- 4 Count total number of products in each category.
select category, sum(stock) from products group by category;

-- INSIGHTS: Electronics-150, Clothing-280,  Stationery-500

-- 5 Retrieve orders that are not yet delivered.
select 
orderid ,
status 
from orders 
where status in ("pending");

--  6 Show total quantity ordered per product.
select
products.productid,
products.productname,
sum(orderdetails.quantity) 
from orderdetails 
join products on products.productid = orderdetails.productid
group by productid;

-- INSIGHTS : NOTEBOOK IS THE MOST POPULAR PRODUCT BASED ON ORDER QUANTITY(10UNITS)

-- 7  Display the stock left for each product.

select p.productid,
p.productname,
p.stock ,
od.quantity as quantity,
p.stock - od.quantity as leftstock 
from products p 
join orderdetails as od on p.productid = od.productid
group by p.productid, p.productname, p.stock , od.quantity;

-- INSIGHTS : THIS DATA WILL BE HELPFUL FOR RESTOCK THE PRODUCTS

-- 8 Get customer names who placed an order.
select c.name ,
o.orderid
from 
customers as c
join orders as o on  o.customerid = c.customerid
where orderid is null; 


-- 9 Find the number of orders per customer.
select c.name ,
count(o.orderid)
from 
customers as c
join orders as o on  o.customerid = c.customerid
group by name;





-- 10 Calculate total amount paid per order.
select sum(py.amount),
py.orderid
from payments as py 
group by orderid;




-- 11 List customers who have never placed an order.
select c.name, 
o.status 
from customers as c 
join orders as o on o.customerid = c.customerid
where o.status = "cancelled";

-- INSIGHTS: PRIYA MEHTA NEVER PLACE THE ORDER

-- 12 Calculate the average payment amount.
select round(avg(amount),2) from payments;

-- 13 Find total revenue generated from delivered orders.
select 
sum(py.amount),
py.orderid,
o.status
from payments as py 
join orders as o on o.orderid = py.orderid
where o.status in ("delivered") group by orderid;

-- 14 List products that have never been ordered.
select p.ProductID,
p.ProductName,
p.Category,
p.Price,
p.Stock
from products p
join orderdetails od
on p.ProductID = od.ProductID
WHERE od.ProductID IS NULL;

-- 15 Count how many times each product was sold.
select 
p.ProductID,
p.ProductName,
sum(od.Quantity) as TotalUnitsSold
from orderdetails od
join  products p ON od.ProductID = p.ProductID
join orders o ON od.OrderID = o.OrderID
where o.Status = 'Delivered'  
group by p.ProductID, p.ProductName
order by TotalUnitsSold DESC;



-- 16 Show customers who made payments using UPI.
select c.name,
o.orderid,
p.paymentmode 
from customers c
 join orders as o on o.customerid = c.customerid
join payments as p on p.orderid = o.orderid
where  p.paymentmode ="upi";

-- INSIGHTS: RAVI VAERMA IS THE CUSTOMERS MADE PAYMENTS BY USING UPI


-- 17 Get the most popular product (based on quantity sold).
select
products.productid,
products.productname,
sum(orderdetails.quantity) 
from orderdetails 
join products on products.productid = orderdetails.productid
group by productid,productname;

-- INSIGHTS : NOTEBOOK IS THE MOST POPULAR PRODUCT BASED ON ORDER QUANTITY(10UNITS)

-- 18 List the top 3 customers by total spending.
select 
c.name, 
sum(py.amount) as total_spendings
from customers as c
join orders as o on o.customerid = c.customerid
join payments as py on py.orderid = o.orderid
group by c.name order by total_spendings desc;


-- 19 Calculate average basket size (items per order).
SELECT 
    ROUND(SUM(od.Quantity)  / COUNT(DISTINCT od.OrderID)) AS AvgBasketSize
FROM 
    orderdetails od
JOIN 
    orders o ON od.OrderID = o.OrderID
WHERE 
    o.Status = 'Delivered';



-- 20 Display monthly revenue for March 2023.
Select
sum(amount) as monthly_revenue
from payments 
where month(PaymentDate) = 3;


-- 21  Identify categories generating the most revenue.

select p.category as category,
sum(py.amount) as revenue
from payments as py 
join orderdetails as od on od.orderid = py.orderid
join products as p on  p.productid = od.productid
group by category order by revenue desc;

-- INSIGHTS : ELECTRONICS CATEGORY HAVE MOST REVENUE

-- 22 Find the cancellation rate of orders.

SELECT  COUNT(*) AS total_orders, 
COUNT(CASE WHEN o.status = 'cancelled' THEN 1 END) AS cancelled_orders,  
ROUND(COUNT(CASE WHEN o.status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*),2 ) AS cancellation_rate_percentage
FROM orders AS o;

-- INSIGHTS: THE CANCELLATION RATE OF ORDERS IS 20.


-- 23 Analyze customer retention: who placed multiple orders.
SELECT 
c.CustomerID,
c.Name,
COUNT(o.OrderID) AS OrderCount
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
WHERE o.Status = 'Delivered'  
GROUP BY c.CustomerID, c.Name
HAVING COUNT(o.OrderID) > 1
ORDER BY OrderCount DESC;




-- 24 Determine the most active cities in terms of orders.
select 
c.City,
count(o.OrderID) AS TotalOrders
from customers c
join orders o ON c.CustomerID = o.CustomerID
where o.Status = 'Delivered'  
group by  c.City
order by TotalOrders DESC;

-- 25 Compare order quantity vs. available stock for restocking decisions.
select p.productid,
p.productname,
p.stock as available_stock ,
od.quantity as order_quantity,
p.stock - od.quantity as leftstock 
from products p 
join orderdetails as od on p.productid = od.productid
group by p.productid, p.productname, p.stock , od.quantity;

-- 26 Analyze peak ordering day (day with most orders).
select
c.customerID,
c.Name,
count(o.OrderID) as OrderCount
from customers c
join orders o 
ON c.CustomerID = o.CustomerID
group by  c.CustomerID, c.Name
having count(o.OrderID) > 1;


-- 27 Find which payment mode is used most frequently.
select paymentmode, 
count(paymentmode) 
from payments 
group by paymentmode 
order by paymentmode desc;

-- INSIGHTS : ALL THE PAYMENTS MODE HAVE SAME FREQUENCY


-- 28 Rank customers based on total amount spent

select c.name, 
o.orderid, 
sum(p.amount)  as total_spent,
rank()over(order by sum(p.amount)  desc) as ranks
from customers as c
join orders as o on o.customerid = c.customerid
join payments as p on p.orderid = o.ordered
group by c.name, o.orderid ;

-- INSIGHTS: AMIT SHARMA IS THE RANK 1 CUSTOMER BASED ON MOST AMOUNT SPENT WE CAN REWARDS TO THEM





