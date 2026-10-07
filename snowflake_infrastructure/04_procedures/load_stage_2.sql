
CREATE OR REPLACE PROCEDURE ECOM_DWH.CLEANED.LOAD_STAGE_2()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    affected_rows INT;
BEGIN
    INSERT INTO ECOM_DWH.CLEANED.INT_USERS
    SELECT user_id, full_name, email, region, TRY_TO_DATE(registered_date)
    FROM ECOM_DWH.RAW.STREAM_RAW_USERS WHERE METADATA$ACTION = 'INSERT';
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_2_USERS', :affected_rows);

    INSERT INTO ECOM_DWH.CLEANED.INT_PRODUCTS
    SELECT product_id, product_name, category, TRY_TO_DOUBLE(price)
    FROM ECOM_DWH.RAW.STREAM_RAW_PRODUCTS WHERE METADATA$ACTION = 'INSERT';
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_2_PRODUCTS', :affected_rows);

    INSERT INTO ECOM_DWH.CLEANED.INT_ORDERS
    SELECT order_id, user_id, product_id, TRY_TO_NUMBER(quantity), TRY_TO_TIMESTAMP(order_date), TRY_TO_DOUBLE(total_amount)
    FROM ECOM_DWH.RAW.STREAM_RAW_ORDERS WHERE METADATA$ACTION = 'INSERT';
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_2_ORDERS', :affected_rows);

    RETURN 'Stage 2 Load and Audit Complete';
END;
$$;