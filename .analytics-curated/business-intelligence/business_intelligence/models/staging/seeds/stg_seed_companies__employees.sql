{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

{{ create_seed_incremental(
    seed_ref='seed_companies__employees'
    , unique_id='company_id'
    , update_cols=['company_name']
) }}