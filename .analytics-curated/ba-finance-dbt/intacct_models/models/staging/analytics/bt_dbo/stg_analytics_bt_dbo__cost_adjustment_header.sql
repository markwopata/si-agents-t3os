select
    -- === IDs ===
    costadjustmentid as cost_adjustment_id,
    creditnoteid as credit_note_id,
    approvedbyid as approved_by_id,
    customerid as customer_id,
    invoiceid as invoice_id,
    suppliersupportagreementid as supplier_support_agreement_id,
    reasonid as reason_id,
    departmentid as department_id,

    -- === Dates/Times ===
    costadjustmentdate as cost_adjustment_date,
    datetimeapproved as datetime_approved,

    -- === Numbers ===
    totalcostadjustment as total_cost_adjustment,
    costadjustmentnumber as cost_adjustment_number,

    -- === Booleans / Flags ===
    paid,
    _fivetran_deleted,

    -- === Strings / Other ===
    costadjustmenttype as cost_adjustment_type,
    allocateon as allocate_on,
    notes

from {{ source('analytics_bt_dbo', 'costadjustmentheader') }}
