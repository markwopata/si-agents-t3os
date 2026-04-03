{%- macro get_model_properties(model_name, property) -%}

    {%- if execute -%}

        {%- set models = graph.nodes.values() -%}

        {%- set model = (models | selectattr('name', 'equalto', model_name) | list).pop() -%}

        {# 
        {% for node in graph.nodes.values() %}
            {% do log(node, info=true)%}
        {% endfor %} 
        #}

        {%- do log('Getting property ' ~ property ~ ' from model ' ~ model['name'], info=true) -%}
        
        {{ return(model[property]) }}
        
    {%- endif -%}

{%- endmacro -%}