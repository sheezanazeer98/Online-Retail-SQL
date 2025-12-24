-- ============================================================================
-- Online Retail Dataset - Comprehensive SQL Analysis Queries
-- Dataset: UCI Machine Learning Repository - Online Retail
-- ============================================================================

-- ============================================================================
-- SECTION 1: BASIC STATISTICS & DATA OVERVIEW
-- ============================================================================

-- Query 1.1: Total row count
SELECT COUNT(*) AS total_rows
FROM online_retail;

-- Query 1.2: Total revenue (including returns)
SELECT
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
    ROUND(SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity * UnitPrice) ELSE 0 END), 2) AS return_value
FROM online_retail
WHERE UnitPrice IS NOT NULL;

-- Query 1.3: Number of distinct invoices
SELECT 
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    COUNT(DISTINCT CASE WHEN InvoiceNo NOT LIKE 'C%' THEN InvoiceNo END) AS valid_invoices,
    COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_invoices
FROM online_retail;

-- Query 1.4: Number of distinct customers
SELECT 
    COUNT(DISTINCT CustomerID) AS total_customers,
    COUNT(DISTINCT CASE WHEN CustomerID IS NOT NULL THEN CustomerID END) AS customers_with_id
FROM online_retail;

-- Query 1.5: Number of distinct products
SELECT 
    COUNT(DISTINCT StockCode) AS total_products,
    COUNT(DISTINCT CASE WHEN Description IS NOT NULL AND Description != '' THEN StockCode END) AS products_with_description
FROM online_retail;

-- Query 1.6: Number of countries
SELECT COUNT(DISTINCT Country) AS total_countries
FROM online_retail;

-- Query 1.7: Date range of transactions
SELECT 
    MIN(InvoiceDate) AS first_transaction_date,
    MAX(InvoiceDate) AS last_transaction_date,
    JULIANDAY(MAX(InvoiceDate)) - JULIANDAY(MIN(InvoiceDate)) AS days_span
FROM online_retail
WHERE InvoiceDate IS NOT NULL;

-- ============================================================================
-- SECTION 2: DATA QUALITY & VALIDATION
-- ============================================================================

-- Query 2.1: Missing values analysis
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END) AS missing_invoice_no,
    SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END) AS missing_stock_code,
    SUM(CASE WHEN Description IS NULL OR Description = '' THEN 1 ELSE 0 END) AS missing_description,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS missing_invoice_date,
    SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Country IS NULL OR Country = '' THEN 1 ELSE 0 END) AS missing_country
FROM online_retail;

-- Query 2.2: Missing CustomerID percentage
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    ROUND(100.0 * SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_missing_customer_id
FROM online_retail;

-- Query 2.3: Cancelled invoices analysis
SELECT 
    COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_invoices,
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) / 
          COUNT(DISTINCT InvoiceNo), 2) AS cancellation_rate_pct,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN ABS(Quantity * UnitPrice) ELSE 0 END) AS cancelled_revenue_value
FROM online_retail
WHERE UnitPrice IS NOT NULL;

-- Query 2.4: Returns analysis (negative quantities)
SELECT 
    COUNT(*) AS return_transactions,
    SUM(Quantity) AS total_returned_quantity,
    ROUND(SUM(Quantity * UnitPrice), 2) AS return_value,
    COUNT(DISTINCT InvoiceNo) AS return_invoices,
    COUNT(DISTINCT StockCode) AS products_returned,
    ROUND(AVG(Quantity), 2) AS avg_return_quantity
FROM online_retail
WHERE Quantity < 0 AND UnitPrice IS NOT NULL;

-- Query 2.5: Invalid data flags (negative prices, zero prices)
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END) AS negative_prices,
    SUM(CASE WHEN UnitPrice = 0 THEN 1 ELSE 0 END) AS zero_prices,
    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS zero_quantities,
    SUM(CASE WHEN Quantity < 0 AND UnitPrice < 0 THEN 1 ELSE 0 END) AS double_negative
FROM online_retail;

-- Query 2.6: Duplicate transactions check
SELECT 
    InvoiceNo,
    StockCode,
    COUNT(*) AS occurrence_count
FROM online_retail
GROUP BY InvoiceNo, StockCode
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC
LIMIT 20;

-- ============================================================================
-- SECTION 3: REVENUE ANALYSIS
-- ============================================================================

