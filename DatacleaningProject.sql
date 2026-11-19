SELECT * 
FROM world_layoffs.layoffs;


-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
USE world_layoffs;
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;



-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates

# First let's check for duplicates

SELECT *
FROM world_layoffs.layoffs_staging;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoffs.layoffs_staging;
        
        
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;


-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- these are our real duplicates 
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

-- now you may want to write it like this:
USE world_layoffs;

DESCRIBE layoffs_staging;

ALTER TABLE layoffs_staging
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY; 


DELETE FROM layoffs_staging
WHERE row_id IN
(
    SELECT row_id
    FROM
    (
        SELECT row_id,
            ROW_NUMBER() OVER (
                PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised
                ORDER BY row_id
            ) AS row_num
        FROM layoffs_staging
    ) AS duplicates
    WHERE row_num > 1
);


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, row_num
	FROM DELETE_CTE
) AND row_num > 1;


-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- so let's do it!!

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;


SELECT *
FROM world_layoffs.layoffs_staging
;

USE world_layoffs;

DESCRIBE layoffs;

DESCRIBE layoffs_staging;

DESCRIBE world_layoffs.layoffs_staging3;

SELECT *
FROM layoffs_staging
LIMIT 5;

CREATE TABLE `world_layoffs`.`layoffs_staging3` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,`location`,`industry`,`total_laid_off`,`percentage_laid_off`,`date`,`stage`,`country`,`funds_raised`,`row_num`)
SELECT `company`,`location`,`industry`,`total_laid_off`,`percentage_laid_off`,`date`,`stage`,`country`,`funds_raised`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging3;

-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM world_layoffs.layoffs_staging3
WHERE row_num >= 2;







