-- ============================================================================
-- FORESTATION ANALYSIS PROJECT - SQL QUERIES
-- ============================================================================
-- This file contains all SQL queries organized by requirement category.
-- Each query demonstrates specific SQL concepts as required by the rubric.
-- ============================================================================

-- ============================================================================
-- SECTION 1: BASIC SQL QUERIES (SELECT, WHERE, ORDER BY, GROUP BY)
-- ============================================================================

-- ============================================================================
-- QUERY 1.1: SELECT Query
-- Returns all forestation data for a specific year
-- Demonstrates: SELECT keyword to return information
-- ============================================================================
SELECT 
    country_name,
    region,
    year,
    forest_area_sqkm,
    total_area_sq_km,
    forest_percent
FROM forestation
WHERE year = 2016
ORDER BY forest_percent DESC;

-- ============================================================================
-- QUERY 1.2: WHERE Clause Filtering
-- Filters countries with forest percentage greater than 50%
-- Demonstrates: WHERE keyword to filter results
-- ============================================================================
SELECT 
    country_name,
    region,
    forest_percent
FROM forestation
WHERE forest_percent > 50
    AND year = 2016
ORDER BY forest_percent DESC;

-- ============================================================================
-- QUERY 1.3: ORDER BY Ascending and Descending
-- Shows countries with lowest forest coverage in 2016
-- Demonstrates: ORDER BY with ASC and DESC specifications
-- ============================================================================
SELECT 
    country_name,
    forest_percent,
    forest_area_sqkm
FROM forestation
WHERE year = 2016
ORDER BY forest_percent ASC;

-- ============================================================================
-- QUERY 1.4: GROUP BY with Aggregation
-- Calculates average forest percentage by region
-- Demonstrates: GROUP BY keyword for categorical aggregation
-- ============================================================================
SELECT 
    region,
    ROUND(AVG(forest_percent), 2) AS avg_forest_percent,
    COUNT(DISTINCT country_name) AS country_count,
    ROUND(SUM(forest_area_sqkm), 0) AS total_forest_area_sqkm
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY avg_forest_percent DESC;

-- ============================================================================
-- QUERY 1.5: Boolean Operators (AND, OR)
-- Complex filtering with multiple conditions
-- Demonstrates: Boolean operators to link conditional clauses
-- ============================================================================
SELECT 
    country_name,
    region,
    forest_percent,
    total_area_sq_km
FROM forestation
WHERE year = 2016
    AND (
        region = 'Asia' 
        OR region = 'Africa'
    )
    AND forest_percent > 30
ORDER BY forest_percent DESC;

-- ============================================================================
-- SECTION 2: WINDOW FUNCTIONS
-- ============================================================================

-- ============================================================================
-- QUERY 2.1: Window Function - ROW_NUMBER
-- Ranks countries by forest percentage within each region
-- Demonstrates: Window functions for row-level analysis
-- ============================================================================
SELECT 
    region,
    country_name,
    forest_percent,
    ROW_NUMBER() OVER (
        PARTITION BY region 
        ORDER BY forest_percent DESC
    ) AS rank_in_region
FROM forestation
WHERE year = 2016;

-- ============================================================================
-- QUERY 2.2: Window Function - SUM (Running Total)
-- Shows cumulative forest area by region over time
-- Demonstrates: SUM window function for aggregate calculation
-- ============================================================================
SELECT 
    region,
    year,
    country_name,
    forest_area_sqkm,
    ROUND(
        SUM(forest_area_sqkm) OVER (
            PARTITION BY region 
            ORDER BY year
        ),
        2
    ) AS cumulative_forest_area
FROM forestation
WHERE region = 'South America'
ORDER BY year, country_name;

