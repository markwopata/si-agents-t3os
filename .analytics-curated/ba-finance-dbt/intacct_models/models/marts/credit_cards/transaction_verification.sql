{% set date_buffer = 5 %}

{{ config(
    schema='credit_card'
) }}

with reallocated_transactions as (
    select
        pk_transaction,
        pk_upload,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_merchant_name,
        transaction_mcc_code,
        transaction_mcc,
        transaction_card_type,
        upload_id::int as upload_id,
        upload_date,
        upload_amount,
        employee_id,
        full_name,
        work_email,
        transaction_default_cost_centers_full_path,
        transaction_card_holder_name,
        upload_market_id::int as upload_market_id,
        upload_market_verified,
        sub_department_id,
        sub_department,
        expense_line_id,
        expense_line,
        verified_status,
        verified_status_desc,
        upload_notes,
        upload_url,
        upload_submitted_at_date,
        upload_modified_at_date,
        load_section,
        corporate_account_name,
        is_personal_expense,
        is_return,
        recordtimestamp
    from {{ ref('int_credit_card_load_reallocated_transactions') }}
    where not (corporate_account_name = 'EQS EMPLOYEE REWARDS' or corporate_account_number = '5563970058548639')
),

expenses_tool_matched_transactions as (
    select
        mpt.pk_transaction,
        mpt.pk_upload,
        mpt.transaction_id::varchar as transaction_id,
        mpt.transaction_date,
        mpt.transaction_amount,
        mpt.transaction_merchant_name,
        mpt.transaction_mcc_code,
        mpt.transaction_mcc,
        mpt.transaction_card_type,
        mpt.upload_id,
        mpt.upload_date,
        mpt.upload_amount,
        mpt.employee_id,
        mpt.full_name,
        mpt.work_email,
        mpt.transaction_default_cost_centers_full_path,
        mpt.transaction_card_holder_name,
        mpt.upload_market_id,
        mpt.upload_market_verified,
        bu_sub.sub_department_id::varchar as sub_department_id,
        bu_sub.name as sub_department,
        bu_exp.expense_line_id,
        bu_exp.name as expense_line,
        mpt.verified_status,
        mpt.verified_status_desc,
        mpt.upload_notes,
        mpt.upload_url,
        mpt.upload_submitted_at_date,
        mpt.upload_modified_at_date,
        mpt.load_section,
        mpt.corporate_account_name,
        mpt.is_personal_expense,
        mpt.is_return,
        mpt.record_timestamp as recordtimestamp
    from {{ ref('int_credit_card_load_matched_purchase_transactions') }} as mpt
    -- selecting sub department names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_sub
            on mpt.sub_department_id
                = bu_sub.business_unit_snapshot_id
                and bu_sub.business_unit_type = upper('sub_department')
        -- selecting expense line item names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_exp
            on mpt.expense_line_id
                = bu_exp.business_unit_snapshot_id
                and bu_exp.business_unit_type = upper('expense_line')
        -- filtering for transaction_ids that are already in reallocated transactions
        left join reallocated_transactions as r
            on mpt.transaction_id::varchar = r.transaction_id::varchar
    where r.transaction_id is null -- exclude already reallocated transactions

),

