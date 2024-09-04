
CREATE TABLE layoffs_staging
LIKE dayoffs
;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs
;

-- Remove Duplicate


CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1
;


-- Standardizing

UPDATE layoffs_staging_2
SET company = TRIM(company)
;

UPDATE layoffs_staging_2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%"
;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE "United States%"
;

UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y")
;

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE 
;


-- Reomve Null

UPDATE layoffs_staging_2
SET industry = NULL 
WHERE industry = ""
;

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT null 
;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- DROP ADDED COLUMN

ALTER TABLE layoffs_staging_2
DROP COLUMN row_num
;
