{{ config(
    schema='credit_card',
    materialized='view'
) }}

-- View mirror of cc_and_fuel_spend_all in the credit_card schema
select *
from {{ ref('cc_and_fuel_spend_all') }}
