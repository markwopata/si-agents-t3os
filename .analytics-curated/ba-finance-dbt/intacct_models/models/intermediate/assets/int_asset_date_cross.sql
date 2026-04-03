with date_series as (
    select dateadd(nanosecond, -1, t.series::date + 1) as daily_timestamp
    from
        table(es_warehouse.public.generate_series(
            {% if is_incremental() %}
                dateadd(days, -15, current_date)::timestamp_tz,
            {% else %}
                '2016-01-01'::timestamp_tz,
            {% endif %}
            current_timestamp::timestamp_tz,
            'day'
        )) as t
)

select
    aa.asset_id,
    ds.daily_timestamp::timestamp_tz as daily_timestamp
from
    {{ ref("int_assets") }} as aa
    cross join date_series as ds
    -- Exponentially bad, but we will use incremental loading.
where aa.date_created <= ds.daily_timestamp
