-- 1. 
SELECT COUNT(DISTINCT p_date) FROM ECOM_DWH.SANDBOX.TEST_2_LOG;

-- 2. 
SELECT COUNT(*) AS bad_rows
FROM (
    SELECT p_prev_date,
           LAG(p_date, 1, '2025-01-28'::DATE) OVER (ORDER BY log_id) AS expected_prev
    FROM ECOM_DWH.SANDBOX.TEST_2_LOG
)
WHERE p_prev_date <> expected_prev;

-- 3. 
SELECT * FROM ECOM_DWH.SANDBOX.TEST_2_LOG ORDER BY log_id;
