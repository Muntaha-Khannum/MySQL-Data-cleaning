SELECT *
FROM layoffs;

-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

DROP TABLE IF EXISTS layoffs_stagging;

CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT layoffs_stagging
SELECT * FROM layoffs
;

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions 
) AS row_num
FROM layoffs_stagging
;


WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1 
;

SELECT *
FROM layoffs_stagging
WHERE company = 'cazoo';

DROP TABLE IF EXISTS layoffs_stagging2;

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` Int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_stagging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
FROM layoffs_stagging;
;

DELETE
FROM layoffs_stagging2
WHERE row_num > 1
;

SELECT DISTINCT company
FROM layoffs_stagging2
ORDER BY 1
;

UPDATE layoffs_stagging2
SET company = TRIM(company); 

SELECT DISTINCT country
FROM layoffs_stagging2
ORDER BY 1
;

UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.';

SELECT DISTINCT industry
FROM layoffs_stagging2
ORDER BY 1
;

UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT *
FROM layoffs_stagging2
WHERE industry = '' OR industry IS NULL;

SELECT date,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_stagging2
;

UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE
;


-- 3. Look at null values and see what 

SELECT DISTINCT *
FROM layoffs_stagging2
WHERE industry = ''
OR industry IS NULL
;

SELECT t1.company, t1.location, t1.industry, t2.company, t2.location, t2.industry
FROM layoffs_stagging2 AS t1
JOIN layoffs_stagging2 AS t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND t2.industry IS NOT NULL
AND t2.industry != ''
;

UPDATE layoffs_stagging2 AS t1
JOIN layoffs_stagging2 AS t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND t2.industry IS NOT NULL
AND t2.industry != ''
;

SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

ALTER TABLE layoffs_stagging2
DROP COLUMN row_num
;

SELECT *
FROM layoffs_stagging2
;

