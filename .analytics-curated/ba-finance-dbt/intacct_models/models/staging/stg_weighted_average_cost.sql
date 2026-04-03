{{
    config(materialized='table',)
}}
with wac_keep_latest_override as (
    select wacs.*
    from
        {{ ref("stg_es_warehouse_inventory__weighted_average_cost_snapshots") }}
            as wacs
    qualify
        row_number()
            over (
                partition by
                    wacs.inventory_location_id,
                    wacs.product_id,
                    wacs.date_applied
                order by wacs.date_created desc
            )
        = 1
)

select
    wk.wac_snapshot_id,
    wk.created_by_user_id,
    wk.reason,
    wk.transaction_id,
    wk.date_applied as date_start,
    coalesce(lead(wk.date_applied)
        over (partition by wk.inventory_location_id, wk.product_id order by wk.date_applied, wk.date_created),
    '2099-12-31'::timestamp_ntz) as date_end,
    wk.date_applied,
    wk.date_created,
    wk.inventory_location_id,
    wk.product_id,
    wk.is_override,
    wk.incoming_cost_per_item,
    wk.total_quantity,
    wk.updated_by_user_id,
    wk.weighted_average_cost,
    wk.incoming_quantity,
    wk.date_updated,
    wk.date_archived,
    wk.is_current,
    wk._es_update_timestamp
from wac_keep_latest_override as wk
order by
    wk.inventory_location_id, wk.product_id, wk.date_applied, wk.date_created
