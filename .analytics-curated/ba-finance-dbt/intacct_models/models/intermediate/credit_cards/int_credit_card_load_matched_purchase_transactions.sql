with matched_purchase_transactions as (
    select
        u.user_id::varchar || '|' || pt.purchase_date::date::varchar || '|' || pt.amount::varchar
        || '|'
        || row_number() over (
            partition by u.user_id, pt.amount, date_trunc('day', pt.purchase_date)
            order by u.user_id, pt.amount, pt.purchase_date, pt.external_transaction_id
        ) as pk_transaction,
        pc.pk_upload::varchar as pk_upload,
        pt.external_transaction_id::varchar as transaction_id,
        pt.purchase_date::date as transaction_date,
        pt.amount as transaction_amount,
        pt.merchant as transaction_merchant_name,
        mcc.mcc_code as transaction_mcc_code,
        mcc.mcc_description as transaction_mcc,
        left(lower(pa.account_type), 4) as transaction_card_type,
        pc.upload_id::varchar as upload_id,
        pc.upload_date,
        pc.upload_amount,
        cd.employee_id,
        cd.first_name || ' ' || cd.last_name as full_name,
        lower(cd.work_email) as work_email,
        cd.default_cost_centers_full_path as transaction_default_cost_centers_full_path,
        ccf.full_name as transaction_card_holder_name,
        pc.upload_market_id,
        case
            when pc.upload_market_id in ('38653', '79502') then 'Verified Market'
            when pc.upload_market_id in (
                    '89834', '55924', '32198', '47399', '32199', '1491', '32200',
                    '32197'
                ) then 'Erroneous Market'
            when pc.upload_market_id = '13481' then 'Corporate market'
            when pc.upload_market_id is not null then 'Verified Market'
            else 'Unrecognized Market Value'
        end as upload_market_verified,
        pc.business_sub_department_snapshot_id::varchar as sub_department_id,
        pc.business_expense_line_snapshot_id::varchar as expense_line_id,
        pc.business_department_snapshot_id::varchar as department_id,
        1 as verified_status,
        'Verified' as verified_status_desc,
        pc.upload_notes,
        pc.upload_url,
        pc.upload_submitted_at_date,
        pc.upload_modified_at_date,
        'Expenses Tool Match' as load_section,
        -- all fuel card transactions are belong to the same corporate account, the other fuel account has been deprecated
        case
            when pa.account_type = 'FUEL' then '863295028'
            else ccf.corporate_account_number
        end as corporate_account_number,
        cca.corporate_account_name,
        pc.is_personal_expense,
        pc.is_return,
        current_timestamp as record_timestamp
    from {{ ref('stg_procurement_public__matched_purchase_transactions') }} as mpt
        inner join {{ ref('stg_procurement_public__purchase_transactions') }} as pt
            on mpt.purchase_transaction_id = pt.purchase_transaction_id
        inner join {{ ref('stg_procurement_public__purchase_accounts') }} as pa
            on pt.purchase_account_id = pa.purchase_account_id
        inner join {{ ref('stg_es_warehouse_public__users') }} as u
            on pa.user_id = u.user_id
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
            on cd.employee_id::varchar = u.employee_id::varchar
            -- joining to get additional purchase upload detail
        inner join {{ ref('int_credit_card_load_cc_uploads') }} as pc
            on mpt.purchase_id = pc.upload_id
        left join {{ ref('stg_analytics_gs__mcc') }} as mcc
            on pt.mcc_code = mcc.mcc_code
        -- inner joining to get addtional cc transaction detail
        inner join {{ ref('cc_and_fuel_spend_all') }} as ccf
            on pt.external_transaction_id = ccf.transaction_id
        -- joining to get corporate account name
        left join {{ ref('stg_analytics_credit_card__corporate_card_accounts') }} as cca
            on cca.corporate_account_number::varchar
                -- all fuel card transactions are belong to the same corporate account, the other fuel account has been deprecated
                = case
                    when pa.account_type = 'FUEL'
                        then '863295028'
                    else ccf.corporate_account_number
                end
    where
    -- per Gina Campagna: no need to verify debts over $3 USD
        (ccf.transaction_amount >= 3
        -- per Gina Campagna: no need to verify credits under $3 USD after 09/26/2025
        -- also, no need to verify any credit before 09/26/2025
        or (ccf.transaction_amount < -3 and ccf.transaction_date >= '2025-09-26'))
        and (
        --allow cc transactions that are not fuel before this date
            (ccf.transaction_date >= '2023-07-01' and ccf.card_type != 'fuel_card')
            or (ccf.transaction_date >= '2023-08-21' and ccf.card_type = 'fuel_card')
        )
        and (cd.default_cost_centers_full_path ilike 'Corp/Corp/Corporate/%' or ccf.transaction_amount > -3)
        --exclude vsg car charging department from Nicholas Bauman
        and ccf.full_name != 'VSGCARCHARGING DEPARTMENT'

)

select *
from matched_purchase_transactions
