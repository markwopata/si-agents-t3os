-- prod: stg_analytics_intacct__gl_resolve: https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/c5966a68c6263a313a31a320dc96a23c0d6ccac0/intacct_models/models/staging/analytics/intacct/stg_analytics_intacct__gl_resolve.sql
{% set query_prod %}
select
    pk_gl_resolve_id
    , raw_amount
from analytics.intacct_models.stg_analytics_intacct__gl_resolve
{% endset %}

-- proposed: 
{% set query_dev %}
select
    pk_gl_resolve_id
    , raw_amount
from {{ ref('base_analytics_intacct__gl_resolve') }}
{% endset %}

{{ audit_helper.compare_queries(
    a_query=query_prod,
    b_query=query_dev,
    summarize = True
) }}
