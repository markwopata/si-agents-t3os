{% macro be_live_date_list() %}

{% set date_array_query %}
    select arrayagg(datelist) as date_array
    from ({{ live_be_period_firstday_of_each_month() }})
{% endset %}

{% set date_array_result = run_query(date_array_query) %}

{% if execute %}
    {% set date_array = date_array_result.columns[0][0] %}
    {% set date_list = [] %}
    {% set cleaned_string = date_array.replace('[', '').replace(']', '').replace('"', '').replace(' ', '') %}
    {% set date_strings = cleaned_string.split(',') %}
    {% for date_string in date_strings %}
        {% if date_string | trim != '' %}
            {% do date_list.append(date_string | trim) %}
        {% endif %}
    {% endfor %}
{% else %}
    {% set date_list = [] %}
{% endif %}

{{ return(date_list) }}

{% endmacro %}
