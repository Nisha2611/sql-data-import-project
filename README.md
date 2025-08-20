# 🧾 SQL Data Import Project

A practical SQL Server project focused on importing, cleaning, and transforming sales data from CSV files. It highlights real-world issues like data type mismatches, NULL handling, and schema corrections during data import workflows.

---

## 📌 Project Objective

To import raw sales data from a CSV file into a production SQL Server table while ensuring:

- Correct data types are enforced
- NULL/blank values are handled properly (not treated as 0)
- Data is cleaned and ready for analysis

---

## 📂 Dataset Structure

The original dataset includes:

- `transaction_id`: Unique identifier
- `sales_date`: Date of sale
- `sales_time`: Time of sale
- `customer_id`, `gender`, `age`: Customer info
- `category`, `quantity`, `price_per_unit`, `cogs`, `total_sale`: Transaction details

---

## 🧪 Final Table Schema

```sql
CREATE TABLE dbo.Retail_sales (
    transactions_id     VARCHAR(50)  NOT NULL,
    sales_date          DATE         NULL,
    sales_time          TIME(7)      NULL,
    customer_id         INT          NULL,
    gender              VARCHAR(10)  NULL,
    age                 INT          NULL,
    category            VARCHAR(15)  NULL,
    quantity            INT          NULL,
    price_per_unit      FLOAT        NULL,
    cogs                FLOAT        NULL,
    total_sale          FLOAT        NULL
);


****🧰 Method 1: Direct Import into Retail_sales
**
**❗ Issues Faced:****

Date/Time columns imported as VARCHAR

Blank cells were converted to 0 instead of NULL

Couldn’t rename or alter columns easily due to:

Msg 15248, Level 11, State 1
Either the parameter @objname is ambiguous or the claimed @objtype (COLUMN) is wrong.


**✅ Fixes Applied:**

-- Add correct-typed columns
ALTER TABLE dbo.Retail_sales
ADD sales_date_new DATE NULL,
    sales_time_new TIME NULL;

-- Convert values safely
UPDATE dbo.Retail_sales
SET sales_date_new = TRY_CAST(sales_date AS DATE),
    sales_time_new = TRY_CAST(sales_time AS TIME);

-- Drop old columns
ALTER TABLE dbo.Retail_sales DROP COLUMN sales_date, sales_time;

-- Rename new ones
EXEC sp_rename 'dbo.Retail_sales.sales_date_new', 'sales_date', 'COLUMN';
EXEC sp_rename 'dbo.Retail_sales.sales_time_new', 'sales_time', 'COLUMN';


🔄 Handling NULLs:

UPDATE dbo.Retail_sales
SET customer_id = NULLIF(customer_id, 0),
    age = NULLIF(age, 0),
    quantity = NULLIF(quantity, 0),
    price_per_unit = NULLIF(price_per_unit, 0),
    cogs = NULLIF(cogs, 0),
    total_sale = NULLIF(total_sale, 0)
WHERE customer_id = 0 OR age = 0 OR quantity = 0 OR price_per_unit = 0 OR cogs = 0 OR total_sale = 0;



✅ Method 2 (Recommended): Using a Staging Table
**Step 1: Create Staging Table**

CREATE TABLE dbo.Retail_sales_staging (
    transactions_id     VARCHAR(100),
    sales_date          VARCHAR(100),
    sales_time          VARCHAR(100),
    customer_id         VARCHAR(100),
    gender              VARCHAR(100),
    age                 VARCHAR(100),
    category            VARCHAR(100),
    quantity            VARCHAR(100),
    price_per_unit      VARCHAR(100),
    cogs                VARCHAR(100),
    total_sale          VARCHAR(100)
);


**Step 2: Import CSV → Retail_sales_staging**

No data type conflicts

Empty cells are preserved as '' (not 0)


**Step 3: Clean Insert into Final Table**

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


**Step 4: Clean Up**

TRUNCATE TABLE dbo.Retail_sales_staging;



**🔍 Error Summary**

| Error                       | Cause                       | Fix                              |
| --------------------------- | --------------------------- | -------------------------------- |
| Data type mismatch          | CSV → Wrong mapping         | Use staging table                |
| NULLs converted to 0        | Default import behavior     | Use `NULLIF()`                   |
| `sp_rename` errors          | Wrong column name or syntax | Use fully qualified column names |
| Append rows option disabled | Schema mismatch             | Use staging to reformat          |
| Import failed for numeric   | Wrong datatype              | Use `TRY_CAST()`                 |



**🏁 Final Recommendation**

Always use a staging table when importing raw data:

Avoids schema conflicts

Better error handling

Preserves NULL values

Easier to debug & scale



**🛠 Tools Used**

SQL Server Management Studio (SSMS)

CSV Import Wizard

Git & GitHub

Microsoft Word (Project Report)



**📁 Project Files Overview**

File/Folder Name	                               Description
SQL Data Import Project Report.docx	 Comprehensive project documentation including objectives, methods, errors, and                                               resolutions.
README.md	                         Clean and concise GitHub-facing project summary with highlights and usage instructions.
SQL_Data_Import_Project.sql	         Full SQL script for both import methods — includes schema creation, data type fixes, and NULL handling.


👩‍💻 Author

Nisha2611
Aspiring Data Analyst | Passionate about SQL & Data Cleaning
LinkedIn
🔗 www.linkedin.com/in/
nisha-khatoon-a866b633b

🔗 GitHub Profile
https://github.com/Nisha2611



**💬 Feedback**

Have suggestions? Open an issue or drop a ⭐ if you found it helpful!