adjustment_transactions as (
    select
        cfc.pk_transaction,
        null as pk_upload,
        cfc.transaction_id,
        cfc.transaction_date,
        cfc.transaction_amount,
        cfc.transaction_merchant_name,
        cfc.transaction_mcc_code,
        cfc.transaction_mcc,
        cfc.transaction_card_type,
        null as upload_id,
        null as upload_date,
        null as upload_amount,
        cfc.employee_id,
        cfc.full_name,
        cfc.work_email,
        cfc.transaction_default_cost_centers_full_path,
        cfc.transaction_card_holder_name,
        p.market_id as upload_market_id,
        case
            when p.market_id in ('38653', '79502') then 'Verified Market'
            when
                p.market_id in ('89834', '55924', '32198', '47399', '32199', '1491', '32200', '32197')
                then 'Erroneous Market'
            when p.market_id = '13481' then 'Corporate market'
            when p.market_id is not null then 'Verified Market'
            else 'Unrecognized Market Value'
        end as upload_market_verified,
        bu_sub.sub_department_id::varchar as sub_department_id,
        bu_sub.name as sub_department,
        bu_exp.expense_line_id,
        bu_exp.name as expense_line,
        1 as verified_status,
        'Verified' as verified_status_desc,
        pta.adjustment_description as upload_notes,
        null as upload_url,
        pta.date_created as upload_submitted_at_date,
        null as upload_modified_at_date,
        'Adjustment Transaction' as load_section,
        cfc.corporate_account_name,
        p.is_personal_expense,
        pta.is_credit as is_return,
        current_timestamp as recordtimestamp
    from {{ ref('int_credit_card_load_cc_and_fuel_transactions') }} as cfc
        inner join {{ ref('stg_procurement_public__purchase_transaction_adjustments') }} as pta
            on cfc.transaction_id = pta.external_transaction_id
        left join {{ ref('stg_procurement_public__matched_purchase_transactions') }} as mpt
            on pta.adjusted_transaction_id = mpt.purchase_transaction_id
        left join {{ ref('stg_procurement_public__purchases') }} as p
            on mpt.purchase_id = p.purchase_id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_sub
            on p.business_sub_department_snapshot_id = bu_sub.business_unit_snapshot_id
                and bu_sub.business_unit_type = upper('sub_department')
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_exp
            on p.business_expense_line_snapshot_id = bu_exp.business_unit_snapshot_id
                and bu_exp.business_unit_type = upper('expense_line')
),

reallocated_and_expenses_tool_transactions as (
    select
        transaction_id,
        upload_id
    from reallocated_transactions
    union all
    select
        transaction_id,
        upload_id
    from expenses_tool_matched_transactions
    union all
    select
        transaction_id,
        null as upload_id
    from adjustment_transactions
),

pk_exact_match as (
    select
        cfc.pk_transaction,
        pc.pk_upload,
        cfc.transaction_id,
        cfc.transaction_date,
        cfc.transaction_amount,
        cfc.transaction_merchant_name,
        cfc.transaction_mcc_code,
        cfc.transaction_mcc,
        cfc.transaction_card_type,
        pc.upload_id,
        pc.upload_date,
        pc.upload_amount,
        cfc.employee_id,
        cfc.full_name,
        cfc.work_email,
        cfc.transaction_default_cost_centers_full_path,
        cfc.transaction_card_holder_name,
        pc.upload_market_id,
        case
            when pc.upload_market_id in ('38653', '79502') then 'Verified Market'
            when pc.upload_market_id in (
                    '89834', '55924', '32198', '47399', '32199', '1491', '32200', '32197'
                ) then 'Erroneous Market'
            when pc.upload_market_id = '13481' then 'Corporate market'
            when pc.upload_market_id is not null then 'Verified Market'
            else 'Unrecognized Market Value'
        end as upload_market_verified,
        bu_sub.sub_department_id::varchar as sub_department_id,
        bu_sub.name as sub_department,
        bu_exp.expense_line_id,
        bu_exp.name as expense_line,
        1 as verified_status,
        'Verified' as verified_status_desc,
        pc.upload_notes,
        pc.upload_url,
        pc.upload_submitted_at_date,
        pc.upload_modified_at_date,
        'Primary Key Exact Match' as load_section, -- capturing matches by primary key
        cfc.corporate_account_name,
        pc.is_personal_expense,
        pc.is_return,
        current_timestamp as recordtimestamp -- ensures timestamp for data auditability
    from {{ ref('int_credit_card_load_cc_and_fuel_transactions') }} as cfc
        inner join {{ ref('int_credit_card_load_cc_uploads') }} as pc
            on cfc.pk_transaction = pc.pk_upload -- joining by the PK we created
        -- selecting sub department names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_sub
            on pc.business_sub_department_snapshot_id = bu_sub.business_unit_snapshot_id
                and bu_sub.business_unit_type = upper('sub_department')
        -- selecting expense line item names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_exp
            on pc.business_expense_line_snapshot_id = bu_exp.business_unit_snapshot_id
                and bu_exp.business_unit_type = upper('expense_line')
        -- filtering for transaction_ids that are already in reallocated transactions
        left join reallocated_and_expenses_tool_transactions as t_id
            on cfc.transaction_id = t_id.transaction_id

        left join reallocated_and_expenses_tool_transactions as u_id
            on pc.upload_id = u_id.upload_id
    where t_id.transaction_id is null -- exclude already reallocated transactions
        and u_id.upload_id is null -- exclude already reallocated uploads
),

