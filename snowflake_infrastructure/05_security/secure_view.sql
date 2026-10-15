-- 1. Define the Row Access Policy
CREATE OR REPLACE ROW ACCESS POLICY ECOM_DWH.MART.REGION_ACCESS_POLICY AS (region_val VARCHAR) RETURNS BOOLEAN ->
    CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN') 
    OR CURRENT_ROLE() = 'ROLE_' || UPPER(region_val);

-- 2. Create the Secure View and attach the policy
CREATE OR REPLACE SECURE VIEW ECOM_DWH.MART.SECURE_FACT_ORDER 
WITH ROW ACCESS POLICY ECOM_DWH.MART.REGION_ACCESS_POLICY ON (region)
AS
SELECT 
    f.order_id,
    f.user_id,
    f.product_id,
    f.quantity,
    f.total_amount,
    u.region
FROM ECOM_DWH.MART.FACT_ORDER f
JOIN ECOM_DWH.MART.DIM_USER u ON f.user_id = u.user_id;