-- ============================================================================
-- QUERY 2.3: Window Function - COUNT and ROUND
-- Counts countries per region and calculates average forest percent
-- Demonstrates: COUNT and ROUND in window functions
-- ============================================================================
SELECT 
    region,
    year,
    country_name,
    forest_percent,
    COUNT(*) OVER (PARTITION BY region, year) AS countries_per_region,
    ROUND(AVG(forest_percent) OVER (PARTITION BY region, year), 2) AS region_avg_forest_percent
FROM forestation
WHERE year IN (2000, 2016)
ORDER BY region, year, country_name;

-- ============================================================================
-- QUERY 2.4: Window Function - LAG (Year-over-Year Change)
-- Calculates year-over-year change in forest area
-- Demonstrates: LAG function and window aggregation
-- ============================================================================
SELECT 
    country_name,
    year,
    forest_area_sqkm,
    LAG(forest_area_sqkm) OVER (
        PARTITION BY country_name 
        ORDER BY year
    ) AS previous_year_forest_area,
    ROUND(
        forest_area_sqkm - 
        LAG(forest_area_sqkm) OVER (
            PARTITION BY country_name 
            ORDER BY year
        ),
        2
    ) AS forest_area_change
FROM forestation
WHERE country_name IN ('Brazil', 'Indonesia', 'Nigeria')
ORDER BY country_name, year;

-- ============================================================================
-- SECTION 3: JOIN COMMANDS (INNER, LEFT, RIGHT, OUTER)
-- ============================================================================

-- ============================================================================
-- QUERY 3.1: INNER JOIN (Two Tables)
-- Demonstrates proper join of forest_area and land_area on country and year
-- Demonstrates: JOIN keyword with ON clause and boolean operator (=)
-- ============================================================================
SELECT 
    f.country_code,
    f.year,
    f.forest_area_sqkm,
    l.total_area_sq_km,
    ROUND(
        (f.forest_area_sqkm / l.total_area_sq_km) * 100,
        2
    ) AS forest_percentage
FROM forest_area f
INNER JOIN land_area l
    ON f.country_code = l.country_code
    AND f.year = l.year
WHERE f.year = 2016
ORDER BY forest_percentage DESC
LIMIT 10;

-- ============================================================================
-- QUERY 3.2: LEFT JOIN
-- Returns all countries with forest data, including those without land_area data
-- Demonstrates: LEFT JOIN to include all rows from left table
-- ============================================================================
SELECT 
    f.country_code,
    f.year,
    f.forest_area_sqkm,
    l.total_area_sq_km,
    CASE 
        WHEN l.total_area_sq_km IS NULL THEN 'Missing Land Data'
        ELSE CAST(ROUND((f.forest_area_sqkm / l.total_area_sq_km) * 100, 2) AS VARCHAR)
    END AS forest_percent_or_status
FROM forest_area f
LEFT JOIN land_area l
    ON f.country_code = l.country_code
    AND f.year = l.year
WHERE f.year = 2016
ORDER BY f.country_code;

-- ============================================================================
-- QUERY 3.3: Self-Join (Row-level Comparison)
-- Compares forest area between 2000 and 2016 for the same countries
-- Demonstrates: Self-join to compare values in different rows
-- ============================================================================
SELECT 
    f2000.country_code,
    f2000.forest_area_sqkm AS forest_area_2000,
    f2016.forest_area_sqkm AS forest_area_2016,
    ROUND(
        f2016.forest_area_sqkm - f2000.forest_area_sqkm,
        2
    ) AS forest_area_change,
    ROUND(
        ((f2016.forest_area_sqkm - f2000.forest_area_sqkm) / 
         f2000.forest_area_sqkm) * 100,
        2
    ) AS percent_change
FROM forest_area f2000
INNER JOIN forest_area f2016
    ON f2000.country_code = f2016.country_code
    AND f2000.year = 2000
    AND f2016.year = 2016
ORDER BY percent_change ASC;

