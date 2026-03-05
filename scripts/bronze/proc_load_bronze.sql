/*
============================================================
Stored Procedure: Load Bronze Layer (Source-> Bronze)
============================================================
Script Purpose:
      This stored procedure loads data into the 'bronze' schema from external CSV files.
       It performs the following actions:
       - Creates a staging table for the CRM customers source file to support initial data ingestion.       
       -  Truncate the bronze tables before loading data.
       -  Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.

Parameters:
     None.
    This stored procedure does not accept any parameters or return any values.

Using Example:
    EXEC bronze.load_bronze;
===============================================================

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN    
   DECLARE  @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
   BEGIN TRY
        SET @batch_start_time  = GETDATE();
	    PRINT '============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------';
	    
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
	
		PRINT '>> Truncating Staging Table : bronze.crm_cust_info_stage';
		TRUNCATE TABLE bronze.crm_cust_info_stage;
	
		PRINT '>> Inserting Data Into : bronze.crm_cust_info_stage';
		BULK INSERT bronze.crm_cust_info_stage
		FROM 'C:\DataWarehouseProject\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0d0a',
			CODEPAGE = '65001',
			TABLOCK
		);
	
		PRINT '>> Transforming & Inserting Data Into : bronze.crm_cust_info';
		INSERT INTO bronze.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			LTRIM(RTRIM(cst_key)),
			LTRIM(RTRIM(cst_firstname)),
			LTRIM(RTRIM(cst_lastname)),
			LTRIM(RTRIM(cst_marital_status)),
			LTRIM(RTRIM(cst_gndr)),
			TRY_CONVERT(DATE, LTRIM(RTRIM(cst_create_date)), 105)
		FROM bronze.crm_cust_info_stage;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	    PRINT '-----------------------';
 
		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table : bronze.crm_prd_info';
		 TRUNCATE TABLE bronze.crm_prd_info;
	
		 PRINT '>> Inserting Data Into : bronze.crm_prd_info';
		 BULK INSERT  bronze.crm_prd_info
		 FROM 'C:\DataWarehouseProject\source_crm\prd_info.csv'
		 WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK
		 );
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		 PRINT '---------------------';

		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table : bronze.crm_sales_details';
		 TRUNCATE TABLE bronze.crm_sales_details;

		 PRINT '>> Inserting Data Into : bronze.crm_sales_details';
		 BULK INSERT bronze.crm_sales_details
		 FROM  'C:\DataWarehouseProject\source_crm\sales_details.csv'
		 WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK
		 );
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		 PRINT '---------------------';

         
		 PRINT '--------------------------------------------';
		 PRINT 'Loading ERP Tables';
		 PRINT '--------------------------------------------';

		  SET @start_time = GETDATE();
		  PRINT '>> Truncating Table : bronze.erp_cust_az12';
		  TRUNCATE TABLE bronze.erp_cust_az12;
	  
		  PRINT '>> Inserting Data Into : bronze.erp_cust_az12';
		  BULK INSERT bronze.erp_cust_az12
		  FROM 'C:\DataWarehouseProject\source_erp\CUST_AZ12.csv'
		  WITH (
		  FIRSTROW = 2,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		  );
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		 PRINT '---------------------';


		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table : bronze.erp_loc_a101';
		  TRUNCATE TABLE bronze.erp_loc_a101;

		  PRINT '>> Inserting Data Into : bronze.erp_loc_a101';
		  BULK INSERT bronze.erp_loc_a101
		  FROM 'C:\DataWarehouseProject\source_erp\LOC_A101.csv'
		  WITH (
		  FIRSTROW = 2,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		  );
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		 PRINT '---------------------';

		  SET @start_time = GETDATE();
		  PRINT '>> Truncating Table : bronze.erp_px_cat_g1v2';
		  TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	  
		  PRINT '>> Inserting Data Into : bronze.erp_px_cat_g1v2';
		  BULK INSERT bronze.erp_px_cat_g1v2
		  FROM 'C:\DataWarehouseProject\source_erp\PX_CAT_G1V2.csv'
		  WITH (
		  FIRSTROW = 2,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		  );
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		 PRINT '---------------------';

		 SET @batch_end_time = GETDATE();
		 PRINT' ==================================';
		 PRINT 'Loading Bronze Layer is Completed';
		 PRINT '   - Total Load Duration : ' + Cast(datediff(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		 PRINT '==================================';


	  END TRY
	  BEGIN CATCH 
	     PRINT'========================================================';
		 PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		 PRINT 'Error Message' + ERROR_MESSAGE();
		 PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		 PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR); 
	  END CATCH
END
