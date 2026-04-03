{%- macro get_model_data_types() -%}

    {%- if execute -%}
        {% set data_type_dict = {} %}
        {% for col in adapter.get_columns_in_relation(this) -%}
            {%- if col.dtype == 'NUMBER' -%}
                {% do data_type_dict.update({ col.column | lower: col.dtype | lower ~ '(' ~ col.numeric_precision ~ ', ' ~ col.numeric_scale ~ ')' }) %}
            {%- else -%}
                {% do data_type_dict.update({ col.column | lower: col.dtype | lower ~ '(' ~ col.char_size ~ ')' }) %}
            {%- endif -%}
        {% endfor %}

        {# 
        {% do log('checking dict output', info=true) %}
        {% for key,val in data_type_dict.items() -%}
            {% do log(key ~ ': ' ~ val , info=true) %}
        {% endfor %} 
        #}
        
        {{ return(data_type_dict) }}
        
    {%- endif -%}

{% endmacro %}