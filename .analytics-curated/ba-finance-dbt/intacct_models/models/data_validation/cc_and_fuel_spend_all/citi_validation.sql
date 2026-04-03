{# in dbt Develop #}


{% set old_citi_bank %}
    select
        employee_number as employee_id
        , transaction_id

        , first_name
        , last_name
        -- , lower(mcc) as mcc
        -- , lower(status) as status
        -- , lower(merchant_name) as merchant_name

        , transaction_amount
        , mcc_code

        , transaction_date
    from analytics.intacct_models.citi_transactions_test
{% endset %}


{% set new_citi_bank %}
    select
        cc.employee_id
        , cc.transaction_id

        -- -- strings
        , cc.first_name
        , cc.last_name
        -- , lower(cc.mcc) as mcc
        -- , lower(cc.status) as status
        -- , lower(cc.merchant_name) as merchant_name

        -- -- -- numerics
        , cc.transaction_amount
        , cc.mcc_code

        -- -- -- dates
        , cc.transaction_date

    from {{ ref('stg_analytics_credit_card__citi_daily_transactions') }} cc
{% endset %}


{{ audit_helper.compare_queries(
    a_query=old_citi_bank,
    b_query=new_citi_bank,
    summarize=true
) }}