{%- macro create_url_encode_udf() %}

create or replace function {{ target.database }}.silver.urlencodestring(str string)
returns string
language javascript
strict
as
$$
    return encodeURIComponent(arguments[0]);
$$;

{%- endmacro -%}