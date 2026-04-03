{%- macro filter_test_domains() -%}

domain not like '%dev.equipmentshare.com'
and domain not in ('staging-www.equipmentshare.com', 'staging-app.estrack.com', 'localhost')

{%- endmacro -%}
