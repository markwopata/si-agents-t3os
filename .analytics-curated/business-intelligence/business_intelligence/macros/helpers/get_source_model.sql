{# https://docs.getdbt.com/reference/dbt-jinja-functions/graph #}

{% macro get_source_model(model_name) %}

    {%- if execute -%}
        {% set sources = get_model_properties(this.name, 'sources') %}

        {% set unique_sources = [] %}    
        {% for source in sources if source not in unique_sources %}
            {% do unique_sources.append(source) %}
        {% endfor %}

        {{ return(unique_sources) }}

    {%- endif -%}

{% endmacro %}