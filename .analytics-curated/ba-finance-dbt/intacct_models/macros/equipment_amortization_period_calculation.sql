{% macro equipment_amortization_period_calculation() %}

{% set date_query %}

SELECT  
    MAX(x.DATE)::DATE AS MaxDate
    , DATE_TRUNC('MONTH', MAX(x.DATE)::DATE) AS DateMonth
FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET X
WHERE   x.DATE <= CURRENT_DATE

{% endset %}

{% set results = run_query(date_query) %}

{% if execute %}
{# Return the first column #}
{% set MAX_HAM_DATE = results.columns[0].values() %}
{% else %}
{% set MAX_HAM_DATE = [] %}
{% endif %}


{% if execute %}
{# Return the second column #}
{% set FIRST_OF_MONTH_MAX_HAM_DATE = results.columns[1].values() %}
{% else %}
{% set FIRST_OF_MONTH_MAX_HAM_DATE = [] %}
{% endif %}

SELECT  

    CASE 
        WHEN MONTH(d.DATE) = MONTH(CURRENT_DATE) THEN d.DATE
        ELSE LAST_DAY(d.DATE)
    END AS DATELIST

FROM    {{ ref('dim_date') }} d
WHERE   d.DATE= 
    '{{ MAX_HAM_DATE[0] }}'

OR
    (
        d.DAY = 1
            AND
        d.DATE >= (
                    SELECT  
                        DATEADD(MONTH, 1, MAX(date_trunc(MONTH, p.TRUNC::DATE)))
                    FROM    {{ ref('seed_plexi_periods') }} p
                    WHERE   p.PERIOD_PUBLISHED = 'published'
                  )
            AND
        d.DATE < 
                '{{ FIRST_OF_MONTH_MAX_HAM_DATE[0] }}'
    )
{% endmacro %}