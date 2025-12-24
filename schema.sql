-- Schema for Online Retail dataset in SQLite

DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
    InvoiceNo    TEXT,
    StockCode    TEXT,
    Description  TEXT,
    Quantity     INTEGER,
    InvoiceDate  TEXT,       -- stored as ISO-8601 string (YYYY-MM-DD HH:MM:SS)
    UnitPrice    REAL,
    CustomerID   TEXT,
    Country      TEXT
);

-- Optional index to speed up common queries
CREATE INDEX IF NOT EXISTS idx_online_retail_invoicedate
    ON online_retail (InvoiceDate);

CREATE INDEX IF NOT EXISTS idx_online_retail_customer
    ON online_retail (CustomerID);

CREATE INDEX IF NOT EXISTS idx_online_retail_country
    ON online_retail (Country);



