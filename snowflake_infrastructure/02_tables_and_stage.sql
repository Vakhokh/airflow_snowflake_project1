CREATE TABLE ECOM_DWH.RAW.RAW_USERS (
    user_id VARCHAR, 
    full_name VARCHAR, 
    email VARCHAR, 
    region VARCHAR, 
    registered_date VARCHAR
);
CREATE TABLE ECOM_DWH.RAW.RAW_PRODUCTS (
    product_id VARCHAR, 
    product_name VARCHAR, 
    category VARCHAR, 
    price VARCHAR
);
CREATE TABLE ECOM_DWH.RAW.RAW_ORDERS (
    order_id VARCHAR, 
    user_id VARCHAR, 
    product_id VARCHAR, 
    quantity VARCHAR, 
    order_date VARCHAR, 
    total_amount VARCHAR
);


CREATE TABLE ECOM_DWH.CLEANED.INT_USERS (
    user_id VARCHAR, 
    full_name VARCHAR, 
    email VARCHAR, 
    region VARCHAR, 
    registered_date DATE
);
CREATE TABLE ECOM_DWH.CLEANED.INT_PRODUCTS (
    product_id VARCHAR, 
    product_name VARCHAR, 
    category VARCHAR, 
    price FLOAT
);
CREATE TABLE ECOM_DWH.CLEANED.INT_ORDERS (
    order_id VARCHAR, 
    user_id VARCHAR,
    product_id VARCHAR, 
    quantity INT, 
    order_date TIMESTAMP, 
    total_amount FLOAT
);


CREATE TABLE ECOM_DWH.MART.DIM_USER AS SELECT * FROM ECOM_DWH.CLEANED.INT_USERS WHERE 1=0;
CREATE TABLE ECOM_DWH.MART.DIM_PRODUCT AS SELECT * FROM ECOM_DWH.CLEANED.INT_PRODUCTS WHERE 1=0;
CREATE TABLE ECOM_DWH.MART.FACT_ORDER (
    order_id VARCHAR, user_id VARCHAR, product_id VARCHAR, quantity INT, order_date TIMESTAMP, total_amount FLOAT,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE ECOM_DWH.AUDIT.PIPELINE_LOG (
    log_id INT AUTOINCREMENT,
    procedure_name VARCHAR,
    rows_affected INT,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);



CREATE FILE FORMAT ECOM_DWH.RAW.CSV_FORMAT
    TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1;

    
CREATE STAGE ECOM_DWH.RAW.INTERNAL_STAGE
    FILE_FORMAT = ECOM_DWH.RAW.CSV_FORMAT;

