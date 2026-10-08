/* ============================================================
   BikeStore SQL Analysis
   Database : Final_project (BikeStores schema: sales + production)
   Order status codes: 1 = Pending, 2 = Processing, 3 = Rejected, 4 = Completed
   ============================================================ */

USE Final_project;
GO

-- Q1. Which bike is the most expensive?
SELECT TOP 1 WITH TIES
       p.product_name,
       MAX(i.list_price) AS price
FROM sales.order_items AS i
JOIN production.products AS p ON i.product_id = p.product_id
GROUP BY p.product_name
ORDER BY price DESC;

-- Q2. How many customers does BikeStore have?
SELECT COUNT(customer_id) AS count_of_customers
FROM sales.customers;

-- Q3. How many stores does BikeStore have?
SELECT COUNT(store_id) AS count_of_stores
FROM sales.stores;

-- Q4. Total price spent per order (after discount)
SELECT order_id,
       SUM(list_price * quantity * (1 - discount)) AS total_price
FROM sales.order_items
GROUP BY order_id;

-- Q5. Revenue per store (rejected orders excluded)
SELECT st.store_name,
       ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 1) AS revenue
FROM sales.order_items AS oi
JOIN sales.orders AS o  ON oi.order_id = o.order_id
JOIN sales.stores AS st ON o.store_id = st.store_id
WHERE o.order_status <> 3
GROUP BY st.store_name
ORDER BY revenue DESC;

-- Q6. Which category is the most sold (by units)?
-- FIX: original summed list_price and sorted by category name instead of the total
SELECT TOP 1 WITH TIES
       c.category_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM production.categories AS c
JOIN production.products AS p    ON c.category_id = p.category_id
JOIN sales.order_items AS oi     ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY total_quantity_sold DESC;

-- Q7. Which categories have the most rejected orders?
-- FIX: count distinct orders instead of order-item rows
SELECT TOP 3
       c.category_name,
       COUNT(DISTINCT o.order_id) AS rejected_orders
FROM production.categories AS c
JOIN production.products AS p ON c.category_id = p.category_id
JOIN sales.order_items AS oi  ON p.product_id = oi.product_id
JOIN sales.orders AS o        ON oi.order_id = o.order_id
WHERE o.order_status = 3
GROUP BY c.category_name
ORDER BY rejected_orders DESC;

-- Q8. Which bike is the least sold?
-- FIX: removed the arbitrary "<= 10" filter; LEFT JOIN keeps products that were never sold
SELECT TOP 1 WITH TIES
       p.product_name,
       COALESCE(SUM(oi.quantity), 0) AS total_quantity
FROM production.products AS p
LEFT JOIN sales.order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity ASC;

-- Q9. Full name of customer 259
SELECT customer_id,
       first_name + ' ' + last_name AS full_name
FROM sales.customers
WHERE customer_id = 259;

-- Q10. What did customer 259 buy, when, and what is the order status?
SELECT c.customer_id,
       p.product_name,
       o.order_date,
       CASE o.order_status
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Processing'
            WHEN 3 THEN 'Rejected'
            WHEN 4 THEN 'Completed'
       END AS order_status
FROM sales.customers AS c
JOIN sales.orders AS o      ON c.customer_id = o.customer_id
JOIN sales.order_items AS i ON o.order_id = i.order_id
JOIN production.products AS p ON i.product_id = p.product_id
WHERE c.customer_id = 259;

-- Q11. Which staff member processed the orders of customer 259, and from which store?
-- FIX: join on orders.staff_id (original joined on store_id and returned every staff member of the store)
SELECT o.order_id,
       f.first_name + ' ' + f.last_name AS staff_name,
       s.store_name
FROM sales.orders AS o
JOIN sales.staffs AS f ON o.staff_id = f.staff_id
JOIN sales.stores AS s ON o.store_id = s.store_id
WHERE o.customer_id = 259;

-- Q12. How many staff (and managers) does BikeStore have?
SELECT COUNT(*) AS count_of_staff,
       COUNT(DISTINCT manager_id) AS count_of_managers
FROM sales.staffs;

