SELECT
    vwotc.asset_id,
    vwotc.pk_id_json,
    vwotc.wo_text
FROM {{ source('es_warehouse_public', 'vw_work_order_to_create') }} as vwotc
