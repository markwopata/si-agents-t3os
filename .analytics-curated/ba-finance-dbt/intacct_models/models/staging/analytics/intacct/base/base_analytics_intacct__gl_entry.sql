with source as (
    select * from {{ source('analytics_intacct', 'gl_entry') }}
),

renamed as (
    select

        -- ids 
        recordno as pk_gl_entry_id,
        accountkey as fk_account_id,
        departmentkey as fk_department_id,
        department as department_id,
        department as market_id,
        locationkey as fk_entity_id,
        location as entity_id,
        gldimexpense_line::int as fk_expense_type_id,
        batchno as fk_journal_id,
        gldimud_loan::int as fk_ud_loan_id,
        gldimtransaction_identifier as gl_dim_transaction_identifier,
        gldimasset::int as gl_dim_asset_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        coalesce(gl_dim_asset_id::varchar, asset_id) as asset_id, -- casting gl_dim_asset_id to varchar to match asset_id type (asset_id can contain multiple assets ie (571787, 571788))

        -- strings
        tr_type as debit_credit_sign,
        description as entry_description,
        batchtitle as journal_title,
        iff(tr_type = 1, 'debit', 'credit') as debit_credit,
        currency as currency_code,
        basecurr as base_currency_code,
        document,
        ud_estrack_workorder_number as ud_t3_work_order_number,
        ud_esadmin_invoice_number as ud_admin_invoice_number,
        state as entry_state,

        -- numerics
        accountno as account_number,
        -1 as positive_revenue_sign,
        amount::number(38, 2) as raw_amount,
        (raw_amount * debit_credit_sign)::number(38, 2) as net_amount,
        trx_amount::number(38, 2) as raw_trx_amount,
        (raw_trx_amount * debit_credit_sign)::number(38, 2) as net_trx_amount,
        (raw_trx_amount * (debit_credit_sign * -1))::number(38, 2) as trx_amount,
        (raw_amount * (debit_credit_sign * -1))::number(38, 2) as amount,
        exchange_rate,
        line_no as line_number,
        debit_credit_sign * -1 as applied_sign,

        -- booleans
        statistical != 'F' as is_statistical,

        -- dates
        entry_date,
        exch_rate_date as exchange_rate_date,

        -- timestamps
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source
)

select * from renamed
