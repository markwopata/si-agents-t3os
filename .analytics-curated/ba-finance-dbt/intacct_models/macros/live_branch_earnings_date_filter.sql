
{% macro live_branch_earnings_date_filter(date_field, timezone_conversion) %}

{% set converted_date_field = date_field ~ "::timestamp_ntz" %}

    {% if timezone_conversion %}
        {% set date = "CONVERT_TIMEZONE('UTC', 'America/Chicago', " ~ converted_date_field ~ ")" %}
    {% else %}
        {% set date = converted_date_field %}
    {% endif %}

    {{ date }}::date >= '{{ live_be_start_date() }}'
    and {{ date }}::date <= last_day(current_date)
  
{% endmacro %} 

