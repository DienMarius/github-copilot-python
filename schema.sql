-- ============================================================================
-- FORESTATION ANALYSIS PROJECT - DATABASE SCHEMA
-- ============================================================================
-- This script creates the database structure for the forestation analysis.
-- It includes three base tables and the forestation view that combines them.
-- ============================================================================

-- ============================================================================
-- TABLE 1: countries
-- Contains information about countries and their regions
-- ============================================================================
CREATE TABLE IF NOT EXISTS countries (
    country_code VARCHAR(3) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- ============================================================================
-- TABLE 2: forest_area
-- Contains forest area data for each country by year (in millions of hectares)
-- ============================================================================
CREATE TABLE IF NOT EXISTS forest_area (
    country_code VARCHAR(3),
    year INTEGER,
    forest_area_sqkm DECIMAL(15, 2),
    PRIMARY KEY (country_code, year),
    FOREIGN KEY (country_code) REFERENCES countries(country_code)
);

-- ============================================================================
-- TABLE 3: land_area
-- Contains total land area for each country by year (in millions of hectares)
-- ============================================================================
CREATE TABLE IF NOT EXISTS land_area (
    country_code VARCHAR(3),
    year INTEGER,
    total_area_sq_km DECIMAL(15, 2),
    PRIMARY KEY (country_code, year),
    FOREIGN KEY (country_code) REFERENCES land_area(country_code)
);

-- ============================================================================
-- VIEW: forestation
-- 
-- This view joins all three tables and calculates the forest percentage
-- for each country in each year. The forest_percent column shows the
-- percentage of land area that is covered by forest.
--
-- Calculation: (forest_area_sqkm / total_area_sq_km) * 100
-- ============================================================================
CREATE OR REPLACE VIEW forestation AS
    SELECT 
        c.country_code,
        c.country_name,
        c.region,
        f.year,
        f.forest_area_sqkm,
        l.total_area_sq_km,
        -- Calculated column: forest percentage
        ROUND(
            CAST(f.forest_area_sqkm AS DECIMAL(10, 2)) / 
            CAST(l.total_area_sq_km AS DECIMAL(10, 2)) * 100,
            2
        ) AS forest_percent
    FROM countries c
    INNER JOIN forest_area f
        ON c.country_code = f.country_code
    INNER JOIN land_area l
        ON c.country_code = l.country_code
        AND f.year = l.year
    ORDER BY c.country_name, f.year;

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
