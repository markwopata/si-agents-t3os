select
    concat(q.quote_pk_id, '-', f.value:asset_pk_id::varchar) as pk_id,
    q.quote_pk_id,
    q.quote_id,
    f.value:asset_pk_id::varchar as asset_pk_id,
    f.value:asset_id::int as asset_id,
    f.value:asset_type::varchar as asset_type,
    f.value:description::varchar as description,
    f.value:make::varchar as make,
    f.value:model::varchar as model, -- noqa: RF04
    f.value:oec::numeric(10, 2) as oec,
    f.value:rebate_oec::numeric(10, 2) as rebate_oec,
    f.value:sale_price::numeric(10, 2) as sale_price,
    f.value:serial_number::varchar as serial_number,
    f.value:warranty_note::varchar as warranty_note,
    f.value:warranty_type::varchar as warranty_type
from {{ ref('base_tools_trailer_retail_sales__quotes') }} as q,
    lateral flatten(input => parse_json(q.assets)) as f