matched_transactions as (
    select
        pkm.transaction_id,
        pkm.upload_id
    from pk_exact_match as pkm -- transaction id's and upload id's already matched in primary key join
    union all
    select
        rt.transaction_id,
        rt.upload_id
    -- transaction id's and upload id's already separated for the reallocated transactions
    from reallocated_and_expenses_tool_transactions as rt
),

multi_col_join as (
    select
        cfc.pk_transaction,
        pc.pk_upload,
        cfc.transaction_id,
        cfc.transaction_date,
        cfc.transaction_amount,
        cfc.transaction_merchant_name,
        cfc.transaction_mcc_code,
        cfc.transaction_mcc,
        cfc.transaction_card_type,
        pc.upload_id,
        pc.upload_date,
        pc.upload_amount,
        cfc.employee_id,
        cfc.full_name,
        cfc.work_email,
        cfc.transaction_default_cost_centers_full_path,
        cfc.transaction_card_holder_name,
        pc.upload_market_id,
        case
            when pc.upload_market_id in ('38653', '79502') then 'Verified Market'
            when pc.upload_market_id in (
                    '89834', '55924', '32198', '47399', '32199', '1491', '32200', '32197'
                ) then 'Erroneous Market'
            when pc.upload_market_id = '13481' then 'Corporate market'
            when pc.upload_market_id is not null then 'Verified Market'
            else 'Unrecognized Market Value'
        end as upload_market_verified,
        bu_sub.sub_department_id::varchar as sub_department_id,
        bu_sub.name as sub_department,
        bu_exp.expense_line_id,
        bu_exp.name as expense_line,
        1 as verified_status,
        'Verified' as verified_status_desc,
        pc.upload_notes,
        pc.upload_url,
        pc.upload_submitted_at_date,
        pc.upload_modified_at_date,
        'Multi-Column Join - One Possible Combo' as load_section, -- indicating the join type
        cfc.corporate_account_name,
        pc.is_personal_expense,
        pc.is_return,
        current_timestamp as recordtimestamp
    from {{ ref('int_credit_card_load_cc_and_fuel_transactions') }} as cfc
        -- joining by user_id, transaction amount, transaction date +- 5 days, and transaction rank
        inner join {{ ref('int_credit_card_load_cc_uploads') }} as pc
            on cfc.transaction_user_id = pc.upload_user_id
                and cfc.transaction_amount = pc.upload_amount
                and cfc.transaction_date::date between
                dateadd(days, -1 * {{ date_buffer }}, pc.upload_date::date) and
                dateadd(days, {{ date_buffer }}, pc.upload_date::date)
                and cfc.transaction_rank = pc.upload_rank
        left join matched_transactions as mt_id -- filter for transaction_ids that were already used
            on cfc.transaction_id = mt_id.transaction_id
        left join matched_transactions as mu_id -- filter for upload_ids already used
            on pc.upload_id = mu_id.upload_id
        -- selecting sub department names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_sub
            on pc.business_sub_department_snapshot_id = bu_sub.business_unit_snapshot_id
                and bu_sub.business_unit_type = upper('sub_department')
        -- selecting expense line item names for its respective snapshot id
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_exp
            on pc.business_expense_line_snapshot_id = bu_exp.business_unit_snapshot_id
                and bu_exp.business_unit_type = upper('expense_line')
    where mt_id.transaction_id is null -- excluding already matched transaction_ids
        and mu_id.upload_id is null -- excluding already matched upload_ids
    qualify
        count(pc.pk_upload) over (partition by pc.pk_upload) = 1 -- only joining columns that match by one upload id
        -- only joining columns that match by one transaction id
        and count(cfc.pk_transaction) over (partition by cfc.pk_transaction) = 1
),

matched_transactions_w_multicol as (
    select
        transaction_id,
        upload_id
    from matched_transactions
    union all
    select
        transaction_id,
        upload_id
    from multi_col_join
),

