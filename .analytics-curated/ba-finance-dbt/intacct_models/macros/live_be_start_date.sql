{% macro live_be_start_date() %}
  {% if execute %}
    {% set my_date = last_branch_earnings_published_date() %}
    {% set last_audit_id = run_query(
        
        "
        SELECT   dateadd(months, -1, '" ~ last_branch_earnings_published_date() ~ "')
        ").columns[0][0]
        
    %}
  {% else %}  
    {% set last_audit_id = -1 %}
  {% endif %}

  {% do return(last_audit_id) %}
{% endmacro %}

