with source as (
    select * from {{ source('analytics_intacct', 'ar_header') }} as arr

)

, renamed as (
    select
        -- ids
        recordno as pk_ar_header_id,
        termkey as fk_terms_id,
        customerid as customer_id,
        recordid as invoice_number,
        locationkey as fk_entity_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,

        -- strings
        description,
        docnumber as document_number,
        recordtype as ar_header_type,
        customername as customer_name,
        termname as terms_name,
        basecurr as base_currency_code,
        currency as currency_code,
        state as invoice_state,
        financialentity as bank_account,
        undepositedaccountno as undeposited_funds_account_number,
        paymentmethod as payment_method,
        paymentmethodkey as fk_payment_method_id,
        paymenttype as payment_type,
        batchtitle as journal_title,
        memo as invoice_memo,
        status as invoice_status,


        -- numerics
        totalentered as invoice_amount,

        -- booleans
        onhold as is_on_hold,

        -- dates
        whenposted as gl_date,
        whendue as due_date,
        whenpaid as date_paid,
        whencreated as invoice_date,
        postingdate as date_posted,

        -- timestamps
        auwhencreated as date_created,
        ddsreadtime as dds_read_timestamp,
        whenmodified as date_updated

    from source

)

select * from renamed
