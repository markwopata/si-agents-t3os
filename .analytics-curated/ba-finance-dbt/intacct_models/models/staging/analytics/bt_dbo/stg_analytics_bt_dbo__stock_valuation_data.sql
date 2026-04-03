with source as (
    select
        _fivetran_id,
        total_reporting_cost,
        product_batch_id,
        stock_valuation_id,
        valuation_date,
        stock_unit_cost,
        standard_buy_unit_cost,
        stock_quantity,
        stock_per_id,
        product_id,
        bt_branch_id,
        stock_valuation,
        standard_buy_per_id,
        _fivetran_deleted,
        _fivetran_synced,
        row_number() over (partition by product_id, stock_valuation_id, bt_branch_id, valuation_date
            order by _fivetran_synced desc ) as rn
    from {{ ref("base_analytics_bt_dbo__stock_valuation_data") }}
)

select *
from source
where rn = 1
