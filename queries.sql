# Q1
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q1_cleaned_orders AS
SELECT 
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';
""")

pd.read_sql_query("SELECT * FROM q1_cleaned_orders LIMIT 5;", conn)

# Q2
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q2_cohort_assignment AS
SELECT 
    customer_unique_id,
    strftime('%Y-%m-01', MIN(order_purchase_timestamp)) AS cohort_month
FROM q1_cleaned_orders
GROUP BY customer_unique_id;
""")

pd.read_sql_query("SELECT * FROM q2_cohort_assignment LIMIT 5;", conn)

# Q3
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q3_customer_activity AS
SELECT 
    customer_unique_id,
    order_id,
    strftime('%Y-%m-01', order_purchase_timestamp) AS order_month
FROM q1_cleaned_orders;
""")

pd.read_sql_query("SELECT * FROM q3_customer_activity LIMIT 5;", conn)

# Q4
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q4_cohort_activity_joined AS
SELECT 
    ca.customer_unique_id,
    ca.cohort_month,
    act.order_id,
    act.order_month,
    CAST((strftime('%Y', act.order_month) - strftime('%Y', ca.cohort_month)) * 12 + 
         (strftime('%m', act.order_month) - strftime('%m', ca.cohort_month)) AS INTEGER) AS period_number
FROM q3_customer_activity act
INNER JOIN q2_cohort_assignment ca ON act.customer_unique_id = ca.customer_unique_id;
""")

pd.read_sql_query("SELECT * FROM q4_cohort_activity_joined LIMIT 5;", conn)

# Q5
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q5_retention_matrix AS
SELECT 
    cohort_month,
    period_number,
    COUNT(DISTINCT customer_unique_id) AS retained_customers
FROM q4_cohort_activity_joined
GROUP BY cohort_month, period_number;
""")

pd.read_sql_query("SELECT * FROM q5_retention_matrix LIMIT 5;", conn)

# Q6
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q6_cohort_sizes AS
SELECT 
    cohort_month,
    retained_customers AS cohort_size
FROM q5_retention_matrix
WHERE period_number = 0;
""")

pd.read_sql_query("SELECT * FROM q6_cohort_sizes LIMIT 5;", conn)

# Q7
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q7_retention_rates AS
SELECT 
    rm.cohort_month,
    rm.period_number,
    rm.retained_customers,
    cs.cohort_size,
    ROUND(CAST(rm.retained_customers AS REAL) / cs.cohort_size * 100, 2) AS retention_rate_pct
FROM q5_retention_matrix rm
INNER JOIN q6_cohort_sizes cs ON rm.cohort_month = cs.cohort_month;
""")

pd.read_sql_query("SELECT * FROM q7_retention_rates LIMIT 5;", conn)

# Q8
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q8_period_averages AS
SELECT 
    period_number,
    ROUND(AVG(retention_rate_pct), 2) AS avg_retention_rate
FROM q7_retention_rates
GROUP BY period_number;
""")

pd.read_sql_query("SELECT * FROM q8_period_averages;", conn)

# Q9
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q9_best_worst_month1 AS
SELECT 
    cohort_month,
    retention_rate_pct,
    CASE 
        WHEN retention_rate_pct = (SELECT MAX(retention_rate_pct) FROM q7_retention_rates WHERE period_number = 1) THEN 'Best Cohort'
        WHEN retention_rate_pct = (SELECT MIN(retention_rate_pct) FROM q7_retention_rates WHERE period_number = 1) THEN 'Worst Cohort'
    END AS cohort_rank
FROM q7_retention_rates
WHERE period_number = 1 
  AND (
    retention_rate_pct = (SELECT MAX(retention_rate_pct) FROM q7_retention_rates WHERE period_number = 1)
    OR retention_rate_pct = (SELECT MIN(retention_rate_pct) FROM q7_retention_rates WHERE period_number = 1)
  );
""")

pd.read_sql_query("SELECT * FROM q9_best_worst_month1;", conn)

# Q10
conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q10_order_prices AS
SELECT order_id, SUM(price) AS order_total
FROM order_items
GROUP BY order_id;
""")

conn.execute("""
CREATE TEMP VIEW IF NOT EXISTS q10_cohort_revenue AS
SELECT 
    caj.cohort_month,
    caj.period_number,
    ROUND(SUM(op.order_total), 2) AS total_revenue
FROM q4_cohort_activity_joined caj
INNER JOIN q10_order_prices op ON caj.order_id = op.order_id
GROUP BY caj.cohort_month, caj.period_number;
""")

pd.read_sql_query("SELECT * FROM q10_cohort_revenue LIMIT 5;", conn)