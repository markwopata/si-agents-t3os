SELECT
    s.spn,
    s.length,
    s.spn_name,
    s.spn_desc,
    s.spn_type,
    s.type,
    s.value_offset,
    s.value_scale,
    s.units,
    s.delimiter,
    s.not_avail_bitmask,
    s.oper_range_hi,
    s.oper_range_low,
    s.slot_id
FROM {{ source('es_warehouse_public', 'spn') }} as s
