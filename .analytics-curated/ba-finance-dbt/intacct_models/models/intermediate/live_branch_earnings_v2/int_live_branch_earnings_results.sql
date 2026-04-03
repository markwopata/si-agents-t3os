with unioned_data as (
-- =================================================================================================
-- Revenue
-- Extracts revenue data from live branch earnings
-- =================================================================================================

    select *
    from {{ ref('int_live_branch_earnings_revenue') }}

    -- =================================================================================================
    -- Credits
    -- Pulls credit transactions from live branch earnings
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_credits') }}

    -- =================================================================================================
    -- Core Sales Cogs
    -- Captures cost of goods sold from core/fleet sales
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_sales_cogs_core') }}

    -- =================================================================================================
    -- Retail Sales Cogs
    -- Captures cost of goods sold from reatil/dealership sales
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_sales_cogs_retail') }}

    -- =================================================================================================
    -- Retail Sales Cogs Offsets
    -- Creates offsetting cost entries for any make-ready expenses associated with retail sales, to double-counting expenses
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_sales_cogs_retail_offsets') }}

    -- =================================================================================================
    -- Sales Cogs Credits
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_sales_cogs_credits') }}

    -- =================================================================================================
    -- Manual Intacct Journal Entries
    -- TODO: We are getting additional entries from several account numbers that should be excluded.
    -- TODO: Add tests for filtering out inappropriate journal entries.
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_manual_journal_entries') }}
    -- Prevents double counting of payroll entries
    where transaction_number not in (
            select transaction_number
            from {{ ref('int_live_branch_earnings_payroll_actuals') }}
            where date_trunc(month, gl_date) in ({{ be_live_payroll_switch() }})
        )

    -- =================================================================================================
    -- Bad Debt from Invoices
    -- Handles bad debt specifically arising from invoices
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_bad_debt_from_invoices') }}

    -- =================================================================================================
    -- Bad Debt from General Ledger
    -- Handles bad debt adjustments directly from the GL
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_bad_debt_write_offs') }}

    -- =================================================================================================
    -- Property Tax
    -- Captures property tax entries from live branch earnings
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_property_tax') }}

    -- =================================================================================================
    -- Accounts Payable
    -- Summarizes all accounts payable entries
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_ap') }}

    -- =================================================================================================
    -- Repeating Entries - Prior Month
    -- Captures repeating journal entries from the prior month
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_repeating_entries') }}

    -- =================================================================================================
    -- Health Insurance
    -- Details health insurance expenses from branch earnings
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_health_insurance') }}

    -- =================================================================================================
    -- Worker's Comp Insurance
    -- Summarizes worker's compensation insurance costs
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_worker_comp') }}

    -- =================================================================================================
    -- Auto Premium Recovery
    -- Accounts for recovery of auto insurance premiums
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_auto_premium') }}

    -- =================================================================================================
    -- Part Transactions
    -- Pulls all part transaction data
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_part_transactions') }}

    -- =================================================================================================
    -- Payroll Estimates
    -- Provides estimates of payroll costs from branch earnings
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_payroll_estimate') }}
    where date_trunc(month, gl_date) not in ({{ be_live_payroll_switch() }})

    union all

    select *
    from {{ ref('int_live_branch_earnings_payroll_actuals') }}
    where date_trunc(month, gl_date) in ({{ be_live_payroll_switch() }})

    -- =================================================================================================
    -- Intercompany Hard Down
    -- Details transactions considered as hard down between companies
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_intercompany_hard_down') }}

    -- =================================================================================================
    -- Equipment Charge (amortization)
    -- Uses Original Equipment Cost to calculate "equipment charge".
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_equipment_charge') }}

    -- =================================================================================================
    -- Lost, Stolen, and Destroyed Equipment
    -- This is only be LSD assets that don't have an invoice associated with them (they are taken care of in sales cogs)
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_lost_stolen_destroyed') }}

    -- =================================================================================================
    -- Credit Card Transactions / Allocations
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_credit_card_transactions') }}

    -- =================================================================================================
    -- Credit Card Fees (Avg. of last 3 months)
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_credit_card_fees') }}

    -- =================================================================================================
    -- Depreciation Non-Asset
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_other_depreciation') }}

    -- =================================================================================================
    --  Other Insurance
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_other_insurance') }}

    -- =================================================================================================
    --  New Machine Parts and Labor Capitalization
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_machine_make_ready') }}

    -- =================================================================================================
    -- Corporate Allocation
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_live_branch_earnings_corporate_allocation') }}

    -- =================================================================================================
    -- Asset Repair Capitalization - Expense Reversal
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_major_asset_repair_expense_reversal_trending') }}

    -- =================================================================================================
    -- Asset Repair Capitalization - Monthly Capitalization
    -- =================================================================================================

    union all

    select *
    from {{ ref('int_major_asset_repair_monthly_capitalization_trending') }}

),

