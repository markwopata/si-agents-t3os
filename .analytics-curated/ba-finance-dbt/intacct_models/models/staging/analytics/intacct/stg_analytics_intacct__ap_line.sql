with source as (

    select * from {{ source('analytics_intacct', 'ap_line') }}

),

renamed as (

    select

        -- ids
        recordno as pk_ap_line_id,
        recordkey as fk_ap_header_id,
        parententry as fk_parent_ap_line_id,
        accountkey as fk_account_id,
        gldimud_loan::int as fk_ud_loan_id,
        gldimasset::int as gl_dim_asset_id,
        gldimtransaction_identifier as gl_dim_transaction_identifier,
        exch_rate_type_id,
        locationid as entity_id,
        departmentid as department_id,
        customerid as customer_id,
        customerdimkey as fk_customer_id,
        vendorid as vendor_id,
        vendordimkey as fk_vendor_id,
        itemid as item_id,
        itemdimkey as fk_item_id,
        classid as class_id,
        classdimkey as fk_class_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        asset_id::int as asset_id,
        locationkey as fk_entity_id,
        departmentkey as fk_department_id,
        gldimexpense_line::int as fk_expense_type_id,

        -- strings
        entrydescription as line_description,
        accounttitle as account_name,
        locationname as entity_name,
        departmentname as department_name,
        currency as currency_code,
        recordtype as ap_line_type,
        basecurr as base_currency_code,
        ud_esadmin_invoice_number as ud_admin_invoice_number,
        ud_estrack_workorder_number as ud_t3_work_order_number,
        state as invoice_line_state,

        -- numerics
        gloffset as debit_credit_sign,
        offsetglaccountno as offset_account_number,
        offsetglaccounttitle as offset_account_name,
        amount::number(38, 2) as amount,
        line_no::int as line_number,
        row_number() over (partition by recordkey, gloffset, amount order by recordno) as secondary_line_number,
        accountno as account_number,

        -- dates
        entry_date as gl_date,

        -- timestamps
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)

select * from renamed
