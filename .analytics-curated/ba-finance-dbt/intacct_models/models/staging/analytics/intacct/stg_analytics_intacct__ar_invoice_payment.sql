with source as (

    select * from {{ source('analytics_intacct', 'ar_invoice_payment') }}

),

renamed as (

    select

        -- ids
        recordno as pk_ar_invoice_payment_id,
        paymentkey as payment_key,
        payitemkey as pay_item_key,
        recordkey as record_key,
        paiditemkey as paid_item_key,
        parentpymt as parent_payment,

        -- strings
        state,
        currency as currency_code,
        createdby as fk_created_by_user_id,
        modifiedby as fk_modified_by_user_id,

        -- numerics
        amount,
        trx_amount as transaction_amount,
        invbaseamt as invoice_base_amount,
        invtrxamt as invoice_transaction_amount,

        -- booleans
        -- dates
        paymentdate as payment_date,

        -- timestamps
        whenmodified as date_updated,
        whencreated as date_created,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)

select * from renamed
