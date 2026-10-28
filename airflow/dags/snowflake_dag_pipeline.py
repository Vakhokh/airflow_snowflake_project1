from datetime import datetime, timedelta

from airflow.decorators import dag, task, task_group
from airflow.exceptions import AirflowException
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

SNOWFLAKE_CONN_ID = "snowflake_default"  
DATA_DIR = "/opt/airflow/data"        

default_args = {
    "owner": "data_engineer",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


def _hook() -> SnowflakeHook:
    return SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)


@dag(
    dag_id="ecommerce_snowflake_pipeline",
    description="End-to-End ELT Pipeline for Snowflake DWH",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,  
    default_args=default_args,
    tags=["snowflake", "elt"],
)
def ecommerce_snowflake_pipeline():

    @task
    def upload_csv(file_name: str) -> str:
        sql = (
            f"PUT file://{DATA_DIR}/{file_name}.csv @ECOM_DWH.RAW.INTERNAL_STAGE "
            "AUTO_COMPRESS=FALSE OVERWRITE=TRUE"
        )
        row = _hook().get_first(sql)
        return f"{file_name}: {row}"

    @task
    def load_stage_1() -> str:
        _hook().run("CALL ECOM_DWH.RAW.LOAD_STAGE_1()", autocommit=True)
        return "Stage 1 Complete"
    @task
    def load_stage_2() -> str:
        _hook().run("CALL ECOM_DWH.CLEANED.LOAD_STAGE_2()", autocommit=True) 
        return "Stage 2 Complete"
    @task
    def check_cleaned_orders() -> None:
        bad_rows = _hook().get_first(
            """
            SELECT COUNT(*) 
            FROM ECOM_DWH.CLEANED.STREAM_INT_ORDERS 
            WHERE (order_date IS NULL OR quantity IS NULL OR total_amount IS NULL)
            AND METADATA$ACTION = 'INSERT'
            
            """
        )[0]
        if bad_rows > 0:
            raise AirflowException(
                f"{bad_rows} rows in INT_ORDERS have an unparseable date, quantity or amount"
            )

    @task
    def load_stage_3() -> str:
        _hook().run("CALL ECOM_DWH.MART.LOAD_STAGE_3()", autocommit=True)
        return "Stage 3 Complete"

    @task_group(group_id="upload_to_stage")
    def upload_to_stage():
        upload_csv.expand(file_name=["users", "products", "orders"])

    upload = upload_to_stage()
    s1, s2, check, s3 = load_stage_1(), load_stage_2(), check_cleaned_orders(), load_stage_3()

    upload >> s1 >> s2 >> check >> s3


ecommerce_snowflake_pipeline()