-- Query 3.1: Total revenue breakdown
SELECT 
    ROUND(SUM(CASE WHEN Quantity > 0 AND UnitPrice > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_sales_revenue,
    ROUND(SUM(CASE WHEN Quantity < 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_returns_value,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    COUNT(DISTINCT CASE WHEN Quantity > 0 AND UnitPrice > 0 THEN InvoiceNo END) AS sales_invoices,
    COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) AS return_invoices
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%';

-- Query 3.2: Revenue by country (Top 20)
SELECT
    Country,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(DISTINCT CustomerID) AS num_customers,
    COUNT(DISTINCT StockCode) AS num_products,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value,
    ROUND(100.0 * SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          (SELECT SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) 
           FROM online_retail WHERE UnitPrice IS NOT NULL), 2) AS revenue_percentage
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY Country
ORDER BY sales_revenue DESC
LIMIT 20;

-- Query 3.3: Monthly revenue trend
SELECT
    strftime('%Y-%m', InvoiceDate) AS year_month,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(DISTINCT CustomerID) AS num_customers,
    COUNT(*) AS num_transactions,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS avg_transaction_value
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY year_month
ORDER BY year_month;

-- Query 3.4: Revenue growth rate (month-over-month)
WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS year_month,
        ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
    FROM online_retail
    WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
    GROUP BY year_month
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY year_month) AS previous_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY year_month), 2) AS revenue_change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month)) / 
          NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0), 2) AS growth_rate_pct
FROM monthly_revenue
ORDER BY year_month;

-- Query 3.5: Average order value (AOV) by country
SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END), 2) AS avg_items_per_order
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY Country
HAVING num_invoices >= 10
ORDER BY avg_order_value DESC;

-- ============================================================================
-- SECTION 4: CUSTOMER ANALYSIS
-- ============================================================================

-- Query 4.1: Top 20 customers by revenue
SELECT
    CustomerID,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS customer_revenue,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(*) AS num_transactions,
    COUNT(DISTINCT StockCode) AS num_products_purchased,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS last_purchase_date,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS avg_transaction_value,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value
FROM online_retail
WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY CustomerID
ORDER BY customer_revenue DESC
LIMIT 20;

-- Query 4.2: Customer purchase frequency distribution
SELECT
    CASE
        WHEN invoice_count = 1 THEN '1 purchase'
        WHEN invoice_count BETWEEN 2 AND 5 THEN '2-5 purchases'
        WHEN invoice_count BETWEEN 6 AND 10 THEN '6-10 purchases'
        WHEN invoice_count BETWEEN 11 AND 20 THEN '11-20 purchases'
        WHEN invoice_count BETWEEN 21 AND 50 THEN '21-50 purchases'
        ELSE '50+ purchases'
    END AS purchase_frequency_category,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT CustomerID) 
                              FROM online_retail 
                              WHERE CustomerID IS NOT NULL), 2) AS percentage
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS invoice_count
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
    GROUP BY CustomerID
) AS customer_freq
GROUP BY purchase_frequency_category
ORDER BY MIN(invoice_count);

-- Query 4.3: Customer lifetime value (CLV) analysis
SELECT
    CustomerID,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT strftime('%Y-%m', InvoiceDate)) AS active_months,
    MIN(InvoiceDate) AS first_purchase,
    MAX(InvoiceDate) AS last_purchase,
    JULIANDAY(MAX(InvoiceDate)) - JULIANDAY(MIN(InvoiceDate)) AS customer_lifetime_days,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT strftime('%Y-%m', InvoiceDate)), 0), 2) AS revenue_per_month
FROM online_retail
WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY CustomerID
HAVING total_orders >= 2
ORDER BY total_revenue DESC
LIMIT 50;

-- Query 4.4: New vs returning customers (by month)
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(strftime('%Y-%m', InvoiceDate)) AS first_purchase_month
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
    GROUP BY CustomerID
)
SELECT
    strftime('%Y-%m', o.InvoiceDate) AS order_month,
    COUNT(DISTINCT CASE WHEN fp.first_purchase_month = strftime('%Y-%m', o.InvoiceDate) 
                        THEN o.CustomerID END) AS new_customers,
    COUNT(DISTINCT CASE WHEN fp.first_purchase_month < strftime('%Y-%m', o.InvoiceDate) 
                        THEN o.CustomerID END) AS returning_customers,
    COUNT(DISTINCT o.CustomerID) AS total_customers
FROM online_retail o
JOIN first_purchase fp ON o.CustomerID = fp.CustomerID
WHERE o.InvoiceNo NOT LIKE 'C%'
GROUP BY order_month
ORDER BY order_month;

