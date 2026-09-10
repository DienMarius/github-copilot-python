# Forestation Analysis Project

## Overview
This project analyzes global deforestation trends across countries and regions. It demonstrates proficiency in SQL including views, joins, window functions, case statements, and complex queries.

## Project Structure
- `schema.sql` - Database schema and forestation view
- `queries.sql` - All SQL queries organized by requirement category
- `report.md` - Comprehensive analysis report with findings and recommendations
- `data.sql` - Sample data (in production, this would connect to actual database)

## Key Components
1. **Forestation View** - Joins three tables with calculated deforestation percentages
2. **Basic Queries** - SELECT, WHERE, ORDER BY, GROUP BY operations
3. **Window Functions** - Aggregate analysis across regions and time periods
4. **Self-Joins** - Year-over-year comparisons
5. **Case Statements** - Deforestation categorization
6. **Comprehensive Report** - Global situation, regional analysis, country details, and recommendations

## Database Tables
- `countries` - Country information and regions
- `forest_area` - Forest coverage by year
- `land_area` - Total land area by year
