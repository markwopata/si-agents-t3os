select
    costadjustmentlineid as cost_adjustment_line_id,
    exportedtodatawarehouse as exported_to_data_warehouse,
    totalreportingcost as total_reporting_cost,
    orderlineid as order_line_id,
    invoicelineid as invoice_line_id,
    costadjustment as cost_adjustment,
    calculatedcostadjustment as calculated_cost_adjustment,
    costadjustmentid as cost_adjustment_id,
    orderlineaddcostchargeid as order_line_add_cost_charge_id,
    orderlineavoid as order_line_avoid,
    creditnotelineid as credit_note_line_id,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'costadjustmentline') }}
