/*
==================================================================================
SQL Data Import Project: Detailed Workflow, Errors, and Resolutions
==================================================================================

1. Project Goal
---------------
To import CSV sales data into SQL Server with correct data types, handle NULL/blank 
values properly, and maintain data integrity in the table dbo.Retail_sales.

==================================================================================
2. Table Schema (Final Desired Format)
--------------------------------------
*/

CREATE TABLE dbo.Retail_sales (
    transactions_id   VARCHAR(50)  NOT NULL,
    sales_date        DATE         NULL,
    sales_time        TIME(7)      NULL,
    customer_id       INT          NULL,
    gender            VARCHAR(10)  NULL,
    age               INT          NULL,
    category          VARCHAR(15)  NULL,
    quantity          INT          NULL,
    price_per_unit    FLOAT        NULL,
    cogs              FLOAT        NULL,
    total_sale        FLOAT        NULL
);

/*
==================================================================================
3. Method 1: Direct Import into dbo.Retail_sales Table
------------------------------------------------------
Step 1: Import CSV directly via SQL Server Import Wizard

Issues faced:
- Date/time columns imported as VARCHAR.
- Blank/null CSV fields imported as 0 instead of NULL.
- Append option was disabled (greyed out).
- Errors when renaming or altering columns.

Errors encountered:
- Invalid column names in queries.
- sp_rename failed with Msg 15248 (ambiguous or wrong column name).
- Imported zeros instead of NULL for blanks.

Step 2: Add new columns with correct data types for date/time
*/

ALTER TABLE dbo.Retail_sales
ADD sales_date_new DATE NULL,
    sales_time_new TIME NULL;

/*
Step 3: Update new columns by converting old varchar columns
*/

UPDATE dbo.Retail_sales
SET sales_date_new = TRY_CAST(sales_date AS DATE),
    sales_time_new = TRY_CAST(sales_time AS TIME);

/*
Step 4: Drop old varchar date/time columns
*/

ALTER TABLE dbo.Retail_sales
DROP COLUMN sales_date, sales_time;

/*
Step 5: Rename new columns to original names
Note: If sp_rename fails, check column names carefully.
*/

EXEC sp_rename 'dbo.Retail_sales.sales_date_new', 'sales_date', 'COLUMN';
EXEC sp_rename 'dbo.Retail_sales.sales_time_new', 'sales_time', 'COLUMN';

/*
Step 6: Fix NULL values for numeric columns (convert zeros to NULL)
*/

UPDATE dbo.Retail_sales
SET customer_id = NULLIF(customer_id, 0),
    age = NULLIF(age, 0),
    quantity = NULLIF(quantity, 0),
    price_per_unit = NULLIF(price_per_unit, 0),
    cogs = NULLIF(cogs, 0),
    total_sale = NULLIF(total_sale, 0)
WHERE customer_id = 0 OR age = 0 OR quantity = 0 OR price_per_unit = 0 OR cogs = 0 OR total_sale = 0;

/*
Summary of Method 1:
- Direct import is faster but prone to data type conflicts and NULL mishandling.
- Manual schema fixing and data cleanup are required post-import.
- Risk of errors and careful troubleshooting needed.
*/

/*
==================================================================================
4. Method 2: Recommended - Use a Staging Table for CSV Import
-------------------------------------------------------------
Step 1: Create staging table with all columns as VARCHAR for flexible import
*/

CREATE TABLE dbo.Retail_sales_staging (
    transactions_id   VARCHAR(100) NULL,
    sales_date        VARCHAR(100) NULL,
    sales_time        VARCHAR(100) NULL,
    customer_id       VARCHAR(100) NULL,
    gender            VARCHAR(100) NULL,
    age               VARCHAR(100) NULL,
    category          VARCHAR(100) NULL,
    quantity          VARCHAR(100) NULL,
    price_per_unit    VARCHAR(100) NULL,
    cogs              VARCHAR(100) NULL,
    total_sale        VARCHAR(100) NULL
);

/*
Step 2: Import CSV into dbo.Retail_sales_staging using Import Wizard or BULK INSERT.
- No data type conflicts.
- Blank/null values import as empty strings, not zero.
*/

/*
Step 3: Insert into dbo.Retail_sales with proper type conversion and NULL handling
*/

INSERT INTO dbo.Retail_sales (
    transactions_id,
    sales_date,
    sales_time,
    customer_id,
    gender,
    age,
    category,
    quantity,
    price_per_unit,
    cogs,
    total_sale
)
SELECT
    transactions_id,
    TRY_CAST(NULLIF(sales_date, '') AS DATE),
    TRY_CAST(NULLIF(sales_time, '') AS TIME),
    TRY_CAST(NULLIF(customer_id, '') AS INT),
    gender,
    TRY_CAST(NULLIF(age, '') AS INT),
    category,
    TRY_CAST(NULLIF(quantity, '') AS INT),
    TRY_CAST(NULLIF(price_per_unit, '') AS FLOAT),
    TRY_CAST(NULLIF(cogs, '') AS FLOAT),
    TRY_CAST(NULLIF(total_sale, '') AS FLOAT)
FROM dbo.Retail_sales_staging;

/*
NULLIF(value, '') converts empty strings to NULL.
TRY_CAST attempts data type conversion; if it fails, returns NULL.
Ensures NULLs remain NULL and no zeros are forced.
*/

/*
Step 4: Optional clean-up of staging table
*/

TRUNCATE TABLE dbo.Retail_sales_staging;



