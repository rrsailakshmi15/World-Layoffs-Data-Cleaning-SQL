# World-Layoffs-Data-Cleaning-SQL
Data cleaning project using MySQL on a World Layoffs dataset.

# World Layoffs Data Cleaning using SQL

## About the Project

This is one of my SQL practice projects. In this project, I worked with a World Layoffs dataset and cleaned the data using MySQL Workbench.

While working on this project, I tried to find duplicate records, check missing values, remove unwanted spaces, and make the data consistent. I used a separate staging table so that the original dataset would remain unchanged.

## Tools Used
- MySQL
- MySQL Workbench

## Steps I Followed

1. Created staging tables to work on a copy of the original data.
2. Identified duplicate records using `ROW_NUMBER()` and removed them.
3. Removed extra spaces from company names using `TRIM()`.
4. Checked missing values in the industry and layoff columns.
5. Removed records where both total layoffs and percentage laid off were missing.
6. Converted the date column from text format to DATE format using `STR_TO_DATE()`.
7. Standardized country names, including changing UAE to United Arab Emirates.
8. Removed the temporary columns used during data cleaning.

## Project Results

- Original dataset: 4,110 records
- Duplicate records removed: 2
- Records removed due to missing layoff information: 654
- Final cleaned dataset: 3,454 records
- Final columns: 11

One record from Appsmith still has a missing industry value. I left it blank because I could not confirm the correct industry.

## What I Learned

Through this project, I got practical experience with SQL queries such as SELECT, UPDATE, DELETE, ALTER TABLE, GROUP BY, DISTINCT, and COUNT().

I also practiced using CTEs, ROW_NUMBER(), JOIN, TRIM(), and STR_TO_DATE(). This project helped me understand how to identify duplicates, handle missing values, and clean data step by step using SQL.

## Conclusion

This project gave me a better understanding of SQL and how it is used to clean real-world datasets. It was a good learning experience, and I got more confidence in writing SQL queries.

