CREATE OR REPLACE PROCEDURE ECOM_DWH.MART.LOAD_STAGE_3()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    affected_rows INT;
BEGIN
    MERGE INTO ECOM_DWH.MART.DIM_USER t
    USING (
        SELECT user_id, full_name, email, region, registered_date
        FROM ECOM_DWH.CLEANED.STREAM_INT_USERS
        WHERE METADATA$ACTION = 'INSERT'
        QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY registered_date DESC NULLS LAST) = 1
    ) s
    ON t.user_id = s.user_id
    WHEN MATCHED THEN UPDATE SET
        t.full_name = s.full_name,
        t.email = s.email,
        t.region = s.region,
        t.registered_date = s.registered_date
    WHEN NOT MATCHED THEN INSERT (user_id, full_name, email, region, registered_date)
        VALUES (s.user_id, s.full_name, s.email, s.region, s.registered_date);
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_3_DIM_USER', :affected_rows);

    MERGE INTO ECOM_DWH.MART.DIM_PRODUCT t
    USING (
        SELECT product_id, product_name, category, price
        FROM ECOM_DWH.CLEANED.STREAM_INT_PRODUCTS
        WHERE METADATA$ACTION = 'INSERT'
        QUALIFY ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name) = 1
    ) s
    ON t.product_id = s.product_id
    WHEN MATCHED THEN UPDATE SET
        t.product_name = s.product_name,
        t.category = s.category,
        t.price = s.price
    WHEN NOT MATCHED THEN INSERT (product_id, product_name, category, price)
        VALUES (s.product_id, s.product_name, s.category, s.price);
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_3_DIM_PRODUCT', :affected_rows);

    INSERT INTO ECOM_DWH.MART.FACT_ORDER (order_id, user_id, product_id, quantity, order_date, total_amount)
    SELECT order_id, user_id, product_id, quantity, order_date, total_amount
    FROM ECOM_DWH.CLEANED.STREAM_INT_ORDERS
    WHERE METADATA$ACTION = 'INSERT';
    affected_rows := SQLROWCOUNT;
    INSERT INTO ECOM_DWH.AUDIT.PIPELINE_LOG (procedure_name, rows_affected) VALUES ('LOAD_STAGE_3_FACTS', :affected_rows);

    RETURN 'Stage 3 Load and Audit Complete';
END;
$$;