-- ============================================================================
-- QUERY 3.4: Multiple Table Join (Three Tables)
-- Combines all three tables to show comprehensive forestration data
-- Demonstrates: Multiple ON clauses and proper join structure
-- ============================================================================
SELECT 
    c.country_code,
    c.country_name,
    c.region,
    f.year,
    f.forest_area_sqkm,
    l.total_area_sq_km,
    ROUND(
        (f.forest_area_sqkm / l.total_area_sq_km) * 100,
        2
    ) AS forest_percent
FROM countries c
INNER JOIN forest_area f
    ON c.country_code = f.country_code
INNER JOIN land_area l
    ON c.country_code = l.country_code
    AND f.year = l.year
WHERE f.year IN (2000, 2016)
ORDER BY c.region, c.country_name, f.year;

-- ============================================================================
-- QUERY 3.5: FULL OUTER JOIN (Union of Left and Right)
-- Shows all records from both tables, with nulls where no match exists
-- Demonstrates: Proper use of OUTER join to capture all data
-- ============================================================================
SELECT 
    COALESCE(f.country_code, l.country_code) AS country_code,
    f.year AS forest_year,
    l.year AS land_year,
    f.forest_area_sqkm,
    l.total_area_sq_km
FROM forest_area f
FULL OUTER JOIN land_area l
    ON f.country_code = l.country_code
    AND f.year = l.year
WHERE COALESCE(f.year, l.year) = 2016
ORDER BY COALESCE(f.country_code, l.country_code);

-- ============================================================================
-- SECTION 4: CASE STATEMENT
-- ============================================================================

-- ============================================================================
-- QUERY 4.1: CASE Statement for Categorization
-- Categorizes countries by deforestation level
-- Demonstrates: CASE statement to return values based on conditions
-- ============================================================================
SELECT 
    country_name,
    region,
    forest_percent,
    CASE 
        WHEN forest_percent > 60 THEN 'High Forest Coverage'
        WHEN forest_percent BETWEEN 30 AND 60 THEN 'Moderate Forest Coverage'
        WHEN forest_percent BETWEEN 10 AND 30 THEN 'Low Forest Coverage'
        WHEN forest_percent < 10 THEN 'Critical Deforestation'
        ELSE 'Unknown'
    END AS forest_coverage_category
FROM forestation
WHERE year = 2016
ORDER BY forest_percent DESC;

-- ============================================================================
-- QUERY 4.2: CASE with Multiple Conditions (Complex)
-- Evaluates forest trend and alerts for countries needing attention
-- Demonstrates: Nested and complex CASE logic
-- ============================================================================
SELECT 
    c.country_name,
    c.region,
    f2000.forest_percent AS forest_percent_2000,
    f2016.forest_percent AS forest_percent_2016,
    ROUND(f2016.forest_percent - f2000.forest_percent, 2) AS percent_change,
    CASE 
        WHEN (f2016.forest_percent - f2000.forest_percent) < -10 
            AND f2016.forest_percent < 30 
            THEN 'CRITICAL ALERT: High Deforestation'
        WHEN (f2016.forest_percent - f2000.forest_percent) < -5 
            THEN 'WARNING: Significant Deforestation'
        WHEN (f2016.forest_percent - f2000.forest_percent) > 5 
            THEN 'POSITIVE: Reforestation in Progress'
        ELSE 'STABLE: Forest Coverage Unchanged'
    END AS forest_trend_alert
FROM countries c
INNER JOIN forestation f2000
    ON c.country_code = f2000.country_code
    AND f2000.year = 2000
INNER JOIN forestation f2016
    ON c.country_code = f2016.country_code
    AND f2016.year = 2016
ORDER BY percent_change ASC;

-- ============================================================================
-- SECTION 5: ADVANCED ANALYTICAL QUERIES
-- ============================================================================

