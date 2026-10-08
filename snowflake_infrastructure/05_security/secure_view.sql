CREATE OR REPLACE SECURE VIEW ECOM_DWH.MART.SECURE_FACT_ORDER AS
SELECT 
    f.order_id,
    f.user_id,
    f.product_id,
    f.quantity,
    f.total_amount,
    u.region
FROM ECOM_DWH.MART.FACT_ORDER f
JOIN ECOM_DWH.MART.DIM_USER u ON f.user_id = u.user_id;