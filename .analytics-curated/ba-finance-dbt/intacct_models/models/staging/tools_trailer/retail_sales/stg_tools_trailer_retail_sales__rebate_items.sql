select
    concat(q.quote_pk_id, '-', f.value:rebate_pk_id::varchar) as pk_id,
    q.quote_pk_id,
    q.quote_id,
    f.value:rebate_pk_id::varchar as rebate_pk_id,
    f.value:asset_pk_id::varchar as asset_pk_id,
    f.value:type_id::varchar as type_id,
    f.value:amount_type::varchar as amount_type,
    f.value:description::varchar as description,
    f.value:value_dollar::numeric(10, 2) as value_dollar,
    f.value:value_percent::numeric(10, 4) as value_percent
from {{ ref("base_tools_trailer_retail_sales__quotes") }} as q,
    lateral flatten(input => parse_json(q.rebate_items)) as f
