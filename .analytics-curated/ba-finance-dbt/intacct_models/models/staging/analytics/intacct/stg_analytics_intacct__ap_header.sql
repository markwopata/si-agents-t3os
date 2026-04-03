with source as (

    select * from {{ source('analytics_intacct', 'ap_header') }}

),

renamed as (

    select
        -- ids
        recordno as pk_ap_header_id,
        vendorid as vendor_id,
        locationkey as fk_entity_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        recordid as invoice_number,
        concur_image_id as fk_concur_image,
        modulekey as module_key,
        prbatchkey as prbatch_key,
        termkey as term_key,
        supdocid,
        billtopaytokey as bill_to_pay_to_key,
        shiptoreturntokey as ship_to_return_to_key,
        userkey as user_key,

        -- strings
        memo as invoice_memo,
        docnumber as document_number,
        description,
        description2,
        description2 as source_document_name,
        recordtype as ap_header_type,
        state as invoice_state,
        vendorname as vendor_name,
        termname as terms_name,
        paymenttype as payment_type,
        financialentity as financial_entity,
        financialaccount as bank_account,
        currency as currency_code,
        basecurr as base_currency_code,
        exchange_rate,
        yooz_url as url_concur,
        form1099type as form_1099_type,
        vendtype1099type as vendor_1099_type,
        prbatch as pr_batch,
        paymentpriority as payment_priority,
        billtopaytocontactname as bill_to_pay_to_contact_name,
        shiptoreturntocontactname as ship_to_return_to_contact_name,
        form1099box as form_1099_box,
        cleared,
        status,

        -- numerics
        totalentered::number(38, 2) as invoice_amount,
        totaldue::number(38, 2) as due_amount,
        totalpaid::number(38, 2) as paid_amount,
        totalselected::number(38, 2) as total_selected_amount,
        trx_totalselected::number(38, 2) as trx_total_selected_amount,
        trx_entitydue::number(38, 2) as trx_entity_due_amount,
        paymentamount::number(38, 2) as payment_amount,

        -- booleans
        onhold as is_on_hold,
        systemgenerated as is_system_generated,
        inclusivetax as is_inclusive_tax,

        -- dates
        whencreated as invoice_date,
        whenposted as gl_date,
        whendue as due_date,
        whendiscount as discount_date,
        recpaymentdate as rec_payment_date,
        recon_date,
        clrdate as cleared_date,
        paymentdate as payment_date,
        receiptdate as receipt_date,

        -- timestamps
        auwhencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)

select * from renamed