transactions_filtered as (
    select cfc.*
    from {{ ref('int_credit_card_load_cc_and_fuel_transactions') }} as cfc
        left join matched_transactions_w_multicol as mt_id
            on cfc.transaction_id = mt_id.transaction_id -- filtering for unused transaction_ids
    where mt_id.transaction_id is null
),

uploads_filtered as (
    select pc.*
    from {{ ref('int_credit_card_load_cc_uploads') }} as pc
        left join matched_transactions_w_multicol as mu_id
            on pc.upload_id = mu_id.upload_id -- filtering for unused upload_ids
    where mu_id.upload_id is null
),

loop_based_combo as (
    select
        cfc.pk_transaction,
        pc.pk_upload,
        cfc.transaction_id,
        cfc.transaction_date,
        cfc.transaction_amount,
        cfc.transaction_merchant_name,
        cfc.transaction_mcc_code,
        cfc.transaction_mcc,
        cfc.transaction_card_type,
        pc.upload_id,
        pc.upload_date,
        pc.upload_amount,
        cfc.employee_id,
        cfc.full_name,
        cfc.work_email,
        cfc.transaction_default_cost_centers_full_path,
        cfc.transaction_card_holder_name,
        pc.upload_market_id,
        case
            when pc.upload_market_id in ('38653', '79502') then 'Verified Market'
            when pc.upload_market_id in (
                    '89834', '55924', '32198', '47399', '32199', '1491', '32200', '32197'
                ) then 'Erroneous Market'
            when pc.upload_market_id = '13481' then 'Corporate market'
            when pc.upload_market_id is not null then 'Verified Market'
            else 'Unrecognized Market Value'
        end as upload_market_verified,
        bu_sub.sub_department_id::varchar as sub_department_id,
        bu_sub.name as sub_department,
        bu_exp.expense_line_id::varchar as expense_line_id,
        bu_exp.name as expense_line,
        case
            when pc.pk_upload is null then 0
            else 1
        end as verified_status, -- indicates if a match was successful
        case
            when pc.pk_upload is null then 'Unverified'
            else 'Verified'
        end as verified_status_desc, -- describes the verification status
        pc.upload_notes,
        pc.upload_url,
        pc.upload_submitted_at_date,
        pc.upload_modified_at_date,
        case
            when pc.pk_upload is null then 'No Match Found'
            else 'Loop Based Combo'
        end as load_section,
        cfc.corporate_account_name,
        pc.is_personal_expense,
        pc.is_return,
        current_timestamp as recordtimestamp
    from transactions_filtered as cfc
        left join uploads_filtered as pc
            on cfc.transaction_user_id = pc.upload_user_id
                -- compare upload amount to the absolute value to consider credits as well
                and abs(cfc.transaction_amount) = pc.upload_amount
                and cfc.transaction_date::date between
                dateadd(days, -1 * {{ date_buffer }}, pc.upload_date::date) and
                dateadd(days, {{ date_buffer }}, pc.upload_date::date)
        -- selecting sub departments for snapshot ids
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_sub
            on pc.business_sub_department_snapshot_id = bu_sub.business_unit_snapshot_id
                and bu_sub.business_unit_type = upper('sub_department')
        -- selecting expense lines for snapshot ids
        left join {{ ref('int_credit_card_load_business_unit_type') }} as bu_exp
            on pc.business_expense_line_snapshot_id = bu_exp.business_unit_snapshot_id
                and bu_exp.business_unit_type = upper('expense_line')
    qualify
        row_number() over (
            partition by cfc.transaction_id
            order by
                cfc.transaction_rank,
                pc.upload_rank,
                case
                    when pc.upload_notes = '' or pc.upload_notes is null then 1
                    else 0
                end,
                abs(datediff(days, cfc.transaction_date, pc.upload_date))
        ) = 1
),

categorized_upload_id as (
    select
        *,
        row_number() over (
            partition by upload_id
            --more granular level to time difference
            order by abs(datediff(hours, transaction_date, upload_date)), transaction_id
        ) as rn --ranking repeated uploads by difference in dates and if not, transaction_id
    from loop_based_combo
    where upload_id is not null
),

