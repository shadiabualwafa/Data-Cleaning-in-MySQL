-- Select all columns and rows from the `layoffs_staging_2` table
SELECT *
FROM layoffs_staging_2
;

-- Find the maximum values for `total_laid_off` and `percentage_laid_off` columns in the `layoffs_staging_2` table
SELECT  MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2
;

-- Retrieve all columns and rows where `percentage_laid_off` equals 1, ordered by `funds_raised_millions` in descending order
SELECT  *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- Calculate the total number of layoffs per company and order by the total number of layoffs in descending order
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
;

-- Calculate the total number of layoffs per country and order by the total number of layoffs in descending order
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC
;

-- Calculate the total number of layoffs per industry and order by the total number of layoffs in descending order
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC
;

-- Find the earliest and latest dates in the `date` column
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2
;

-- Calculate the total number of layoffs per date and order by date in descending order
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY `date`
ORDER BY 1 DESC
;

-- Calculate the total number of layoffs per year and order by year in descending order
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC 
;

-- Calculate the total number of layoffs per stage and order by the total number of layoffs in descending order
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC 
;

-- Calculate the total number of layoffs per month and order by month in ascending order
-- Assumes `date` is in YYYY-MM-DD format and extracts the year and month
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
;

-- Calculate the total number of layoffs per month and compute the running total (cumulative sum) of layoffs over months
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off,
SUM(total_off) OVER(ORDER BY `Month`) as rolling_total
From Rolling_Total
;

-- Calculate the total number of layoffs per company per year and order by the total number of layoffs in descending order
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

-- Rank companies within each year based on the total number of layoffs using a dense ranking method
WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC)
FROM Company_Year
;
