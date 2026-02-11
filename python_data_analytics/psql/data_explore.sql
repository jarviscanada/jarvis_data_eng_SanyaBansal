---Inspect the table schema

\d+ retail;

--Q1: Show first 10 rows
SELECT * FROM retail LIMIT 10;

--Q2: Check # of records

SELECT COUNT(*) FROM retail;

--Q3: number of clients (e.g. unique client ID)

SELECT COUNT (DISTINCT customer_id) FROM retail;

--Q4: invoice date range (e.g. max/min dates)

SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

--Q5: number of SKU/merchants (e.g. unique stock code)

SELECT COUNT (DISTINCT stock_code) FROM retail;

--Q6: Calculate average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
--an invoice consists of one or more items where each item is a row in the df
--hint: you need to use GROUP BY and HAVING

SELECT AVG(invoice_total) AS avg FROM (
    SELECT
        invoice_no,
        SUM(quantity * unit_price) AS invoice_total FROM retail
        GROUP BY invoice_no
        HAVING SUM(quantity * unit_price) > 0
)t ;

--Q7: Calculate total revenue (e.g. sum of unit_price * quantity)

SELECT SUM(unit_price * quantity) FROM retail;

--Q8: Calculate total revenue by YYYYMM
--hints 
--Create a new YYYMM column e.g. you want convert 2010-10-28 (datetime) to 201010 (integer). 201010 = 2010 *100 + 10.
--The following functions might be useful: extract, cast

SELECT
    CAST(EXTRACT(YEAR FROM invoice_date) * 100
       + EXTRACT(MONTH FROM invoice_date) AS INTEGER) AS yyyymm,
    SUM(quantity * unit_price) AS total_revenue
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;


