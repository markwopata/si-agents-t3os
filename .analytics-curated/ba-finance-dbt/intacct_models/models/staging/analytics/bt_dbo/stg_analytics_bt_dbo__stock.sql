select
    branchid as bt_branch_id,
    productid as product_id,
    stocklocationid as stock_location_id,
    stockreserved as stock_reserved,
    stockawaitingprocess as stock_awaiting_process,
    stocksuspense as stock_suspense,
    stockthirdparty as stock_third_party,
    stockawaitingprocessnotavailable as stock_awaiting_process_not_available,
    stockallocated as stock_allocated,
    stockonorder as stock_on_order,
    stockavailable as stock_available,
    stockactual as stock_actual,
    stockdue as stock_due,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'stock') }}
