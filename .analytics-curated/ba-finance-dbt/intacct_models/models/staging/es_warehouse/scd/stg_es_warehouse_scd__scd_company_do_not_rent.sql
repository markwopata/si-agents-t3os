SELECT
    scdnr.company_id,
    scdnr.do_not_rent,
    scdnr.current_flag,
    scdnr.date_start,
    scdnr.date_end,
    scdnr._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_company_do_not_rent') }} as scdnr