-- ============================================================================
-- SECTION 5: RFM CUSTOMER SEGMENTATION
-- ============================================================================

-- Query 5.1: RFM Analysis - Detailed Segmentation
WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS monetary_value,
        JULIANDAY('now') - JULIANDAY(MAX(InvoiceDate)) AS days_since_last_purchase
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        CustomerID,
        last_purchase_date,
        frequency,
        monetary_value,
        days_since_last_purchase,
        CASE 
            WHEN days_since_last_purchase <= 30 THEN 5
            WHEN days_since_last_purchase <= 60 THEN 4
            WHEN days_since_last_purchase <= 90 THEN 3
            WHEN days_since_last_purchase <= 180 THEN 2
            ELSE 1
        END AS recency_score,
        CASE 
            WHEN frequency >= 50 THEN 5
            WHEN frequency >= 20 THEN 4
            WHEN frequency >= 10 THEN 3
            WHEN frequency >= 5 THEN 2
            ELSE 1
        END AS frequency_score,
        CASE 
            WHEN monetary_value >= 5000 THEN 5
            WHEN monetary_value >= 2000 THEN 4
            WHEN monetary_value >= 1000 THEN 3
            WHEN monetary_value >= 500 THEN 2
            ELSE 1
        END AS monetary_score
    FROM customer_metrics
)
SELECT
    CustomerID,
    last_purchase_date,
    days_since_last_purchase,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 4 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'Potential Loyalists'
        WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'Cannot Lose Them'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Hibernating'
        WHEN recency_score <= 2 THEN 'Lost'
        ELSE 'Need Attention'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_score DESC, monetary_value DESC;

-- Query 5.2: RFM Segment Summary Statistics
WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS monetary_value,
        JULIANDAY('now') - JULIANDAY(MAX(InvoiceDate)) AS days_since_last_purchase
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        CustomerID,
        frequency,
        monetary_value,
        days_since_last_purchase,
        CASE 
            WHEN days_since_last_purchase <= 30 THEN 5
            WHEN days_since_last_purchase <= 60 THEN 4
            WHEN days_since_last_purchase <= 90 THEN 3
            WHEN days_since_last_purchase <= 180 THEN 2
            ELSE 1
        END AS recency_score,
        CASE 
            WHEN frequency >= 50 THEN 5
            WHEN frequency >= 20 THEN 4
            WHEN frequency >= 10 THEN 3
            WHEN frequency >= 5 THEN 2
            ELSE 1
        END AS frequency_score,
        CASE 
            WHEN monetary_value >= 5000 THEN 5
            WHEN monetary_value >= 2000 THEN 4
            WHEN monetary_value >= 1000 THEN 3
            WHEN monetary_value >= 500 THEN 2
            ELSE 1
        END AS monetary_score
    FROM customer_metrics
),
segmented AS (
    SELECT
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 4 AND monetary_score >= 3 THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'Potential Loyalists'
            WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'Cannot Lose Them'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Hibernating'
            WHEN recency_score <= 2 THEN 'Lost'
            ELSE 'Need Attention'
        END AS customer_segment,
        CustomerID,
        monetary_value
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM segmented), 2) AS percentage,
    ROUND(SUM(monetary_value), 2) AS total_revenue,
    ROUND(AVG(monetary_value), 2) AS avg_customer_value
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- ============================================================================
-- SECTION 6: PRODUCT ANALYSIS
-- ============================================================================

-- Query 6.1: Top 30 products by revenue
SELECT
    StockCode,
    COALESCE(Description, 'No Description') AS Description,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS product_revenue,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity_sold,
    SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) AS total_quantity_returned,
    COUNT(DISTINCT InvoiceNo) AS times_purchased,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END), 0), 2) AS revenue_per_unit
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
ORDER BY product_revenue DESC
LIMIT 30;

-- Query 6.2: Top 30 products by quantity sold
SELECT
    StockCode,
    COALESCE(Description, 'No Description') AS Description,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity_sold,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS product_revenue,
    COUNT(DISTINCT InvoiceNo) AS times_purchased,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
ORDER BY total_quantity_sold DESC
LIMIT 30;

-- Query 6.3: Slow-moving products (low sales)
SELECT
    StockCode,
    COALESCE(Description, 'No Description') AS Description,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity,
    COUNT(DISTINCT InvoiceNo) AS times_purchased,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price,
    MAX(InvoiceDate) AS last_sale_date
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
HAVING total_quantity < 10 AND times_purchased < 5
ORDER BY total_quantity ASC, last_sale_date DESC
LIMIT 50;

