{%- macro get_source_to_target_mapping_dict() -%}

    {#- get source -#}
    {%- set source_name = get_source_model( this.name ) -%}

    {# get columns in source and target, since some of the ones in target are renamed #}
    {%- set source_columns = dbt_utils.get_filtered_columns_in_relation(from=source(source_name[0][0], source_name[0][1])) -%}
    {%- set target_columns = dbt_utils.get_filtered_columns_in_relation(from=this, except=["_dbt_updated_timestamp"]) -%}

    {%- set data_type_dict = get_model_data_types() -%}

    {# create a dictionary mapping source columns to the renamed target columns #}
    {%- set column_mapping_dict = {} -%}
    {%- for source_col, target_col in zip(source_columns, target_columns) -%}
        {%- do column_mapping_dict.update({source_col | lower: target_col | lower}) -%}
    {%- endfor -%}

    {{ return(column_mapping_dict) }}

{% endmacro %}