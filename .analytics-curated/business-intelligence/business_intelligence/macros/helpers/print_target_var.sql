{%- macro print_target_var() -%}
  {{ log("target.name=" ~ target.name ~
         ", target.schema=" ~ target.schema ~
         ", target.database=" ~ target.database, info=True) }}
{%- endmacro -%}