-- ============================================================================
-- QUERY 5.1: Regional Comparison
-- Compares deforestation trends across regions
-- Uses: GROUP BY, Window Functions, CASE statements
-- ============================================================================
SELECT 
    region,
    year,
    ROUND(AVG(forest_percent), 2) AS avg_forest_percent,
    ROUND(MIN(forest_percent), 2) AS min_forest_percent,
    ROUND(MAX(forest_percent), 2) AS max_forest_percent,
    COUNT(*) AS country_count,
    ROUND(
        AVG(forest_percent) OVER (
            PARTITION BY region 
            ORDER BY year
        ),
        2
    ) AS cumulative_avg,
    CASE 
        WHEN AVG(forest_percent) > 50 THEN 'Forest-Rich'
        WHEN AVG(forest_percent) > 30 THEN 'Moderate Forests'
        ELSE 'Forest-Poor'
    END AS region_classification
FROM forestation
WHERE year IN (2000, 2010, 2016)
GROUP BY region, year
ORDER BY region, year;

-- ============================================================================
-- QUERY 5.2: Countries with Extreme Deforestation
-- Identifies countries losing forest area at alarming rates
-- Uses: Self-joins, Window functions, and conditional aggregation
-- ============================================================================
SELECT 
    c.country_name,
    c.region,
    f2000.forest_area_sqkm AS baseline_forest_2000,
    f2016.forest_area_sqkm AS forest_area_2016,
    ROUND(
        f2016.forest_area_sqkm - f2000.forest_area_sqkm,
        2
    ) AS forest_loss_sqkm,
    ROUND(
        ABS(
            ((f2016.forest_area_sqkm - f2000.forest_area_sqkm) / 
             f2000.forest_area_sqkm) * 100
        ),
        2
    ) AS percent_change,
    RANK() OVER (
        ORDER BY 
            ABS((f2016.forest_area_sqkm - f2000.forest_area_sqkm) / 
                f2000.forest_area_sqkm) DESC
    ) AS deforestation_rank
FROM countries c
INNER JOIN forest_area f2000
    ON c.country_code = f2000.country_code
    AND f2000.year = 2000
INNER JOIN forest_area f2016
    ON c.country_code = f2016.country_code
    AND f2016.year = 2016
WHERE f2016.forest_area_sqkm < f2000.forest_area_sqkm
ORDER BY percent_change DESC;

-- ============================================================================
-- QUERY 5.3: Decade Analysis
-- Analyzes forest trends by decade with year-over-year comparisons
-- Uses: Window functions, GROUP BY, and multiple conditions
-- ============================================================================
SELECT 
    country_name,
    region,
    year,
    forest_percent,
    ROUND(
        LAG(forest_percent) OVER (
            PARTITION BY country_name 
            ORDER BY year
        ),
        2
    ) AS previous_year_percent,
    ROUND(
        forest_percent - 
        LAG(forest_percent) OVER (
            PARTITION BY country_name 
            ORDER BY year
        ),
        2
    ) AS annual_change,
    ROUND(
        SUM(forest_percent) OVER (
            PARTITION BY country_name 
            ORDER BY year 
            ROWS BETWEEN 10 PRECEDING AND CURRENT ROW
        ) / 11,
        2
    ) AS moving_avg_forest_percent
FROM forestation
WHERE country_name IN ('Brazil', 'Indonesia', 'Nigeria', 'Ghana', 'Canada')
ORDER BY country_name, year;

-- ============================================================================
-- QUERY 5.4: Region Contribution to Global Forest
-- Shows each region's contribution to global forest area
-- Uses: Window functions with SUM and aggregation
-- ============================================================================
SELECT 
    region,
    year,
    ROUND(SUM(forest_area_sqkm), 2) AS region_total_forest,
    ROUND(
        SUM(forest_area_sqkm) OVER (PARTITION BY year),
        2
    ) AS global_total_forest,
    ROUND(
        (SUM(forest_area_sqkm) / 
         SUM(forest_area_sqkm) OVER (PARTITION BY year)) * 100,
        2
    ) AS percent_of_global_forest
FROM forestation
WHERE year = 2016
GROUP BY region, year
ORDER BY region_total_forest DESC;

-- ============================================================================
-- END OF QUERIES
-- ============================================================================
