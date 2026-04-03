{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['pk_part_inventory_transactions_id', 'failure_logged_at'],
    schema = 'dbt_test__audit'
) }}

with dupes as (
    select
        current_timestamp as failure_logged_at,
        *
    from {{ ref('part_inventory_transactions') }}
    where pk_part_inventory_transactions_id is not null
    qualify count(*) over (partition by pk_part_inventory_transactions_id) > 1
)

select * from dupes