loop_match_join as (
    select
        pk_transaction,
        pk_upload,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_merchant_name,
        transaction_mcc_code,
        transaction_mcc,
        transaction_card_type,
        upload_id,
        upload_date,
        upload_amount,
        employee_id,
        full_name,
        work_email,
        transaction_default_cost_centers_full_path,
        transaction_card_holder_name,
        upload_market_id,
        upload_market_verified,
        sub_department_id,
        sub_department,
        expense_line_id,
        expense_line,
        1 as verified_status,
        'Verified' as verified_status_desc,
        upload_notes,
        upload_url,
        upload_submitted_at_date,
        upload_modified_at_date,
        'Loop Based Combo' as load_section,
        corporate_account_name,
        is_personal_expense,
        is_return,
        recordtimestamp
    from categorized_upload_id --changing repeated upload id matches to No Match Found
    where upload_id is not null
        and rn = 1

    union all

    select
        pk_transaction,
        null as pk_upload,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_merchant_name,
        transaction_mcc_code,
        transaction_mcc,
        transaction_card_type,
        null as upload_id,
        null as upload_date,
        null as upload_amount,
        employee_id,
        full_name,
        work_email,
        transaction_default_cost_centers_full_path,
        transaction_card_holder_name,
        null as upload_market_id,
        null as upload_market_verified,
        null as sub_department_id,
        null as sub_department,
        null as expense_line_id,
        null as expense_line,
        0 as verified_status,
        'Unverified' as verified_status_desc,
        null as upload_notes,
        null as upload_url,
        null as upload_submitted_at_date,
        null as upload_modified_at_date,
        'No Match Found - Looped Match Already Used Receipt' as load_section,
        corporate_account_name,
        is_personal_expense,
        is_return,
        recordtimestamp
    from categorized_upload_id --changing repeated upload id matches to No Match Found
    where upload_id is not null
        and rn != 1

    union all

    select
        pk_transaction,
        pk_upload,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_merchant_name,
        transaction_mcc_code,
        transaction_mcc,
        transaction_card_type,
        upload_id,
        upload_date,
        upload_amount,
        employee_id,
        full_name,
        work_email,
        transaction_default_cost_centers_full_path,
        transaction_card_holder_name,
        upload_market_id,
        upload_market_verified,
        sub_department_id,
        sub_department,
        expense_line_id,
        expense_line,
        verified_status,
        verified_status_desc,
        upload_notes,
        upload_url,
        upload_submitted_at_date,
        upload_modified_at_date,
        load_section,
        corporate_account_name,
        is_personal_expense,
        is_return,
        recordtimestamp
    from loop_based_combo
    where upload_id is null --joining it together with uploads that don't have a matching transaction id
),

transaction_verification as (
    select * from reallocated_transactions -- 100% "verified" - bypass verification or reallocated
    union all
    select * from expenses_tool_matched_transactions -- 100% "verified" - expenses tool matched
    union all
    select * from adjustment_transactions -- 100% "verified" - adjustment transactions tied to original receipt
    union all
    select * from pk_exact_match -- 100% verified
    union all
    select * from multi_col_join -- 100% verified
    union all
    select * from loop_match_join
),

extra_exclusions as (
    select
        pk_transaction,
        pk_upload,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_merchant_name,
        transaction_mcc_code,
        transaction_mcc,
        transaction_card_type,
        upload_id,
        upload_date,
        upload_amount,
        employee_id,
        full_name,
        work_email,
        transaction_default_cost_centers_full_path,
        transaction_card_holder_name,
        upload_market_id,
        upload_market_verified,
        sub_department_id,
        sub_department,
        expense_line_id,
        expense_line,
        1 as verified_status, -- Mark verified
        'Verified' as verified_status_desc,
        upload_notes,
        upload_url,
        upload_submitted_at_date,
        upload_modified_at_date,
        'Drop 2025 and prior unverified' as load_section,
        corporate_account_name,
        is_personal_expense,
        is_return,
        recordtimestamp
    from transaction_verification
    -- On release, we started including some old transactions from 2023/2024 because prior methods were 
    -- duplicating. End user didn't actually submit receipts for these.
    where transaction_date < '2025-01-01'
        and verified_status = 0 -- Unverified transactions
),

final as (
    select * from transaction_verification
    where transaction_id not in (
            select transaction_id from extra_exclusions
        )

    union all

    select * from extra_exclusions
)

select *
from final
