select
    stockcostadjustmentid as stock_cost_adjustment_id,
    supplierinvoicelineid as supplier_invoice_line_id,
    productid as product_id,
    totalamount as total_amount,
    adjustmenttransactionid as adjustment_transaction_id,
    stockreceiptid as stock_receipt_id,
    stockreceiptlineid as stock_receipt_line_id,
    stockreceiptcostid as stock_receipt_cost_id,
    suppliercreditlineid as supplier_credit_line_id,
    proratedmanualcost as prorated_manual_cost,
    orderlineid as order_line_id,
    datetimecreated as datetime_created,
    totaladditionalamount as total_additional_amount,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'stockcostadjustment') }}
