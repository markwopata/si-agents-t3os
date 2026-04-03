select
    concat(q.quote_pk_id, '-', f.value:cost_pk_id::varchar) as pk_id,
    q.quote_pk_id,
    q.quote_id,
    f.value:cost_pk_id::varchar as cost_pk_id,
    f.value:asset_pk_id::varchar as asset_pk_id,
    f.value:cost::numeric(10, 2) as cost,
    f.value:price::numeric(10, 2) as price,
    f.value:description::varchar as description,
    f.value:purchase_order_id::varchar as purchase_order_id,
    f.value:type::varchar as line_type
from {{ ref("base_tools_trailer_retail_sales__quotes") }} as q,
    lateral flatten(input => parse_json(q.cost_items)) as f
