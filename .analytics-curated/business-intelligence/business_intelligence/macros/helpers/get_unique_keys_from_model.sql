{%- macro get_unique_keys_for_model(model_name) -%}

    {%- if execute -%}

        {% do log('Checking model name: ' ~ model_name, info=true) %}

        {%- set model_config = get_model_properties(model_name, 'config_call_dict') -%}

        {{ return(model_config['unique_key']) }}
        
    {%- endif -%}

{% endmacro %}