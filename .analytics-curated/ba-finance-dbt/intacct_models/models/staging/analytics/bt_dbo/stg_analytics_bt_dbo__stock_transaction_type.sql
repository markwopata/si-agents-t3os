select
    stocktransactiontype as stock_transaction_type,
    name,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'stocktransactiontype') }}
