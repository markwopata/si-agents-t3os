{# in dbt Develop #}


{% set old_asset4000_query %}
select
    admin_asset_id
    , depreciation_date
    , asset4000_original_cost
    , asset4000_net_book_value
from analytics.intacct_models.asset4000_oec_nbv_test
{% endset %}


{% set new_asset4000_query %}
select
    admin_asset_id
    , depreciation_date
    , asset4000_original_cost
    , asset4000_net_book_value
from {{ ref('asset4000_oec_nbv') }}
{% endset %}


{{ audit_helper.compare_queries(
    a_query=old_asset4000_query,
    b_query=new_asset4000_query,
    summarize=true
) }}