-- Q13. Which brand is the most liked? (defined as highest total quantity sold)
-- FIX: original ordered by brand_name (column 1) instead of the sales measure
SELECT TOP 1 WITH TIES
       b.brand_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM production.brands AS b
JOIN production.products AS p ON p.brand_id = b.brand_id
JOIN sales.order_items AS oi  ON p.product_id = oi.product_id
GROUP BY b.brand_name
ORDER BY total_quantity_sold DESC;

-- Q14. How many categories are there, and which one is the least liked?
SELECT COUNT(*) AS total_categories
FROM production.categories;

SELECT TOP 1 WITH TIES
       c.category_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM production.categories AS c
JOIN production.products AS p ON c.category_id = p.category_id
JOIN sales.order_items AS oi  ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY total_quantity_sold ASC;

-- Q15. Which store has the most stock of the most liked brand?
-- FIX: original joined stocks on store_id only (no product match), hard-coded 'Trek', and sorted by store name
WITH top_brand AS (
    SELECT TOP 1 p.brand_id
    FROM production.products AS p
    JOIN sales.order_items AS oi ON p.product_id = oi.product_id
    GROUP BY p.brand_id
    ORDER BY SUM(oi.quantity) DESC
)
SELECT TOP 1
       st.store_name,
       SUM(sk.quantity) AS units_in_stock
FROM production.stocks AS sk
JOIN production.products AS p ON sk.product_id = p.product_id
JOIN top_brand AS tb          ON p.brand_id = tb.brand_id
JOIN sales.stores AS st       ON sk.store_id = st.store_id
GROUP BY st.store_name
ORDER BY units_in_stock DESC;

-- Q16. Discounted price of product 259
-- FIX: original returned only the discount; now the price after discount is calculated
SELECT DISTINCT
       p.product_id,
       p.product_name,
       i.list_price,
       i.discount,
       i.list_price * (1 - i.discount) AS discounted_price
FROM production.products AS p
JOIN sales.order_items AS i ON p.product_id = i.product_id
WHERE p.product_id = 259;

-- Q17. Details of product 44
SELECT p.product_name,
       SUM(i.quantity) AS total_quantity_sold,
       p.list_price,
       c.category_name,
       p.model_year,
       b.brand_name
FROM production.products AS p
JOIN production.categories AS c ON p.category_id = c.category_id
JOIN production.brands AS b     ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items AS i ON i.product_id = p.product_id
WHERE p.product_id = 44
GROUP BY p.product_name, p.list_price, c.category_name, p.model_year, b.brand_name;

-- Q18. Zip code of the store in CA
SELECT state, zip_code
FROM sales.stores
WHERE state = 'CA';

-- Q19. How many states does BikeStore operate in?
-- FIX: COUNT(DISTINCT state) instead of counting store rows
SELECT COUNT(DISTINCT state) AS count_of_states
FROM sales.stores;

-- Q20. Children bicycles sold in the last 8 months of the data
-- (relative to the latest order date in the dataset, not today's date)
SELECT c.category_name,
       SUM(i.quantity) AS quantity
FROM sales.orders AS o
JOIN sales.order_items AS i   ON i.order_id = o.order_id
JOIN production.products AS p ON p.product_id = i.product_id
JOIN production.categories AS c ON c.category_id = p.category_id
WHERE c.category_name = 'Children Bicycles'
  AND o.order_date >= DATEADD(MONTH, -8, (SELECT MAX(order_date) FROM sales.orders))
GROUP BY c.category_name;

-- Q21. Shipped date of the order(s) of customer 523
SELECT c.customer_id,
       o.order_id,
       o.shipped_date
FROM sales.customers AS c
JOIN sales.orders AS o ON c.customer_id = o.customer_id
WHERE c.customer_id = 523;

-- Q22. How many orders are still pending?
SELECT COUNT(*) AS count_of_pending_orders
FROM sales.orders
WHERE order_status = 1;

-- Q23. Category and brand of "Electra White Water 3i - 2018"
SELECT p.product_name,
       c.category_name,
       b.brand_name
FROM production.products AS p
JOIN production.categories AS c ON p.category_id = c.category_id
JOIN production.brands AS b     ON p.brand_id = b.brand_id
WHERE p.product_name = 'Electra White Water 3i - 2018';