{% macro last_branch_earnings_published_date() %}
  {% if execute %}
    {% set last_audit_id = run_query(
        
        "
        SELECT   MAX(date_trunc('month', p.TRUNC::DATE)) AS return_date
        FROM    ANALYTICS.GS.PLEXI_PERIODS p
        WHERE   p.PERIOD_PUBLISHED = 'published'
        ").columns[0][0] 
        
    %}
  {% else %}  
    {% set last_audit_id = -1 %}
  {% endif %}

  {% do return(last_audit_id) %}
{% endmacro %}
