{% macro es_companies() %}
  
    select company_id
    from {{ ref('stg_analytics_public__es_companies') }}
    where owned = true

{% endmacro %}