-- Query 6.4: Product return rate analysis
SELECT
    StockCode,
    COALESCE(Description, 'No Description') AS Description,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_sold,
    SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) AS total_returned,
    ROUND(100.0 * SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) + 
                 SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END), 0), 2) AS return_rate_pct,
    COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) AS return_invoices
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY StockCode, Description
HAVING total_sold > 0
ORDER BY return_rate_pct DESC
LIMIT 30;

-- Query 6.5: Product performance by price range
SELECT
    CASE
        WHEN UnitPrice < 5 THEN 'Under £5'
        WHEN UnitPrice < 10 THEN '£5-£10'
        WHEN UnitPrice < 20 THEN '£10-£20'
        WHEN UnitPrice < 50 THEN '£20-£50'
        WHEN UnitPrice < 100 THEN '£50-£100'
        ELSE 'Over £100'
    END AS price_range,
    COUNT(DISTINCT StockCode) AS num_products,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity_sold,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS num_transactions
FROM online_retail
WHERE UnitPrice IS NOT NULL AND UnitPrice > 0 AND InvoiceNo NOT LIKE 'C%'
GROUP BY price_range
ORDER BY MIN(UnitPrice);

-- ============================================================================
-- SECTION 7: TIME-BASED ANALYSIS
-- ============================================================================

-- Query 7.1: Hourly sales pattern
SELECT
    CAST(strftime('%H', InvoiceDate) AS INTEGER) AS hour_of_day,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(*) AS num_transactions,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS avg_transaction_value
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Query 7.2: Day of week analysis
SELECT
    CASE CAST(strftime('%w', InvoiceDate) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    CAST(strftime('%w', InvoiceDate) AS INTEGER) AS day_number,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(*) AS num_transactions,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS avg_transaction_value
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY day_of_week, day_number
ORDER BY day_number;

-- Query 7.3: Monthly comparison (year-over-year if available)
SELECT
    strftime('%m', InvoiceDate) AS month_number,
    CASE CAST(strftime('%m', InvoiceDate) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY month_number, month_name
ORDER BY month_number;

-- Query 7.4: Peak shopping hours (top 10)
SELECT
    CAST(strftime('%H', InvoiceDate) AS INTEGER) AS hour_of_day,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY hour_of_day
ORDER BY revenue DESC
LIMIT 10;

-- ============================================================================
-- SECTION 8: GEOGRAPHIC ANALYSIS
-- ============================================================================

-- Query 8.1: Detailed country analysis
SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS num_customers,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(DISTINCT StockCode) AS num_products,
    COUNT(*) AS num_transactions,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT CustomerID), 0), 2) AS revenue_per_customer,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END), 2) AS avg_items_per_order
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY Country
ORDER BY sales_revenue DESC;

-- Query 8.2: UK vs Rest of World comparison
SELECT
    CASE 
        WHEN Country = 'United Kingdom' THEN 'United Kingdom'
        ELSE 'Rest of World'
    END AS region,
    COUNT(DISTINCT CustomerID) AS num_customers,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
    ROUND(100.0 * SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          (SELECT SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) 
           FROM online_retail WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'), 2) AS revenue_percentage
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY region
ORDER BY sales_revenue DESC;

-- ============================================================================
-- SECTION 9: BASKET ANALYSIS
-- ============================================================================

-- Query 9.1: Average items per invoice
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_items_sold,
    ROUND(AVG(items_per_invoice), 2) AS avg_items_per_invoice,
    MAX(items_per_invoice) AS max_items_in_invoice,
    MIN(items_per_invoice) AS min_items_in_invoice
FROM (
    SELECT
        InvoiceNo,
        SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS items_per_invoice
    FROM online_retail
    WHERE InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY InvoiceNo
) AS invoice_items;

-- Query 9.2: Invoice size distribution
SELECT
    CASE
        WHEN items_per_invoice = 1 THEN '1 item'
        WHEN items_per_invoice BETWEEN 2 AND 5 THEN '2-5 items'
        WHEN items_per_invoice BETWEEN 6 AND 10 THEN '6-10 items'
        WHEN items_per_invoice BETWEEN 11 AND 20 THEN '11-20 items'
        WHEN items_per_invoice BETWEEN 21 AND 50 THEN '21-50 items'
        ELSE '50+ items'
    END AS basket_size_category,
    COUNT(*) AS num_invoices,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT InvoiceNo) 
                              FROM online_retail 
                              WHERE InvoiceNo NOT LIKE 'C%'), 2) AS percentage
