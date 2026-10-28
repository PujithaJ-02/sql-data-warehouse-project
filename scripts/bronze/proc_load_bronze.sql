/* 
Baraa uses a different file path in the BULK INSERT statement.
-- Since I am using Azure Data Studio on macOS with SQL Server running
-- inside a Docker container, SQL Server cannot directly access the CSV
-- file from my Mac's local file system.
=> To resolve this, I copied the CSV file into the Docker container
=> and used the container's file path in the BULK INSERT statement.
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN 
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY 
        SET @batch_start_time = GETDATE();
        PRINT '===================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===================================================';

        PRINT '---------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------';
        -- Load customer information from prd_info.csv into the Bronze layer.

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info

        PRINT '>> Inserting Data Into: bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/import/cust_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        -- Load product information from prd_info.csv into the Bronze layer.
        -- Since SQL Server is running inside Docker on macOS, the CSV file  was copied into the Docker container before executing BULK INSERT.
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.prd_info.csv'
        TRUNCATE TABLE bronze.crm_prd_info

        PRINT '>> Inserting Data Into: bronze.prd_info.csv'
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/import/prd_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        -- Load sales details into the Bronze layer.
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details.csv'
        TRUNCATE TABLE bronze.crm_sales_details

        PRINT '>> Inserting Data Into: bronze.crm_sales_detailed'
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/import/sales_details.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        PRINT '---------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------';
        -- Load ERP customer data into the Bronze layer.
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/import/CUST_AZ12.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        -- Load ERP location data into the Bronze layer.
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/import/LOC_A101.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        -- Load ERP product category data into the Bronze layer.
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2

        PRINT '>> Inserting Data Into : bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/import/PX_CAT_G1V2.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ----------------------------------------------------';
        SET @batch_end_time = GETDATE();
        PRINT '=======================================================';
        PRINT ' Loading Bronze Layer is Completed';
        PRINT '     -  Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=======================================================';

        END TRY 
    BEGIN CATCH 
        PRINT '===================================================';
        PRINT '     ERROR COCCURED DURING LOADING BRONZE LAYER    ';
        PRINT '       Error Message' + ERROR_MESSAGE();            ;
        PRINT '  Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR) ;
        PRINT '  Error Message' + CAST(ERROR_STATE() AS NVARCHAR) ;             

        PRINT '==================================================='; 
    END CATCH 

END

 
EXEC bronze.load_bronze

-- ===================================================
--         TESTING THE QUALITY OF CRM DATA 
-- ===================================================
    -- Testing the quality of the Bronze Table 
    SELECT * FROM bronze.crm_cust_info;
    SELECT COUNT(*) FROM bronze.crm_cust_info;
    -- Testing the quality of the product details talbe 
    SELECT TOP 10 * 
    FROM bronze.crm_prd_info;
    -- Testing the quality of the sales.details table 
    SELECT TOP 10 *
    FROM bronze.crm_sales_details;
    
-- ===================================================
--         TESTING THE QUALITY OF ERP DATA 
-- ===================================================
    -- Testing Quality of the erp customer table
    SELECT TOP 10 *
    FROM bronze.erp_cust_az12;
    -- Testing Quality of the erp location table 
    SELECT TOP 10 *
    FROM bronze.erp_loc_a101;
    -- Testing the quality of bronze.erp_px_cat_g1v2
    SELECT TOP 10 *
    FROM bronze.erp_px_cat_g1v2;
