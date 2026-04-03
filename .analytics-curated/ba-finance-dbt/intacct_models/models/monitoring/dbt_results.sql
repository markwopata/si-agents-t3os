-- Save model as 'dbt_results.sql' 
-- creating an empty table that will be used for storing the results after each dbt run

{{
  config(
    materialized = 'incremental',
    transient = False,
    unique_key = 'result_id',
    schema = 'dbt_results'
  )
}}

with empty_table as (
    select
        null as compiled_path,
        null as path,
        null as failures,
        null as message,
        null as result_id,
        null as invocation_id,
        null as unique_id,
        null as database_name,
        null as schema_name,
        null as name,
        null as resource_type,
        null as status,
        null as time_of_run,
        cast(null as float) as execution_time,
        cast(null as int) as rows_affected,
)

select * from empty_table
-- This is a filter so we will never actually insert these values
where 1 = 0