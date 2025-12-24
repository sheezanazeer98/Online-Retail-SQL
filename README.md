# Online Retail SQL + Python Data Analysis Project

**Tech Stack**: Python 3.7+, SQLite, Pandas, SQLAlchemy  
**Project Type**: Data Analysis, Business Intelligence, E-commerce Analytics

---

## 1. Project Overview

This is a comprehensive **data analysis project** that performs deep-dive analytics on an **Online Retail** transactional dataset using a combination of **SQL** and **Python**. The project demonstrates real-world data analysis techniques including:

- **Data Engineering**: ETL (Extract, Transform, Load) processes to import CSV data into SQLite
- **SQL Analytics**: Complex queries for business intelligence and reporting
- **Data Quality Assessment**: Identification and handling of data issues
- **Customer Segmentation**: RFM (Recency, Frequency, Monetary) analysis
- **Time Series Analysis**: Trend analysis across months, days, and hours
- **Product Performance Analysis**: Best sellers, slow movers, and revenue drivers
- **Geographic Analysis**: Country and region-based insights
- **Cohort Analysis**: Customer retention and behavior patterns

### 1.1 Objectives

- Analyze transactional e-commerce data to extract actionable business insights
- Demonstrate proficiency in SQL querying and Python data manipulation
- Identify key performance indicators (KPIs) for retail operations
- Perform customer segmentation and product analysis
- Generate automated reports and visualizations-ready outputs

---

## 2. Dataset Information

### 2.1 Source

The dataset used in this project is the **Online Retail** dataset from the **UCI Machine Learning Repository**:

