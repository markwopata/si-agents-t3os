{% macro live_be_period_firstday_of_each_month() %}

{% set date_query %}

SELECT  
    d.DATE AS DATELIST
FROM   {{ ref('dim_date') }} d
WHERE   
    d.DAY = 1
    AND d.DATE >= '{{ live_be_start_date() }}'
    AND d.DATE <= CURRENT_DATE


{% endset %}

{% set results = run_query(date_query) %}

{% if execute %}
{# Return the first column #}
{% set LAST_PUBLISHED_DATE = results.columns[0].values() %}
{% else %}
{% set LAST_PUBLISHED_DATE = [] %}
{% endif %}

{% for date in LAST_PUBLISHED_DATE %}

SELECT  
    '{{ date }}' as datelist
{% if not loop.last -%} union all {%- endif %}




    {% endfor %}

{% endmacro %}