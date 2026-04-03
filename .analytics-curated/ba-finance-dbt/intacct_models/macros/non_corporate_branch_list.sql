{# Returns a distinct list of branches that are not corporate #}
{% macro non_corporate_branch_list() %}

    select distinct branch_id
        from {{ ref('stg_es_warehouse_public__branch_erp_refs') }}
        where branch_id != 13481
        
{% endmacro %}