- **Dataset Link**: [https://archive.ics.uci.edu/dataset/352/online+retail](https://archive.ics.uci.edu/dataset/352/online+retail)
- **Citation**: Chen, D. (2015). *Online Retail* [Dataset]. UCI Machine Learning Repository. [https://doi.org/10.24432/C5BW33](https://doi.org/10.24432/C5BW33)
- **License**: Creative Commons Attribution 4.0 International (CC BY 4.0)

### 2.2 Dataset Characteristics

- **Type**: Multivariate, Sequential, Time-Series
- **Subject Area**: Business, E-commerce
- **Instances**: ~541,909 transactions
- **Features**: 8 columns
- **Time Period**: Transactions from 01/12/2010 to 09/12/2011
- **Business Context**: UK-based online retail company selling unique all-occasion gifts, with many wholesale customers

### 2.3 Dataset Schema

| Column Name | Data Type | Description | Notes |
|------------|-----------|-------------|-------|
| `InvoiceNo` | TEXT | Invoice number (6-digit) | Starts with 'C' indicates cancellation |
| `StockCode` | TEXT | Product code (5-digit) | Unique identifier for each product |
| `Description` | TEXT | Product name/description | May contain special characters |
| `Quantity` | INTEGER | Quantity of items per transaction | Can be negative (returns) |
| `InvoiceDate` | TEXT (ISO-8601) | Date and time of transaction | Format: YYYY-MM-DD HH:MM:SS |
| `UnitPrice` | REAL | Price per unit in GBP (Sterling) | Must be positive for valid transactions |
| `CustomerID` | TEXT | Customer identifier (5-digit) | May be NULL for guest transactions |
| `Country` | TEXT | Country name where customer resides | Primary market: United Kingdom |

### 2.4 Data Quality Considerations

- **Missing Values**: Some `CustomerID` values may be NULL (guest checkouts)
- **Cancellations**: Invoices starting with 'C' represent cancelled orders
- **Returns**: Negative `Quantity` values indicate product returns
- **Data Completeness**: All transactions are included, including incomplete records

---

## 3. Project Structure

```
projexct 1/
│
├── Online Retail.csv              # Source dataset (CSV file)
├── schema.sql                      # SQL schema definition for SQLite database
├── analysis_queries.sql            # Comprehensive SQL analysis queries
├── load_data.py                   # Python script to create DB and load CSV data
├── run_analysis.py                # Python script to execute analyses and generate outputs
├── requirements.txt               # Python package dependencies
├── README.md                      # This file - project documentation
│
├── online_retail.db               # SQLite database (created after running load_data.py)
│
└── outputs/                       # Generated analysis outputs (created after run_analysis.py)
    ├── top_countries.csv
    ├── top_customers.csv
    ├── top_products_by_quantity.csv
    ├── top_products_by_revenue.csv
    ├── monthly_revenue_trend.csv
    ├── invoice_averages.csv
    ├── rfm_segments.csv
    ├── hourly_sales_pattern.csv
    ├── day_of_week_analysis.csv
    ├── country_analysis.csv
    ├── product_performance.csv
    ├── customer_cohorts.csv
    └── data_quality_report.csv
```

### 3.1 File Descriptions

#### **schema.sql**
- Defines the `online_retail` table structure in SQLite
- Creates indexes on frequently queried columns (`InvoiceDate`, `CustomerID`, `Country`)
- Optimizes query performance for large datasets

#### **analysis_queries.sql**
- Contains 30+ SQL queries organized by category:
  - Basic statistics and data quality checks
  - Revenue and sales analysis
  - Customer segmentation (RFM analysis)
  - Product performance metrics
  - Time-based analysis (hourly, daily, monthly trends)
  - Geographic analysis
  - Cohort analysis
  - Basket analysis
  - Cancellation and return analysis

#### **load_data.py**
- **Purpose**: ETL script to import CSV data into SQLite
- **Features**:
  - Creates database and table structure using `schema.sql`
  - Reads CSV in chunks (50,000 rows at a time) for memory efficiency
  - Cleans and normalizes data (handles date formats, numeric conversions)
  - Validates and transforms data types
  - Provides progress feedback during loading

#### **run_analysis.py**
- **Purpose**: Executes SQL queries and generates output files
- **Features**:
  - Connects to SQLite database
  - Runs all analysis queries from `analysis_queries.sql`
  - Prints results to console for quick review
  - Exports results to CSV files in `outputs/` directory
  - Handles errors gracefully with informative messages

#### **requirements.txt**
- Lists all Python packages needed:
  - `pandas`: Data manipulation and CSV handling
  - `SQLAlchemy`: Database connectivity (optional, for advanced use)
  - `python-dateutil`: Date parsing utilities

---

## 4. Features & Capabilities

### 4.1 Analysis Categories

#### **Basic Statistics**
- Total transaction count
- Total revenue calculation
- Distinct invoice and customer counts
- Data completeness metrics

#### **Revenue Analysis**
- Total revenue (including/excluding returns)
- Revenue by country, customer, product
- Monthly, weekly, daily revenue trends
- Average order value (AOV)
- Revenue growth rates

#### **Customer Analytics**
- Top customers by revenue and frequency
- Customer segmentation using RFM model:
  - **Recency**: Days since last purchase
  - **Frequency**: Number of transactions
  - **Monetary**: Total spending
- Customer lifetime value (CLV)
- Customer retention and cohort analysis
- New vs. returning customer analysis

#### **Product Analytics**
- Top products by quantity sold
- Top products by revenue generated
- Product performance metrics (turnover rate, profit margins)
- Slow-moving vs. fast-moving products
- Product return rates

#### **Time-Based Analysis**
- Hourly sales patterns (peak shopping hours)
- Day-of-week analysis (weekday vs. weekend)
- Monthly trends and seasonality
- Year-over-year comparisons

#### **Geographic Analysis**
- Revenue by country
- Customer distribution by country
- Average order value by country
- Top countries by transaction volume

#### **Data Quality & Validation**
- Missing value detection
- Duplicate record identification
- Invalid data flagging (negative prices, zero quantities)
- Cancellation rate analysis
- Return rate analysis

---

## 5. Setup Instructions

### 5.1 Prerequisites

- **Python**: Version 3.7 or higher
- **Operating System**: Windows, macOS, or Linux
- **Disk Space**: At least 100 MB free (for database and outputs)
- **Memory**: 2 GB RAM recommended (for processing large CSV)

### 5.2 Installation Steps

#### Step 1: Verify Python Installation

Open PowerShell (Windows) or Terminal (macOS/Linux) and check Python version:

```bash
python --version
# Should show Python 3.7 or higher
```

If Python is not installed, download from [python.org](https://www.python.org/downloads/).

#### Step 2: Navigate to Project Directory

```bash
cd "project-name"
```

#### Step 3: Install Python Dependencies

Install required packages using pip:

```bash
pip install -r requirements.txt
```

**Expected output:**
```
Collecting pandas...
Collecting SQLAlchemy...
Collecting python-dateutil...
Successfully installed pandas-x.x.x SQLAlchemy-x.x.x python-dateutil-x.x.x
```

**Troubleshooting**: If you encounter permission errors, use:
```bash
pip install --user -r requirements.txt
```

#### Step 4: Verify CSV File Exists

Ensure `Online Retail.csv` is in the project directory. The file should contain transaction data with the columns described in Section 2.3.

---

## 6. Running the Analysis

### 6.1 Step-by-Step Execution

#### Step 1: Load Data into Database

Run the data loading script:

```bash
python load_data.py
```

**What happens:**
1. Creates `online_retail.db` SQLite database file
2. Creates `online_retail` table using `schema.sql`
3. Reads `Online Retail.csv` in chunks
4. Cleans and transforms data (dates, numbers)
5. Inserts data into database
6. Displays progress and total rows inserted

**Expected output:**
```
Reading CSV from: Online Retail.csv
Inserted 50000 rows (total so far: 50000)
Inserted 50000 rows (total so far: 100000)
...
Finished loading data. Total rows inserted: 541909
```

**Time estimate**: 30 seconds to 2 minutes depending on system performance.

#### Step 2: Run Analysis Queries

Execute the analysis script:

```bash
python run_analysis.py
```

**What happens:**
1. Connects to `online_retail.db`
2. Executes all SQL queries from `analysis_queries.sql`
3. Prints results to console
4. Saves results to CSV files in `outputs/` directory

**Expected output:**
```
Connected to database.

=== Basic Stats ===
   total_rows
0      541909

   total_revenue
0    9747747.84

=== Top 10 Countries by Revenue ===
         Country    revenue  num_invoices
0  United Kingdom  8204357.0        23494
1         Germany    280206.0         2155
2          France    258143.0         1037
...
```

**Time estimate**: 10-30 seconds depending on query complexity.

### 6.2 Using SQL Client (Optional)

You can also interact with the database directly using a SQL client:

#### Option A: DB Browser for SQLite (GUI)
1. Download from [sqlitebrowser.org](https://sqlitebrowser.org/)
2. Open `online_retail.db`
3. Navigate to "Execute SQL" tab
4. Copy queries from `analysis_queries.sql` and run them

#### Option B: Command Line SQLite
```bash
sqlite3 online_retail.db
```

Then run SQL queries:
```sql
SELECT COUNT(*) FROM online_retail;
SELECT * FROM online_retail LIMIT 10;
```

---

## 7. Analysis Queries Explained

This section provides detailed explanations of the SQL queries included in `analysis_queries.sql`.

### 7.1 Basic Statistics Queries

#### Query 1: Total Row Count
```sql
SELECT COUNT(*) AS total_rows FROM online_retail;
```
**Purpose**: Counts total number of transaction records in the dataset.

#### Query 2: Total Revenue
```sql
SELECT ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM online_retail;
```
**Purpose**: Calculates total revenue (including returns, which have negative quantities).

#### Query 3: Distinct Invoices
```sql
SELECT COUNT(DISTINCT InvoiceNo) AS total_invoices FROM online_retail;
```
**Purpose**: Counts unique invoices (one invoice can contain multiple line items).

### 7.2 Data Quality Queries

#### Query 4: Missing Customer IDs
```sql
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    ROUND(100.0 * SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_missing
FROM online_retail;
```
**Purpose**: Identifies percentage of transactions without customer IDs (guest checkouts).

#### Query 5: Cancelled Invoices
```sql
SELECT 
    COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancelled_invoices,
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) / 
          COUNT(DISTINCT InvoiceNo), 2) AS cancellation_rate
FROM online_retail;
```
**Purpose**: Calculates cancellation rate (invoices starting with 'C').

#### Query 6: Returns Analysis
```sql
SELECT 
    COUNT(*) AS return_transactions,
    SUM(Quantity) AS total_returned_quantity,
    ROUND(SUM(Quantity * UnitPrice), 2) AS return_value
FROM online_retail
WHERE Quantity < 0;
```
**Purpose**: Analyzes product returns (negative quantities).

### 7.3 Revenue Analysis Queries

#### Query 7: Revenue by Country
```sql
SELECT
    Country,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(DISTINCT CustomerID) AS num_customers,
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY Country
ORDER BY revenue DESC;
```
**Purpose**: Analyzes revenue performance by country with supporting metrics.

#### Query 8: Monthly Revenue Trend
```sql
SELECT
    strftime('%Y-%m', InvoiceDate) AS year_month,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    COUNT(DISTINCT CustomerID) AS num_customers
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY year_month
ORDER BY year_month;
```
**Purpose**: Shows revenue trends over time to identify seasonal patterns.

### 7.4 Customer Segmentation (RFM Analysis)

#### Query 9: RFM Segmentation
```sql
WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary_value
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND Quantity > 0 AND UnitPrice > 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        CustomerID,
        last_purchase_date,
        frequency,
        monetary_value,
        CASE 
            WHEN last_purchase_date >= date('now', '-30 days') THEN 5
            WHEN last_purchase_date >= date('now', '-60 days') THEN 4
            WHEN last_purchase_date >= date('now', '-90 days') THEN 3
            WHEN last_purchase_date >= date('now', '-180 days') THEN 2
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
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 THEN 'Potential Loyalists'
        WHEN recency_score >= 3 AND frequency_score <= 2 THEN 'At Risk'
        WHEN recency_score <= 2 THEN 'Lost'
        ELSE 'Need Attention'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_score DESC;
```
**Purpose**: Segments customers into groups (Champions, Loyal, At Risk, Lost) based on purchase behavior.

### 7.5 Product Analysis Queries

#### Query 10: Top Products by Revenue
```sql
SELECT
    StockCode,
    Description,
    ROUND(SUM(Quantity * UnitPrice), 2) AS product_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS times_purchased,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY StockCode, Description
ORDER BY product_revenue DESC
LIMIT 20;
```
**Purpose**: Identifies best-performing products by revenue with supporting metrics.

#### Query 11: Slow-Moving Products
```sql
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity,
    COUNT(DISTINCT InvoiceNo) AS times_purchased,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY StockCode, Description
HAVING total_quantity < 10 AND times_purchased < 5
ORDER BY total_quantity ASC;
```
**Purpose**: Identifies products with low sales volume (candidates for discounting or discontinuation).

### 7.6 Time-Based Analysis

#### Query 12: Hourly Sales Pattern
```sql
SELECT
    CAST(strftime('%H', InvoiceDate) AS INTEGER) AS hour_of_day,
    COUNT(DISTINCT InvoiceNo) AS num_invoices,
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY hour_of_day
ORDER BY hour_of_day;
```
**Purpose**: Identifies peak shopping hours throughout the day.

#### Query 13: Day of Week Analysis
```sql
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
    ROUND(SUM(Quantity * UnitPrice), 2) AS revenue
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY day_of_week
ORDER BY revenue DESC;
```
**Purpose**: Analyzes which days of the week generate the most sales.

### 7.7 Cohort Analysis

#### Query 14: Customer Cohort Analysis
```sql
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(InvoiceDate) AS first_purchase_date
    FROM online_retail
    WHERE CustomerID IS NOT NULL AND Quantity > 0
    GROUP BY CustomerID
),
cohorts AS (
    SELECT
        strftime('%Y-%m', fp.first_purchase_date) AS cohort_month,
        strftime('%Y-%m', o.InvoiceDate) AS order_month,
        COUNT(DISTINCT o.CustomerID) AS customers,
        COUNT(DISTINCT o.InvoiceNo) AS orders,
        ROUND(SUM(o.Quantity * o.UnitPrice), 2) AS revenue
    FROM online_retail o
    JOIN first_purchase fp ON o.CustomerID = fp.CustomerID
    WHERE o.Quantity > 0 AND o.UnitPrice > 0
    GROUP BY cohort_month, order_month
)
SELECT * FROM cohorts ORDER BY cohort_month, order_month;
```
**Purpose**: Tracks customer behavior over time by grouping customers by their first purchase month.

---

## 8. Data Quality & Cleaning

### 8.1 Data Cleaning Steps in `load_data.py`

The `load_data.py` script performs the following cleaning operations:

1. **Column Normalization**: Strips whitespace from column names
2. **Numeric Conversion**: Converts `Quantity` and `UnitPrice` to numeric types, handling errors gracefully
3. **Date Parsing**: Converts `InvoiceDate` to ISO-8601 format (YYYY-MM-DD HH:MM:SS)
4. **Null Handling**: Preserves NULL values for missing `CustomerID` entries
5. **Encoding Handling**: Uses `encoding_errors="ignore"` to handle special characters

### 8.2 Data Quality Checks

The analysis queries include several data quality checks:

- **Missing Values**: Identifies transactions without `CustomerID`
- **Invalid Data**: Flags negative prices, zero quantities (where inappropriate)
- **Duplicates**: Can identify duplicate invoice-line combinations
- **Cancellations**: Separates cancelled orders from valid transactions
- **Returns**: Distinguishes returns (negative quantities) from sales

### 8.3 Handling Edge Cases

- **Cancelled Invoices**: Invoices starting with 'C' are excluded from revenue calculations (unless specifically analyzing cancellations)
- **Returns**: Negative quantities are included in total revenue calculations but can be filtered for sales-only analysis
- **Guest Transactions**: Transactions without `CustomerID` are included but excluded from customer-level analyses

---

## 9. Business Insights

### 9.1 Key Performance Indicators (KPIs)

The project calculates and reports on:

- **Total Revenue**: Overall sales performance
- **Average Order Value (AOV)**: Average spending per transaction
- **Customer Lifetime Value (CLV)**: Total value of a customer over time
- **Conversion Rate**: Percentage of visitors who make a purchase
- **Return Rate**: Percentage of products returned
- **Cancellation Rate**: Percentage of orders cancelled

### 9.2 Actionable Insights

#### Customer Insights
- **Champions**: High-value customers who purchase frequently and recently
- **At-Risk Customers**: Customers who haven't purchased recently but used to be active
- **Lost Customers**: Customers who haven't purchased in a long time

#### Product Insights
- **Best Sellers**: Products generating the most revenue
- **Slow Movers**: Products with low sales volume (candidates for promotions)
- **High-Value Products**: Products with high unit prices and good sales

#### Operational Insights
- **Peak Hours**: Times of day with highest sales (for staffing decisions)
- **Seasonal Trends**: Months with highest/lowest sales (for inventory planning)
- **Geographic Performance**: Countries generating the most revenue

---

## 10. Output Files

After running `run_analysis.py`, the following CSV files are generated in the `outputs/` directory:

| File Name | Description | Use Case |
|-----------|-------------|----------|
| `top_countries.csv` | Revenue and transaction counts by country | Geographic expansion planning |
| `top_customers.csv` | Top customers by revenue and frequency | Customer relationship management |
| `top_products_by_quantity.csv` | Best-selling products by units sold | Inventory management |
| `top_products_by_revenue.csv` | Top products by revenue generated | Product portfolio optimization |
| `monthly_revenue_trend.csv` | Revenue trends by month | Financial planning and forecasting |
| `invoice_averages.csv` | Average order value and items per invoice | Pricing strategy |
| `rfm_segments.csv` | Customer segmentation by RFM scores | Marketing campaign targeting |
| `hourly_sales_pattern.csv` | Sales distribution by hour of day | Operational planning |
| `day_of_week_analysis.csv` | Sales performance by day of week | Staffing and promotion timing |
| `country_analysis.csv` | Detailed country-level metrics | Market analysis |
| `product_performance.csv` | Comprehensive product metrics | Product management |
| `customer_cohorts.csv` | Customer retention by cohort | Retention strategy |
| `data_quality_report.csv` | Data completeness and quality metrics | Data governance |

### 10.1 Using Output Files

These CSV files can be:
- **Imported into Excel** for further analysis and visualization
- **Used in BI tools** like Tableau, Power BI, or Looker
- **Visualized in Python** using matplotlib, seaborn, or plotly
- **Shared with stakeholders** for reporting and decision-making

---

## 11. Troubleshooting

### 11.1 Common Issues and Solutions

#### Issue: "FileNotFoundError: Online Retail.csv"
**Solution**: Ensure the CSV file is in the project directory and named exactly `Online Retail.csv` (case-sensitive on Linux/Mac).

#### Issue: "ModuleNotFoundError: No module named 'pandas'"
**Solution**: Install dependencies: `pip install -r requirements.txt`

#### Issue: "Database is locked"
**Solution**: Close any SQL clients or other programs accessing `online_retail.db`, then retry.

#### Issue: "Date parsing errors"
**Solution**: Check the date format in your CSV. The script handles common formats, but you may need to adjust `parse_invoice_date()` in `load_data.py`.

#### Issue: "Memory error when loading CSV"
**Solution**: The script already uses chunked reading. If issues persist, reduce `chunksize` in `load_data.py` (line 51) from 50,000 to 10,000.

#### Issue: "SQLite version too old"
**Solution**: Update SQLite or Python. SQLite comes with Python, so updating Python should resolve this.

### 11.2 Performance Optimization

- **Indexes**: The schema includes indexes on `InvoiceDate`, `CustomerID`, and `Country` for faster queries
- **Chunked Reading**: CSV is read in chunks to manage memory
- **Query Optimization**: Complex queries use CTEs (Common Table Expressions) for better performance

---

## 12. Extending the Project

### 12.1 Adding New SQL Queries

1. Open `analysis_queries.sql`
2. Add your query with a descriptive comment
3. Optionally add corresponding code in `run_analysis.py` to execute and export results

### 12.2 Adding Visualizations

Create a new Python script `visualize.py`:

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load data from outputs
df = pd.read_csv('outputs/monthly_revenue_trend.csv')

# Create visualization
plt.figure(figsize=(12, 6))
plt.plot(df['year_month'], df['revenue'])
plt.title('Monthly Revenue Trend')
plt.xlabel('Month')
plt.ylabel('Revenue (GBP)')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('outputs/monthly_revenue_chart.png')
```

### 12.3 Adding Machine Learning

You could add:
- **Customer Churn Prediction**: Predict which customers are likely to churn
- **Product Recommendation**: Recommend products based on purchase history
- **Sales Forecasting**: Forecast future sales using time series models

### 12.4 Exporting to Other Databases

To use PostgreSQL, MySQL, or other databases:
1. Modify `load_data.py` to use the appropriate database connector
2. Adjust SQL syntax in `analysis_queries.sql` for your database dialect
3. Update connection strings and credentials

---

## 13. Credits & References

### 13.1 Project Author
**Sheeza Nazeer**  

### 13.2 Dataset Citation
**Chen, D.** (2015). *Online Retail* [Dataset]. UCI Machine Learning Repository.  
DOI: [https://doi.org/10.24432/C5BW33](https://doi.org/10.24432/C5BW33)  
Dataset URL: [https://archive.ics.uci.edu/dataset/352/online+retail](https://archive.ics.uci.edu/dataset/352/online+retail)

### 13.3 Related Research

**Introductory Paper**:  
*"Data mining for the online retail industry: A case study of RFM model-based customer segmentation using data mining"*  
By Daqing Chen, Sai Laing Sain, Kun Guo (2012)  
Published in Journal of Database Marketing and Customer Strategy Management, Vol. 19, No. 3

### 13.4 Technologies Used

- **Python**: Programming language for data processing
- **SQLite**: Lightweight SQL database engine
- **Pandas**: Data manipulation library
- **SQL**: Structured Query Language for data analysis

### 13.5 License

This project uses the Online Retail dataset, which is licensed under **Creative Commons Attribution 4.0 International (CC BY 4.0)**. This project code is provided as-is for educational and analytical purposes.

---

## 📞 Contact & Support

For questions, suggestions, or contributions to this project, please contact the project author.

---

