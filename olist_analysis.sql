-- Query 1: Seller Performance Scorecard
USE olist;

SELECT 
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(AVG(r.review_score), 2) as avg_rating,
    ROUND(SUM(oi.price), 2) as total_revenue
FROM order_items oi
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY avg_rating DESC
LIMIT 20;

-- Query 2: Late Delivery Risk Analysis
SELECT 
    oi.seller_id,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN o.order_id END) as late_deliveries,
    ROUND(COUNT(DISTINCT CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN o.order_id END) * 100.0 / COUNT(DISTINCT o.order_id), 2) as late_delivery_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
HAVING late_delivery_pct > 50 AND total_orders >= 10
ORDER BY late_delivery_pct DESC
LIMIT 20;

-- Query 3: Revenue Trend Over Time
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(oi.price), 2) as total_revenue,
    ROUND(AVG(oi.price), 2) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month ASC;

-- Query 4: Customer Satisfaction by State
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(r.review_score), 2) as avg_satisfaction,
    ROUND(SUM(oi.price), 2) as total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_reviews r ON o.order_id = r.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_orders DESC;