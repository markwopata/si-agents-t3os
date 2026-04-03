{{ config(
    materialized='incremental',
    unique_key=['from_company_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

{{ create_seed_incremental(
    seed_ref='seed_companies__use_account_merge_mapping'
    , unique_id='from_company_id'
    , update_cols=['from_company_name', 'to_company_id', 'to_company_name']
) }}