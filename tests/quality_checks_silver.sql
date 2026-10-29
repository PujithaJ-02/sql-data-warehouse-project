/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
 

-- ******************************************
-- Bronze LAYER Quality Check: bronze.crm_cust_info
-- ******************************************
-- Check for nulls or Duplicates in Primary Key 
-- Expectation: No Result

SELECT 
cst_id, 
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*)>1 OR cst_id IS NULL;
-- FIRST NAME
-- CHECK FOR UNWANTED SPACES 

SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
-- LAST NAME 
SELECT cst_lastname 
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
-- GENDER
SELECT cst_gndr 
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)
-- ******************************************
-- Bronze Layer Quality Check: bronze.crm_prd_infor
-- ******************************************
SELECT 
prd_id, 
COUNT(*)
FROM silver.crm_prd_info
GROUP BY cst_id 
HAVING COUNT(*)>1 OR prd_id IS NULL;
-- CHECK FOR UNWANTED SPACES 

SELECT prd_name 
FROM silver.crm_prd_info
WHERE prd_name != TRIM(prd_name)

-- CHECK FOR NULL OR NEGATIVE NUMBERS
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost<0 AND prd_cost IS NULL

-- DATA STANDARDIZATION AND CONSISTENCY 
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- CHECK FOR INVALID DATE ORDERS
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_end_dt<prd_start_dt

-- ******************************************
-- Bronze Layer Quality Check: crm_sales_details
-- ******************************************
-- Check for Invalid Dates
SELECT 
    NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE 
    sls_order_dt < =0 OR 
    LEN(sls_order_dt) !=8 OR 
    sls_order_dt >20500101 OR 
    sls_order_dt < 19000101;

-- Check for Invalid Date Orders 
SELECT 
    * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity, and Price 
-- >>  Sales = Quantity * Price 
-- >> Values must not be NULL, ZERO, or negative 

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity is NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price is NULL OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price 
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price

-- Checking Silver Tables after doing data cleansing
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity is NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details;

-- ******************************************************
-- Bronze LAYER Quality Check: bronze.erp_cust_az12
-- ******************************************************
SELECT 
    cid, 
    bdate, 
    gen 
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

SELECT * FROM silver.crm_cust_info;

-- Removing the 'NAS'
 SELECT 
    cid, 
    CASE WHEN cid LIKE 'NAS%' 
            THEN SUBSTRING(cid, 4, LEN(cid))
         ELSE cid 
    END AS cid,
    bdate, 
    gen 
FROM bronze.erp_cust_az12
WHERE  CASE WHEN cid LIKE 'NAS%' 
            THEN SUBSTRING(cid, 4, LEN(cid))
         ELSE cid 
    END NOT IN(SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- Columb : bdate 

SELECT DISTINCT
    bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
-- Fix the above bdate 
SELECT 
    CASE WHEN bdate > GETDATE() THEN NULL 
        ELSE bdate 
    END as bdate, 
    gen
FROM bronze.erp_cust_az12;

-- Column : Gender 
SELECT DISTINCT gen
FROM bronze.erp_cust_az12
-- Fix above gender data inconsistency and standardization 
SELECT DISTINCT
    gen, 
    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END as cleaned_gen
FROM bronze.erp_cust_az12

SELECT DISTINCT
    gen, 
    CASE 
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END as cleaned_gen
FROM bronze.erp_cust_az12;
-- ******************************************************
-- SILVER LAYER Quality Check: silver.erp_cust_az12
-- ******************************************************
-- Columb : bdate 

SELECT DISTINCT
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
-- Column : Gender
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12;


-- ******************************************************
-- Bronze LAYER Quality Check: bronze.erp_loc_a101
-- ******************************************************
-- Column : cid
SELECT 
    cid, 
    cntry
FROM bronze.erp_loc_a101

SELECT cst_key FROM silver.crm_cust_info
-- Fix the - in the cid
SELECT 
    REPLACE(cid, '-', '') cid, 
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)
-- Column : Country => Data Standardization and Consistency
SELECT DISTINCT 
    cntry 
FROM bronze.erp_loc_a101
ORDER BY cntry

SELECT 
    CASE  WHEN TRIM(cntry) = 'DE' THEN 'Germany'
          WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
          WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
          ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101


SELECT DISTINCT 
    cntry, 
    CASE  WHEN TRIM(cntry) = 'DE' THEN 'Germany'
          WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
          WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
          ELSE TRIM(cntry)
    END AS Updated_cntry
FROM bronze.erp_loc_a101

SELECT DISTINCT
    cntry,
    CASE 
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = 'DE' THEN 'Germany'
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) IN ('USA', 'United States', 'US') THEN 'United States'
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
    END AS Updated_cntry
FROM bronze.erp_loc_a101;
-- ******************************************************
-- Silver LAYER Quality Check: silverronze.erp_loc_a101 
-- AFTER UPDATING INCONSISTENTICS IN BRONZE
-- ******************************************************
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT * FROM silver.erp_loc_a101

-- ******************************************************
-- Bronze LAYER Quality Check: bronze.erp_px_cat_g1v2
-- ******************************************************
SELECT 
    id, 
    cat, 
    subcat, 
    maintenance
FROM bronze.erp_px_cat_g1v2

select * from silver.crm_prd_info
-- Checking for Unwanted Spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)
-- Data Strandardization and Inconsistencies
SELECT DISTINCT 
    cat 
FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT 
    subcat 
FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT 
    maintenance 
FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT
    maintenance,
    TRIM(REPLACE(REPLACE(maintenance, CHAR(13), ''), CHAR(10), '')) AS cleaned_maintenance
FROM bronze.erp_px_cat_g1v2;
-- ******************************************************
-- Silver LAYER Quality Check: silverronze.erp_px_cat_g1v2
-- AFTER UPDATING INCONSISTENTICS IN BRONZE
-- ******************************************************
SELECT DISTINCT 
    cat 
FROM silver.erp_px_cat_g1v2
SELECT DISTINCT 
    subcat 
FROM silver.erp_px_cat_g1v2
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2
SELECT * FROM silver.erp_px_cat_g1v2
