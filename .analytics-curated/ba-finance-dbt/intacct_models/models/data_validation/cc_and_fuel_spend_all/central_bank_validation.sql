{# in dbt Develop #}


{% set old_central_bank %}
    select
        employee_number as employee_id
        , transaction_id

        , first_name
        , last_name
        , lower(mcc) as mcc
        , status
        , merchant_name

        , transaction_amount
        , mcc_code

        , transaction_date
    from analytics.intacct_models.central_bank_test
{% endset %}


{% set new_central_bank %}
    select
        cc.employee_id
        , cc.transaction_id

        -- -- strings
        , cc.first_name
        , cc.last_name
        , lower(cc.mcc) as mcc
        , cc.status
        , cc.merchant_name

        -- -- numerics
        , cc.transaction_amount
        , cc.mcc_code

        -- -- dates
        , cc.transaction_date

    from {{ ref('stg_analytics_public__central_bank_cc_transactions') }} cc
{% endset %}


{{ audit_helper.compare_queries(
    a_query=old_central_bank,
    b_query=new_central_bank,
    summarize=true
) }}