combined_data as (

    select
        market.market_id,
        market.child_market_id,
        unioned_data.account_number,
        unioned_data.transaction_number_format,
        unioned_data.transaction_number,
        unioned_data.description,
        unioned_data.gl_date,
        unioned_data.url_sage,
        unioned_data.url_concur,
        unioned_data.url_admin,
        unioned_data.url_t3,
        case
            when unioned_data.load_section in (
                    'Asset Repair Expense Reversal Trending',
                    'Equipment Repair Capitalization'
                )
                then
                    'https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/tree/main/intacct_models/models/intermediate/service/'
                    || unioned_data.source_model
                    || '.sql'
            else
                'https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/models/intermediate/live_branch_earnings_v2/'
                || unioned_data.source_model
                || '.sql'
        end as url_gitlab,
        round(unioned_data.amount, 2) as amount,
        unioned_data.additional_data,
        unioned_data.source,
        unioned_data.load_section,
        unioned_data.source_model
    from unioned_data
        inner join {{ ref("int_live_branch_earnings_account_mapping") }} as account_mapping
            on unioned_data.account_number = account_mapping.account_number
        inner join {{ ref("market") }} as market
            on unioned_data.market_id = market.child_market_id
    where account_mapping.is_branch_earnings_account = true
        and unioned_data.gl_date between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'

-- =================================================================================================
-- Profit Sharing
-- =================================================================================================

),

market as (
    select *
    from {{ ref("market") }}
),

profit_sharing as (
    select
        combined_data.market_id,
        combined_data.market_id as child_market_id,
        '7700' as account_number,
        'Market ID | GL Date' as transaction_number_format,
        combined_data.market_id || '|' || date_trunc(month, combined_data.gl_date)::varchar as transaction_number,
        'Estimated Profit Sharing Accrual' as description,
        date_trunc(month, combined_data.gl_date) as gl_date,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        null as url_gitlab,
        round(sum(combined_data.amount) * -0.065, 2) as amount,
        object_construct() as additional_data,
        'ANALYTICS' as source,
        'Profit Sharing' as load_section,
        '{{ this.name }}' as source_model
    from combined_data
        inner join market
            on combined_data.child_market_id = market.child_market_id
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15
    having sum(amount) > 0
),

-- =================================================================================================
-- Combine all data
-- =================================================================================================
results as (
    select * from combined_data

    union all

    select * from profit_sharing
),

account_mapping as (
    select *
    from {{ ref("int_live_branch_earnings_account_mapping") }}
),

output as (
    select
        results.*,
        date_trunc(month, results.gl_date) as gl_month,
        to_char(to_date(results.gl_date), 'MMMM YYYY') as filter_month,
        account_mapping.* exclude (account_number),
        market.* exclude (market_id, child_market_id),
        coalesce(
            datediff(
                month, date_trunc(month, market.branch_earnings_start_month::date), date_trunc(month, results.gl_date)
            ),
            0
        ) + 1 as market_age_in_months,
        (market_age_in_months > 12) as market_greater_than_12_months
    from
        results
        inner join account_mapping
            on results.account_number = account_mapping.account_number
        inner join market
            on results.child_market_id = market.child_market_id
)

select *
from output