FROM (
    SELECT
        InvoiceNo,
        SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS items_per_invoice
    FROM online_retail
    WHERE InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY InvoiceNo
) AS invoice_items
GROUP BY basket_size_category
ORDER BY MIN(items_per_invoice);

-- Query 9.3: High-value invoices (top 100)
SELECT
    InvoiceNo,
    CustomerID,
    Country,
    InvoiceDate,
    COUNT(*) AS num_line_items,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_items,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS invoice_value
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
GROUP BY InvoiceNo, CustomerID, Country, InvoiceDate
ORDER BY invoice_value DESC
LIMIT 100;

-- ============================================================================
-- SECTION 10: COHORT ANALYSIS
-- ============================================================================

-- Query 10.1: Customer cohort analysis (by first purchase month)
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(strftime('%Y-%m', InvoiceDate)) AS first_purchase_date,
        MIN(InvoiceDate) AS first_purchase_datetime
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY CustomerID
),
cohorts AS (
    SELECT
        fp.first_purchase_date AS cohort_month,
        strftime('%Y-%m', o.InvoiceDate) AS order_month,
        COUNT(DISTINCT o.CustomerID) AS customers,
        COUNT(DISTINCT o.InvoiceNo) AS orders,
        ROUND(SUM(CASE WHEN o.Quantity > 0 THEN o.Quantity * o.UnitPrice ELSE 0 END), 2) AS revenue,
        (CAST(strftime('%Y', o.InvoiceDate) AS INTEGER) - CAST(strftime('%Y', fp.first_purchase_datetime) AS INTEGER)) * 12 +
        (CAST(strftime('%m', o.InvoiceDate) AS INTEGER) - CAST(strftime('%m', fp.first_purchase_datetime) AS INTEGER)) AS period_number
    FROM online_retail o
    JOIN first_purchase fp ON o.CustomerID = fp.CustomerID
    WHERE o.UnitPrice IS NOT NULL AND o.InvoiceNo NOT LIKE 'C%' AND o.Quantity > 0
    GROUP BY cohort_month, order_month, period_number
)
SELECT 
    cohort_month,
    order_month,
    period_number,
    customers,
    orders,
    revenue
FROM cohorts
ORDER BY cohort_month, period_number;

-- Query 10.2: Cohort retention rate
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(strftime('%Y-%m', InvoiceDate)) AS first_purchase_date
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
    GROUP BY CustomerID
),
cohort_size AS (
    SELECT
        first_purchase_date AS cohort_month,
        COUNT(DISTINCT CustomerID) AS cohort_size
    FROM first_purchase
    GROUP BY first_purchase_date
),
cohort_activity AS (
    SELECT
        fp.first_purchase_date AS cohort_month,
        strftime('%Y-%m', o.InvoiceDate) AS order_month,
        COUNT(DISTINCT o.CustomerID) AS active_customers
    FROM online_retail o
    JOIN first_purchase fp ON o.CustomerID = fp.CustomerID
    WHERE o.InvoiceNo NOT LIKE 'C%' AND o.Quantity > 0
    GROUP BY fp.first_purchase_date, order_month
)
SELECT
    ca.cohort_month,
    ca.order_month,
    cs.cohort_size,
    ca.active_customers,
    ROUND(100.0 * ca.active_customers / cs.cohort_size, 2) AS retention_rate_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.order_month;

-- ============================================================================
-- SECTION 11: SUMMARY STATISTICS & KPIs
-- ============================================================================

-- Query 11.1: Overall business KPIs
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    COUNT(DISTINCT CustomerID) AS total_customers,
    COUNT(DISTINCT StockCode) AS total_products,
    COUNT(DISTINCT Country) AS total_countries,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_sales_revenue,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
          NULLIF(COUNT(DISTINCT CustomerID), 0), 2) AS avg_customer_value,
    ROUND(AVG(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END), 2) AS avg_items_per_transaction
FROM online_retail
WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%';

-- Query 11.2: Transaction volume by month
SELECT
    strftime('%Y-%m', InvoiceDate) AS year_month,
    COUNT(DISTINCT InvoiceNo) AS invoices,
    COUNT(DISTINCT CustomerID) AS customers,
    COUNT(*) AS transactions,
    ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
FROM online_retail
WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
GROUP BY year_month
ORDER BY year_month;

-- ============================================================================
-- END OF ANALYSIS QUERIES
-- ============================================================================
