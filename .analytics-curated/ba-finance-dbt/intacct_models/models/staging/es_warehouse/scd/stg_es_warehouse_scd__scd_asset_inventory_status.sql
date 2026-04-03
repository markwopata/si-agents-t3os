SELECT
    sais.asset_id,
    sais.asset_inventory_status,
    sais.date_start,
    sais.date_end,
    sais.current_flag,
    sais.id,
    row_number() over(partition by sais.asset_id, sais.asset_inventory_status order by sais.date_start asc) as asset_inv_status_seq, -- counting the number of times an asset has been in a specific status
    case
        when sais.current_flag != 0 then datediff(day, sais.date_start, current_date()) -- cap to current_date if status is current (date_end = 9999)
        else datediff(day, sais.date_start, sais.date_end)
    end as inventory_status_duration_days -- calculating the duration of the asset inventory status 
FROM {{ source('es_warehouse_scd', 'scd_asset_inventory_status') }} as sais
