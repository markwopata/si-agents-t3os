select
    concat(q.quote_pk_id, '-', f.value:trade_in_pk_id::varchar) as pk_id,
    q.quote_pk_id,
    q.quote_id,
    f.value:trade_in_pk_id::varchar as trade_in_pk_id,
    f.value:asset_pk_id::varchar as asset_pk_id,
    f.value:asset_id::int as asset_id,
    f.value:build_spec::varchar as build_spec,
    f.value:hours::numeric(10, 2) as hours,
    f.value:make::varchar as make,
    f.value:model::varchar as model, -- noqa: RF04
    f.value:model_year::int as model_year,
    f.value:payoff_amount::numeric(10, 2) as payoff_amount,
    f.value:serial_number::varchar as serial_number,
    f.value:trade_in_over_allowance::numeric(10, 2) as trade_in_over_allowance,
    f.value:trade_in_value::numeric(10, 2) as trade_in_value
from {{ ref("base_tools_trailer_retail_sales__quotes") }} as q,
    lateral flatten(input => parse_json(q.trade_ins)) as f
