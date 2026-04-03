with unverified_reallocations as (
    select
        cdu.user_id::varchar || '|' || ccf.transaction_date::date::varchar || '|' || ccf.transaction_amount::varchar
        || '|'
        || row_number() over (
            partition by cdu.user_id, ccf.transaction_amount, date_trunc(day, ccf.transaction_date)
            order by cdu.user_id, ccf.transaction_amount, ccf.transaction_date, ccf.transaction_id
        -- add additional identifier to pk to avoid potential pk conflicts with cc transactions that are not reallocated
        ) || '|R' as pk_transaction,
        null as pk_upload,
        ra.transaction_id,
        ccf.transaction_date,
        ccf.transaction_amount,
        ccf.merchant_name as transaction_merchant_name,
        ccf.mcc_code as transaction_mcc_code,
        ccf.mcc as transaction_mcc,
        left(lower(ccf.card_type), 4) as transaction_card_type,
        null as upload_id,
        null::date as upload_date,
        null as upload_amount,
        cd.employee_id,
        cd.first_name || ' ' || cd.last_name as full_name,
        lower(cd.work_email) as work_email,
        cd.default_cost_centers_full_path as transaction_default_cost_centers_full_path,
        ccf.full_name as transaction_card_holder_name,
        null as upload_market_id,
        'Unrecognized Market Value' as upload_market_verified,
        null as sub_department_id,
        null as sub_department,
        null as expense_line_id,
        null as expense_line,
        2 as verified_status,
        'Reallocated' as verified_status_desc,
        null::varchar as upload_notes,
        null::varchar as upload_url,
        null::date as upload_submitted_at_date,
        null::date as upload_modified_at_date,
        'Reallocation Transaction' as load_section,
        ccf.corporate_account_number,
        ccf.corporate_account_name,
        null::boolean as is_personal_expense,
        null::boolean as is_return,
        current_timestamp as recordtimestamp
    from {{ ref('stg_analytics_corporate_budget__unverified_cc_reallocations') }} as ra
        inner join {{ ref('cc_and_fuel_spend_all') }} as ccf
            on ra.transaction_id = ccf.transaction_id
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
            on ccf.employee_number = cd.employee_id
        inner join {{ ref("int_company_directory_to_users") }} as cdu
            on cd.employee_id = cdu.employee_id
),

bypass_verifications as (
    select
        ccf.employee_number::varchar
        || '|'
        || ccf.transaction_date::date::varchar
        || '|'
        || ccf.transaction_amount::varchar
        || '|'
        || row_number() over (
            partition by ccf.employee_number, ccf.transaction_amount, date_trunc(day, ccf.transaction_date)
            order by ccf.employee_number, ccf.transaction_amount, ccf.transaction_date, ccf.transaction_id
        -- add additional identifier to pk to avoid potential pk conflicts with cc transactions that are not reallocated
        ) || '|R' as pk_transaction,
        null as pk_upload,
        ccf.transaction_id,
        ccf.transaction_date,
        ccf.transaction_amount,
        ccf.merchant_name as transaction_merchant_name,
        ccf.mcc_code as transaction_mcc_code,
        ccf.mcc as transaction_mcc,
        left(lower(ccf.card_type), 4) as transaction_card_type,
        null as upload_id,
        null::date as upload_date,
        null as upload_amount,
        ccf.employee_number as employee_id,
        null as full_name,
        null as work_email,
        null as transaction_default_cost_centers_full_path,
        ccf.full_name as transaction_card_holder_name,
        null as upload_market_id,
        'Unrecognized Market Value' as upload_market_verified,
        null as sub_department_id,
        null as sub_department,
        null as expense_line_id,
        null as expense_line,
        3 as verified_status,
        'Travel Platform' as verified_status_desc,
        null::varchar as upload_notes,
        null::varchar as upload_url,
        null::date as upload_submitted_at_date,
        null::date as upload_modified_at_date,
        'Reallocation Transaction' as load_section,
        ccf.corporate_account_number,
        ccf.corporate_account_name,
        null::boolean as is_personal_expense,
        null::boolean as is_return,
        current_timestamp as recordtimestamp
    from {{ ref('cc_and_fuel_spend_all') }} as ccf
    where (ccf.is_bypass_verification = true --transactions that don't require verification
    --exclude cc transactions from the benefits rewards cards
    or (ccf.corporate_account_name = 'EQS EMPLOYEE REWARDS' or ccf.corporate_account_number = '5563970058548639'))
    and ccf.employee_number is not null
)

select * from unverified_reallocations
union all
select * from bypass_verifications
