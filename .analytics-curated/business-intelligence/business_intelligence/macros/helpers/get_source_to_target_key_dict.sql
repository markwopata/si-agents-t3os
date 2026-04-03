{%- macro get_source_to_target_key_dict() -%}

    {%- set column_mapping_dict = get_source_to_target_mapping_dict() -%}
    {%- set target_key_list = get_unique_keys_for_model(this.name) %}
    
    {# filter full dictionary for just the join keys #}
    {%- set join_key_dict = {} -%}
    {%- for key, value in column_mapping_dict.items() -%}
        {%- if value in target_key_list -%}
            {%- do join_key_dict.update({key: value}) -%}
        {% endif %}
    {% endfor %}

    {{ return(join_key_dict) }}

{% endmacro %}