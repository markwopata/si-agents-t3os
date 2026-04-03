with source as (

    select * from {{ source('analytics_public', 'branch_earnings_dds_snap') }}

),

renamed as (

    select
        -- ids
        pk,
        mkt_id as market_id,

        -- strings
        mkt_name as market_name,
        type,
        code,
        revexp as revenue_expense_category,
        dept as department,
        pr_type as payroll_type,
        gl_acct as account_name,
        acctno as account_number,
        ar_type as accounts_receivable_type,
        descr as description,
        doc_no,
        url_sage,
        url_yooz,
        url_admin,
        url_track,
        type2,

        -- numerics
        amt as amount,

        -- timestamps
        gl_date

    from source

)

select * from renamed
