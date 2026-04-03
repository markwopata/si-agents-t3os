with employee_to_account as (
-- This is inefficient, but it's a temporary solution Vishesh 2024/06/12
    select distinct
        gl_detail.account_number,
        credit_card_employee.employee_number
    from {{ ref("gl_detail") }} as gl_detail
        inner join {{ ref("cc_and_fuel_spend_all") }} as credit_card_employee
            on split_part(gl_detail.entry_description, ';', 3) = credit_card_employee.transaction_id
                and split_part(gl_detail.entry_description, ';', 1) ilike '%fuel%'
    where gl_detail.account_number in ('6015', '6302', '6309', '7302')
        and gl_detail.journal_title ilike '%fuel%alloc%'
    qualify row_number() over (
            partition by credit_card_employee.employee_number
            order by gl_detail.entry_date desc
        ) = 1
),

cc_and_fuel as (
    select *
    from {{ ref("cc_and_fuel_spend_all") }}
    where
        transaction_date::date
        >= '{{ live_be_start_date() }}'
        -- Remove transactions that have been allocated in sage
        and date_trunc(month, transaction_date) not in (
            select distinct date_trunc(month, entry_date)
            from {{ ref("gl_detail") }}
            where gl_detail.journal_title ilike any (
                    '%1009 - Citi Bank CC Allocation%',
                    '%1009 - Citi Bank Allocation%',
                    '%Fuel CC allocation%',
                    '%1009 - AMEX Corp CC Allocation%'
                )
        )
        and corporate_account_name != 'EQS EMPLOYEE REWARDS' -- Exclude EQS Employee Rewards transactions
),

company_directory as (
    select
        employee_id,
        first_name,
        last_name,
        market_id,
        employee_title,
        date_trunc(month, _es_update_timestamp)::date as join_date
    from {{ ref("stg_analytics_payroll__company_directory_vault") }}
    qualify
        row_number()
            over (
                partition by employee_id, date_trunc(month, _es_update_timestamp)
                order by _es_update_timestamp desc
            )
        = 1

),

market_allocation as (
    select * from {{ ref("int_live_branch_earnings_market_allocation") }}
),

mcc as (
    select *
    from {{ ref("stg_analytics_gs__mcc") }}
),

output as (
    select
        company_directory.market_id,
        case
            when cc_and_fuel.card_type = 'fuel_card'
                -- Use previous employees account else default to Delivery Fuel Exp. Vishesh 2024/06/12
                then coalesce(employee_to_account.account_number, '6015')
            else coalesce(mcc.account_number, '7409')::varchar
        end as account_number,
        'Credit Card Transaction ID' as transaction_number_format,
        cc_and_fuel.transaction_id as transaction_number,
        'Transaction ID: '
        || cc_and_fuel.transaction_id
        || ' | Employee Name: '
        || company_directory.first_name
        || ' '
        || company_directory.last_name
        || ' | Merchant: '
        || cc_and_fuel.merchant_name as description,
        cc_and_fuel.transaction_date as gl_date,
        'Credit Card Transaction ID' as document_type,
        cc_and_fuel.transaction_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        round(
            coalesce(market_allocation.allocation_pct, 1)
            * transaction_amount
            * -1,
            2
        ) as amount,
        object_construct(
            'credit_card_transaction_id', cc_and_fuel.transaction_id,
            'employee_id', company_directory.employee_id
        ) as additional_data,
        'ES_WAREHOUSE' as source,
        'Credit Card' as load_section,
        '{{ this.name }}' as source_model
    from cc_and_fuel
        inner join
            company_directory
            on cc_and_fuel.employee_number = company_directory.employee_id
                and date_trunc(month, cc_and_fuel.transaction_date)::date
                = company_directory.join_date
                and company_directory.employee_title not ilike '%telematics%'
        left join
            market_allocation
            on company_directory.market_id = market_allocation.department_id
                and date_trunc(month, cc_and_fuel.transaction_date)::date
                = market_allocation.gl_date
        left join mcc
            on cc_and_fuel.mcc_code::varchar = mcc.mcc_code::varchar
        left join employee_to_account
            on company_directory.employee_id = employee_to_account.employee_number
)

select * from output
