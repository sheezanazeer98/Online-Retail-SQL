"""
Online Retail Data Analysis Script
Executes comprehensive SQL queries and generates CSV output files
Created by: Sheeza Nazeer
"""

import os
import sqlite3
from pathlib import Path

import pandas as pd


DB_PATH = "online_retail.db"
OUTPUT_DIR = Path("outputs")


def run_query(conn, query: str, description: str = ""):
    """Run a single SQL query and return a DataFrame (if it returns rows)."""
    query = query.strip().rstrip(";")
    if not query:
        return None
    try:
        df = pd.read_sql_query(query, conn)
        if description:
            print(f"\n{description}")
        return df
    except Exception as exc:
        print(f"Error running query: {description}\n{exc}")
        return None


def save_to_csv(df, filename: str, output_dir: Path = OUTPUT_DIR):
    """Save DataFrame to CSV file."""
    if df is not None and not df.empty:
        filepath = output_dir / filename
        df.to_csv(filepath, index=False)
        print(f"  ✓ Saved: {filename}")


def main():
    """Main analysis execution function."""
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(
            f"Database '{DB_PATH}' not found. Run 'python load_data.py' first."
        )

    OUTPUT_DIR.mkdir(exist_ok=True)
    print("=" * 70)
    print("Online Retail Data Analysis")
    print("=" * 70)

    with sqlite3.connect(DB_PATH) as conn:
        print("\n✓ Connected to database.")

        # ====================================================================
        # SECTION 1: BASIC STATISTICS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 1: BASIC STATISTICS & DATA OVERVIEW")
        print("=" * 70)

        # 1.1 Total row count
        total_rows = run_query(
            conn,
            "SELECT COUNT(*) AS total_rows FROM online_retail;",
            "=== Total Rows ==="
        )
        print(total_rows)

        # 1.2 Total revenue breakdown
        revenue_breakdown = run_query(
            conn,
            """
            SELECT
                ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
                ROUND(SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity * UnitPrice) ELSE 0 END), 2) AS return_value
            FROM online_retail
            WHERE UnitPrice IS NOT NULL;
            """,
            "=== Revenue Breakdown ==="
        )
        print(revenue_breakdown)

        # 1.3 Distinct counts
        distinct_counts = run_query(
            conn,
            """
            SELECT 
                COUNT(DISTINCT InvoiceNo) AS total_invoices,
                COUNT(DISTINCT CASE WHEN InvoiceNo NOT LIKE 'C%' THEN InvoiceNo END) AS valid_invoices,
                COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_invoices,
                COUNT(DISTINCT CustomerID) AS total_customers,
                COUNT(DISTINCT StockCode) AS total_products,
                COUNT(DISTINCT Country) AS total_countries
            FROM online_retail;
            """,
            "=== Distinct Counts ==="
        )
        print(distinct_counts)

        # ====================================================================
        # SECTION 2: DATA QUALITY ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 2: DATA QUALITY & VALIDATION")
        print("=" * 70)

        # 2.1 Missing values analysis
        missing_values = run_query(
            conn,
            """
            SELECT 
                COUNT(*) AS total_rows,
                SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
                ROUND(100.0 * SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_missing_customer_id,
                SUM(CASE WHEN Description IS NULL OR Description = '' THEN 1 ELSE 0 END) AS missing_description
            FROM online_retail;
            """,
            "=== Missing Values Analysis ==="
        )
        print(missing_values)
        save_to_csv(missing_values, "data_quality_report.csv")

        # 2.2 Cancellation analysis
        cancellation_analysis = run_query(
            conn,
            """
            SELECT 
                COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_invoices,
                COUNT(DISTINCT InvoiceNo) AS total_invoices,
                ROUND(100.0 * COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) / 
                      COUNT(DISTINCT InvoiceNo), 2) AS cancellation_rate_pct
            FROM online_retail;
            """,
            "=== Cancellation Analysis ==="
        )
        print(cancellation_analysis)

        # 2.3 Returns analysis
        returns_analysis = run_query(
            conn,
            """
            SELECT 
                COUNT(*) AS return_transactions,
                SUM(Quantity) AS total_returned_quantity,
                ROUND(SUM(Quantity * UnitPrice), 2) AS return_value,
                COUNT(DISTINCT InvoiceNo) AS return_invoices
            FROM online_retail
            WHERE Quantity < 0 AND UnitPrice IS NOT NULL;
            """,
            "=== Returns Analysis ==="
        )
        print(returns_analysis)

        # ====================================================================
        # SECTION 3: REVENUE ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 3: REVENUE ANALYSIS")
        print("=" * 70)

        # 3.1 Top countries by revenue
        top_countries = run_query(
            conn,
            """
            SELECT
                Country,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                COUNT(DISTINCT CustomerID) AS num_customers,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
                      NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value
            FROM online_retail
            WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY Country
            ORDER BY sales_revenue DESC
            LIMIT 20;
            """,
            "=== Top 20 Countries by Revenue ==="
        )
        print(top_countries)
        save_to_csv(top_countries, "top_countries.csv")

        # 3.2 Monthly revenue trend
        monthly_trend = run_query(
            conn,
            """
            SELECT
                strftime('%Y-%m', InvoiceDate) AS year_month,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                COUNT(DISTINCT CustomerID) AS num_customers
            FROM online_retail
            WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY year_month
            ORDER BY year_month;
            """,
            "=== Monthly Revenue Trend ==="
        )
        print(monthly_trend)
        save_to_csv(monthly_trend, "monthly_revenue_trend.csv")

        # 3.3 Revenue growth rate
        revenue_growth = run_query(
            conn,
            """
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
            """,
            "=== Revenue Growth Rate (Month-over-Month) ==="
        )
        print(revenue_growth)
        save_to_csv(revenue_growth, "revenue_growth_rate.csv")

        # ====================================================================
        # SECTION 4: CUSTOMER ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 4: CUSTOMER ANALYSIS")
        print("=" * 70)

        # 4.1 Top customers by revenue
        top_customers = run_query(
            conn,
            """
            SELECT
                CustomerID,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS customer_revenue,
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                COUNT(*) AS num_transactions,
                MIN(InvoiceDate) AS first_purchase_date,
                MAX(InvoiceDate) AS last_purchase_date,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
                      NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value
            FROM online_retail
            WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY CustomerID
            ORDER BY customer_revenue DESC
            LIMIT 20;
            """,
            "=== Top 20 Customers by Revenue ==="
        )
        print(top_customers)
        save_to_csv(top_customers, "top_customers.csv")

        # 4.2 Customer purchase frequency distribution
        customer_frequency = run_query(
            conn,
            """
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
            """,
            "=== Customer Purchase Frequency Distribution ==="
        )
        print(customer_frequency)
        save_to_csv(customer_frequency, "customer_frequency_distribution.csv")

        # 4.3 Customer lifetime value
        customer_clv = run_query(
            conn,
            """
            SELECT
                CustomerID,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS total_revenue,
                COUNT(DISTINCT InvoiceNo) AS total_orders,
                COUNT(DISTINCT strftime('%Y-%m', InvoiceDate)) AS active_months,
                MIN(InvoiceDate) AS first_purchase,
                MAX(InvoiceDate) AS last_purchase,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
                      NULLIF(COUNT(DISTINCT strftime('%Y-%m', InvoiceDate)), 0), 2) AS revenue_per_month
            FROM online_retail
            WHERE CustomerID IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY CustomerID
            HAVING total_orders >= 2
            ORDER BY total_revenue DESC
            LIMIT 50;
            """,
            "=== Top 50 Customers by Lifetime Value ==="
        )
        print(customer_clv.head(10))
        save_to_csv(customer_clv, "customer_lifetime_value.csv")

        # ====================================================================
        # SECTION 5: RFM CUSTOMER SEGMENTATION
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 5: RFM CUSTOMER SEGMENTATION")
        print("=" * 70)

        # 5.1 RFM Segmentation
        rfm_segments = run_query(
            conn,
            """
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
            """,
            "=== RFM Customer Segmentation ==="
        )
        print(rfm_segments.head(20))
        save_to_csv(rfm_segments, "rfm_segments.csv")

        # 5.2 RFM Segment Summary
        rfm_summary = run_query(
            conn,
            """
            WITH customer_metrics AS (
                SELECT
                    CustomerID,
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
            """,
            "=== RFM Segment Summary Statistics ==="
        )
        print(rfm_summary)
        save_to_csv(rfm_summary, "rfm_segment_summary.csv")

        # ====================================================================
        # SECTION 6: PRODUCT ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 6: PRODUCT ANALYSIS")
        print("=" * 70)

        # 6.1 Top products by revenue
        top_products_rev = run_query(
            conn,
            """
            SELECT
                StockCode,
                COALESCE(Description, 'No Description') AS Description,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS product_revenue,
                SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity_sold,
                COUNT(DISTINCT InvoiceNo) AS times_purchased,
                COUNT(DISTINCT CustomerID) AS unique_customers,
                ROUND(AVG(UnitPrice), 2) AS avg_unit_price
            FROM online_retail
            WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY StockCode, Description
            ORDER BY product_revenue DESC
            LIMIT 30;
            """,
            "=== Top 30 Products by Revenue ==="
        )
        print(top_products_rev.head(10))
        save_to_csv(top_products_rev, "top_products_by_revenue.csv")

        # 6.2 Top products by quantity
        top_products_qty = run_query(
            conn,
            """
            SELECT
                StockCode,
                COALESCE(Description, 'No Description') AS Description,
                SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_quantity_sold,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS product_revenue,
                COUNT(DISTINCT InvoiceNo) AS times_purchased,
                COUNT(DISTINCT CustomerID) AS unique_customers
            FROM online_retail
            WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY StockCode, Description
            ORDER BY total_quantity_sold DESC
            LIMIT 30;
            """,
            "=== Top 30 Products by Quantity Sold ==="
        )
        print(top_products_qty.head(10))
        save_to_csv(top_products_qty, "top_products_by_quantity.csv")

        # 6.3 Product return rate
        product_returns = run_query(
            conn,
            """
            SELECT
                StockCode,
                COALESCE(Description, 'No Description') AS Description,
                SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS total_sold,
                SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) AS total_returned,
                ROUND(100.0 * SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) / 
                      NULLIF(SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) + 
                             SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END), 0), 2) AS return_rate_pct
            FROM online_retail
            WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY StockCode, Description
            HAVING total_sold > 0
            ORDER BY return_rate_pct DESC
            LIMIT 30;
            """,
            "=== Top 30 Products by Return Rate ==="
        )
        print(product_returns.head(10))
        save_to_csv(product_returns, "product_return_rates.csv")

        # ====================================================================
        # SECTION 7: TIME-BASED ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 7: TIME-BASED ANALYSIS")
        print("=" * 70)

        # 7.1 Hourly sales pattern
        hourly_pattern = run_query(
            conn,
            """
            SELECT
                CAST(strftime('%H', InvoiceDate) AS INTEGER) AS hour_of_day,
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                COUNT(*) AS num_transactions,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
            FROM online_retail
            WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
            GROUP BY hour_of_day
            ORDER BY hour_of_day;
            """,
            "=== Hourly Sales Pattern ==="
        )
        print(hourly_pattern)
        save_to_csv(hourly_pattern, "hourly_sales_pattern.csv")

        # 7.2 Day of week analysis
        day_of_week = run_query(
            conn,
            """
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
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS revenue
            FROM online_retail
            WHERE InvoiceDate IS NOT NULL AND UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
            GROUP BY day_of_week
            ORDER BY revenue DESC;
            """,
            "=== Day of Week Analysis ==="
        )
        print(day_of_week)
        save_to_csv(day_of_week, "day_of_week_analysis.csv")

        # ====================================================================
        # SECTION 8: GEOGRAPHIC ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 8: GEOGRAPHIC ANALYSIS")
        print("=" * 70)

        # 8.1 Detailed country analysis
        country_analysis = run_query(
            conn,
            """
            SELECT
                Country,
                COUNT(DISTINCT CustomerID) AS num_customers,
                COUNT(DISTINCT InvoiceNo) AS num_invoices,
                COUNT(DISTINCT StockCode) AS num_products,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END), 2) AS sales_revenue,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
                      NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS avg_order_value,
                ROUND(SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) / 
                      NULLIF(COUNT(DISTINCT CustomerID), 0), 2) AS revenue_per_customer
            FROM online_retail
            WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%'
            GROUP BY Country
            ORDER BY sales_revenue DESC;
            """,
            "=== Detailed Country Analysis ==="
        )
        print(country_analysis.head(15))
        save_to_csv(country_analysis, "country_analysis.csv")

        # ====================================================================
        # SECTION 9: BASKET ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 9: BASKET ANALYSIS")
        print("=" * 70)

        # 9.1 Invoice-level averages
        invoice_stats = run_query(
            conn,
            """
            WITH invoice_stats AS (
                SELECT
                    InvoiceNo,
                    SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) AS invoice_revenue,
                    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS invoice_qty
                FROM online_retail
                WHERE UnitPrice IS NOT NULL AND InvoiceNo NOT LIKE 'C%' AND Quantity > 0
                GROUP BY InvoiceNo
            )
            SELECT
                COUNT(*) AS total_invoices,
                ROUND(AVG(invoice_revenue), 2) AS avg_order_value,
                ROUND(AVG(invoice_qty), 2) AS avg_items_per_invoice,
                ROUND(MAX(invoice_revenue), 2) AS max_order_value,
                ROUND(MIN(invoice_revenue), 2) AS min_order_value
            FROM invoice_stats;
            """,
            "=== Invoice-Level Statistics ==="
        )
        print(invoice_stats)
        save_to_csv(invoice_stats, "invoice_averages.csv")

        # 9.2 Basket size distribution
        basket_distribution = run_query(
            conn,
            """
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
            """,
            "=== Basket Size Distribution ==="
        )
        print(basket_distribution)
        save_to_csv(basket_distribution, "basket_size_distribution.csv")

        # ====================================================================
        # SECTION 10: COHORT ANALYSIS
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 10: COHORT ANALYSIS")
        print("=" * 70)

        # 10.1 Customer cohorts
        customer_cohorts = run_query(
            conn,
            """
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
                    ROUND(SUM(CASE WHEN o.Quantity > 0 THEN o.Quantity * o.UnitPrice ELSE 0 END), 2) AS revenue
                FROM online_retail o
                JOIN first_purchase fp ON o.CustomerID = fp.CustomerID
                WHERE o.UnitPrice IS NOT NULL AND o.InvoiceNo NOT LIKE 'C%' AND o.Quantity > 0
                GROUP BY fp.first_purchase_date, order_month
            )
            SELECT 
                cohort_month,
                order_month,
                customers,
                orders,
                revenue
            FROM cohorts
            ORDER BY cohort_month, order_month;
            """,
            "=== Customer Cohort Analysis ==="
        )
        print(customer_cohorts.head(20))
        save_to_csv(customer_cohorts, "customer_cohorts.csv")

        # ====================================================================
        # SECTION 11: SUMMARY KPIs
        # ====================================================================
        print("\n" + "=" * 70)
        print("SECTION 11: SUMMARY KPIs")
        print("=" * 70)

        # 11.1 Overall business KPIs
        business_kpis = run_query(
            conn,
            """
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
            """,
            "=== Overall Business KPIs ==="
        )
        print(business_kpis)
        save_to_csv(business_kpis, "business_kpis.csv")

    print("\n" + "=" * 70)
    print("ANALYSIS COMPLETE!")
    print("=" * 70)
    print(f"\n✓ All CSV outputs saved to '{OUTPUT_DIR}/' directory.")
    print(f"\nGenerated files:")
    for file in sorted(OUTPUT_DIR.glob("*.csv")):
        print(f"  • {file.name}")


if __name__ == "__main__":
    main()
