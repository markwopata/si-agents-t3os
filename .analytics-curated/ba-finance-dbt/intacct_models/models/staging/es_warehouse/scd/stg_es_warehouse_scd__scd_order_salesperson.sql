SELECT
    sos.user_scd_order_salesperson_id,
    sos.order_id,
    sos.user_id,
    sos.salesperson_type_id,
    sos.date_start,
    sos.date_end,
    sos.current_flag,
    sos._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_order_salesperson') }} as sos
