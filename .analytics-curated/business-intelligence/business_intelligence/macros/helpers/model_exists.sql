{% macro model_exists() %}

{%- do log("Checking if table " ~ this ~ " exists...", info=True) -%}
{%- set relation = adapter.get_relation( database=this.database, schema=this.schema, identifier=this.identifier ) -%}

{%- do return(relation) -%}

{% endmacro %}