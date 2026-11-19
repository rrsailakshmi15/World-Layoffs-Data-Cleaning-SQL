-- Check whether the table exists
USE world_layoffs;
SHOW TABLES;
SELECT *FROM layoffs;
SELECT COUNT(*)FROM layoffs;
SELECT *FROM layoffs_staging;
DESCRIBE layoffs;
DESCRIBE layoffs_staging;
SELECT COUNT(*) FROM layoffs;
SELECT COUNT(*) FROM layoffs_staging;
SELECT COUNT(*) AS original_count
FROM layoffs;
SELECT COUNT(*) AS staging_count
FROM layoffs_staging;
SELECT *FROM layoffs LIMIT 5;
CREATE TABLE layoffs_staging_new LIKE layoffs;
INSERT INTO layoffs_staging_new
SELECT *FROM layoffs;
SELECT COUNT(*) 
FROM layoffs_staging_new;
DESCRIBE layoffs_staging_new;
-- Identify duplicate records
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised
) AS row_num
FROM layoffs_staging_new;

WITH duplicate_check AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry,
        total_laid_off, percentage_laid_off,
        `date`, stage, country, funds_raised
    ) AS row_num
    FROM layoffs_staging_new
)
SELECT *
FROM duplicate_check
WHERE row_num > 1;

ALTER TABLE layoffs_staging_new
ADD COLUMN row_num INT;

SHOW KEYS FROM layoffs_staging_new;

ALTER TABLE layoffs_staging_new
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
DESCRIBE layoffs_staging_new;

UPDATE layoffs_staging_new t
JOIN (
    SELECT row_id,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry,
               total_laid_off, percentage_laid_off,
               `date`, stage, country, funds_raised
           ) AS rn
    FROM layoffs_staging_new
) duplicates
ON t.row_id = duplicates.row_id
SET t.row_num = duplicates.rn;

SELECT *
FROM layoffs_staging_new
WHERE row_num > 1;
-- Delete duplicate records
DELETE FROM layoffs_staging_new
WHERE row_num > 1;
-- Check the total records
SELECT COUNT(*)
FROM layoffs_staging_new;
-- Check industry values
SELECT DISTINCT industry
FROM layoffs_staging_new
ORDER BY industry; 
-- Check company names with extra spaces
SELECT company
FROM layoffs_staging_new
WHERE company <> TRIM(company);    
-- Remove unwanted spaces
UPDATE layoffs_staging_new
SET company = TRIM(company);
 -- Verify the result
SELECT company
FROM layoffs_staging_new
WHERE company <> TRIM(company);

-- Check industry values again
SELECT DISTINCT industry
FROM layoffs_staging_new
ORDER BY industry;
-- Check Crypto industry consistency
SELECT DISTINCT industry
FROM layoffs_staging_new
WHERE industry LIKE '%Crypto%';
-- Standardize Crypto values
UPDATE layoffs_staging_new
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency';
-- Check blank industry values
SELECT *
FROM layoffs_staging_new
WHERE industry IS NULL
   OR industry = '';
-- Check Appsmith records
SELECT company, location, industry
FROM layoffs_staging_new
WHERE company = 'Appsmith';   
-- Check all NULL and blank values
SELECT
    COUNT(*) AS missing_industry
FROM layoffs_staging_new
WHERE industry IS NULL OR TRIM(industry) = '';  
-- Check NULL values in important columns
SELECT *
FROM layoffs_staging_new
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL;
-- Count missing values
SELECT
    COUNT(*) AS total_missing_records
FROM layoffs_staging_new
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL;
-- Check empty values
SELECT *
FROM layoffs_staging_new
WHERE total_laid_off = ''
   OR percentage_laid_off = '';
-- Check missing values in both columns
SELECT COUNT(*) AS missing_count
FROM layoffs_staging_new
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');   
-- 
SELECT COUNT(*)
FROM layoffs_staging_new
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- 
SELECT
    SUM(total_laid_off IS NULL) AS total_nulls,
    SUM(total_laid_off = '') AS total_blanks,
    SUM(percentage_laid_off IS NULL) AS percentage_nulls,
    SUM(percentage_laid_off = '') AS percentage_blanks,
    SUM(
        (total_laid_off IS NULL OR TRIM(total_laid_off) = '')
        AND
        (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '')
    ) AS both_missing
FROM layoffs_staging_new;

-- Delete records where both values are missing
DELETE FROM layoffs_staging_new
WHERE (total_laid_off IS NULL OR TRIM(total_laid_off) = '')
AND (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '');

-- verify
SELECT COUNT(*) AS remaining_missing_records
FROM layoffs_staging_new
WHERE (total_laid_off IS NULL OR TRIM(total_laid_off) = '')
AND (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '');
--  checking date foramt
SELECT `date`
FROM layoffs_staging_new
LIMIT 10;
-- convert date values
UPDATE layoffs_staging_new
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
--  Change the column data type
ALTER TABLE layoffs_staging_new
MODIFY COLUMN `date` DATE;
-- verify
SELECT `date`
FROM layoffs_staging_new
LIMIT 10;
-- Change the column type to DATE
ALTER TABLE layoffs_staging_new
MODIFY COLUMN `date` DATE;
-- 
DESCRIBE layoffs_staging_new;

-- Clean the country column
SELECT DISTINCT country
FROM layoffs_staging_new
ORDER BY country;
-- Check how many records use each name
SELECT country, COUNT(*) AS total
FROM layoffs_staging_new
WHERE country IN ('UAE', 'United Arab Emirates')
GROUP BY country;  
-- Standardize the country name
UPDATE layoffs_staging_new
SET country = 'United Arab Emirates'
WHERE country = 'UAE'; 
-- Remove any accidental spaces
UPDATE layoffs_staging_new
SET country = TRIM(country);
-- verify
SELECT DISTINCT country
FROM layoffs_staging_new
ORDER BY country;
-- Check the industry column
SELECT DISTINCT industry
FROM layoffs_staging_new
ORDER BY industry;
-- Check blank industry values
SELECT COUNT(*) AS missing_industry
FROM layoffs_staging_new
WHERE industry IS NULL OR TRIM(industry) = '';
-- Check total records after cleaning
SELECT COUNT(*) AS total_clean_records
FROM layoffs_staging_new;  
-- 
SELECT *
FROM layoffs_staging_new
WHERE row_num > 1;
 -- Remove temporary helper columns  
 ALTER TABLE layoffs_staging_new
DROP COLUMN row_num,
DROP COLUMN row_id;  
-- Verify the cleaned table
DESCRIBE layoffs_staging_new;   
SELECT *
FROM layoffs_staging_new
LIMIT 10; 
DESCRIBE layoffs_staging_new;
SHOW COLUMNS FROM layoffs_staging_new;
-- removing helper column
ALTER TABLE layoffs_staging_new
DROP PRIMARY KEY,
DROP COLUMN row_num,
DROP COLUMN row_id;

-- 
SHOW COLUMNS FROM layoffs_staging_new;
