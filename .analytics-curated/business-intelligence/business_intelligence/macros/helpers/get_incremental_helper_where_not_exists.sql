{%- macro get_incremental_helper_where_not_exists(incremental_model) -%}

    {%- set target_key_list = get_unique_keys_for_model(this.name) -%}

    select 1 
    from {{ this }} target
    where 
    {%- for col in target_key_list -%}
        {% if not loop.first %} AND {% endif %} target.{{ col }} = {{ incremental_model }}.{{ col }}
    {% endfor %}

{%- endmacro -%}