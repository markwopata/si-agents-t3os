{% macro be_live_build_description(description_pairs) %}
    TRIM(
    {% for pair in description_pairs %}
        {% if not loop.first %}
        || COALESCE(NULLIF(CONCAT(
            CASE 
                WHEN {{ pair['field'] }} IS NOT NULL THEN ' || '
                ELSE ''
            END,
            CASE 
                WHEN {{ pair['field'] }} IS NOT NULL 
                THEN CONCAT('{{ pair['key'] }}: ', {{ pair['field'] }})
                ELSE ''
            END
        ), ''), '')
        {% else %}
        COALESCE(NULLIF(
            CASE 
                WHEN {{ pair['field'] }} IS NOT NULL 
                THEN CONCAT('{{ pair['key'] }}: ', {{ pair['field'] }})
                ELSE ''
            END
        , ''), '')
        {% endif %}
    {% endfor %}
    )
{% endmacro %}
