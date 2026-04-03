with source as (
    select * from {{ source('analytics_intacct', 'po_line') }}
)

, renamed as (
    select
        -- ids
        recordno as pk_po_line_id,
        locationid as entity_id,
        departmentid as department_id,
        gldimexpense_line::int as fk_expense_type_id,
        itemid as item_id,
        source_doclinekey as fk_source_po_line_id,
        t3_line_item_id as fk_t3_purchase_order_receiver_item_id,

        -- strings
        locationname as entity_name,
        departmentname as department_name,
        line_no as line_number,
        itemdesc as item_description,
        item_itemtype as item_type,
        memo as line_description,
        status as line_status,
        dochdrid as document_name,
        asset_id,
        docparid,
        source_doclinekey,
        
        -- numerics
        uiqty as quantity,
        -- would expand out the quantity if uom != Each, but we appear to not be using anything non-Each last couple  years.
        uiprice as unit_price,
        total as extended_amount,
        qty_remaining as quantity_remaining,
        qty_converted as quantity_converted,
        unit as unit_of_measure,

        -- timestamps
        auwhencreated as date_created,
        whenmodified as date_updated,
        ddsreadtime as dds_read_timestamp,
        _es_update_timestamp

    from source
)
select * from renamed
