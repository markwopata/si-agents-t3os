{% macro live_be_snapshot_delta(table, timestamp_column) %}

{# Retrieve distinct timestamps using dbt_utils #}
{% set ts_pairs = dbt_utils.get_column_values(table=table, column=timestamp_column) | sort(reverse=True) %}
with 
{% set cte_names = [] %}
{% for i in range(ts_pairs | length - 1) %}
    {% set current_ts = ts_pairs[i] %}
    {% set previous_ts = ts_pairs[i+1] %}
    {% if previous_ts is not none %}
        {% set cte_name = "delta_" ~ i %}
        {% do cte_names.append(cte_name) %}
        {{ cte_name }} as (
            select 
                '{{ current_ts }}' as latest_timestamp,
                '{{ previous_ts }}' as previous_timestamp,
                pk_id, 
                amount as amount_in_latest,
                null as amount_in_previous
            from {{ table }}
            where {{ timestamp_column }} = '{{ current_ts }}'
            except
            select 
                '{{ current_ts }}',
                '{{ previous_ts }}',
                pk_id, 
                amount,
                null
            from {{ table }}
            where {{ timestamp_column }} = '{{ previous_ts }}'

            union all

            select 
                '{{ current_ts }}' as latest_timestamp,
                '{{ previous_ts }}' as previous_timestamp,
                pk_id, 
                null as amount_in_latest,
                amount as amount_in_previous
            from {{ table }}
            where {{ timestamp_column }} = '{{ previous_ts }}'
            except
            select 
                '{{ current_ts }}',
                '{{ previous_ts }}',
                pk_id, 
                null,
                amount
            from {{ table }}
            where {{ timestamp_column }} = '{{ current_ts }}'
        ){% if not loop.last %},{% endif %}
    {% endif %}
{% endfor %}

, final_delta as (
    {% for cte in cte_names %}
        select * from {{ cte }}{% if not loop.last %} union all {% endif %}
    {% endfor %}
)

select *
from final_delta
order by latest_timestamp desc

{% endmacro %}