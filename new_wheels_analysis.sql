    ROUND(AVG(rating), 2) AS average_rating
FROM (
    SELECT
        quarter_number,
        CASE
            WHEN customer_feedback = 'Very Bad' THEN 1
            WHEN customer_feedback = 'Bad' THEN 2
            WHEN customer_feedback = 'Okay' THEN 3
            WHEN customer_feedback = 'Good' THEN 4
            WHEN customer_feedback = 'Very Good' THEN 5
        END AS rating
    FROM order_t
) AS feedback_rating
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Question 5: Percentage distribution of customer feedback by quarter
-- ============================================================
SELECT
    quarter_number,
    ROUND(
        COUNT(CASE WHEN customer_feedback = 'Very Bad' THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS very_bad_pct,
    ROUND(
        COUNT(CASE WHEN customer_feedback = 'Bad' THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS bad_pct,
    ROUND(
        COUNT(CASE WHEN customer_feedback = 'Okay' THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS okay_pct,
    ROUND(
        COUNT(CASE WHEN customer_feedback = 'Good' THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS good_pct,
    ROUND(
        COUNT(CASE WHEN customer_feedback = 'Very Good' THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS very_good_pct
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Question 6: Number of orders by quarter
-- ============================================================
SELECT
    quarter_number,
    COUNT(order_id) AS total_orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Question 7: Net revenue and quarter-over-quarter percentage change
-- Net revenue = quantity * vehicle_price * (1 - discount)
-- ============================================================
SELECT
    quarter_number,
    net_revenue,
    LAG(net_revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue,
    ROUND(
        (
            net_revenue
            - LAG(net_revenue) OVER (ORDER BY quarter_number)
        )
        / LAG(net_revenue) OVER (ORDER BY quarter_number) * 100,
        2
    ) AS qoq_percentage_change
FROM (
    SELECT
        quarter_number,
        ROUND(
            SUM(quantity * vehicle_price * (1 - discount)),
            2
        ) AS net_revenue
    FROM order_t
    GROUP BY quarter_number
) AS revenue
ORDER BY quarter_number;


-- ============================================================
-- Question 8: Trend of orders and net revenue by quarter
-- ============================================================
SELECT
    quarter_number,
    COUNT(order_id) AS total_orders,
    ROUND(
        SUM(quantity * vehicle_price * (1 - discount)),
        2
    ) AS net_revenue
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Question 9: Average discount percentage by credit card type
-- ============================================================
SELECT
    c.credit_card_type,
    ROUND(AVG(o.discount) * 100, 2) AS average_discount_percentage
FROM order_t AS o
JOIN customer_t AS c
    ON o.customer_id = c.customer_id
GROUP BY c.credit_card_type
ORDER BY average_discount_percentage DESC;


-- ============================================================
-- Question 10: Average shipping time in days by quarter
-- SQLite-specific date calculation using JULIANDAY()
-- ============================================================
SELECT
    quarter_number,
    ROUND(
        AVG(JULIANDAY(ship_date) - JULIANDAY(order_date)),
        2
    ) AS average_shipping_days
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;
