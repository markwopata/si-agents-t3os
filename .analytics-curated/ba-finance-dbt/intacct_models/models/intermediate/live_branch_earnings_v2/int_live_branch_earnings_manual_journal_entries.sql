select
    gl_detail.market_id,
    gl_detail.account_number,
    'GL Entry Record Number' as transaction_number_format,
    gl_detail.fk_gl_entry_id::varchar as transaction_number,
    gl_detail.journal_title as description,
    gl_detail.entry_date::date as gl_date,
    'Journal Transaction Number' as document_type,
    gl_detail.journal_transaction_number::varchar as document_number,
    gl_detail.url_journal as url_sage,
    null as url_concur,
    null as url_admin,
    null as url_t3,
    gl_detail.amount,
    object_construct(
        'journal_id', gl_detail.fk_journal_id,
        'journal_transaction_number', gl_detail.journal_transaction_number,
        'journal_title', gl_detail.journal_title
    ) as additional_data,
    'Analytics.Intacct' as source,
    'Manual Intacct Journal Entries' as load_section,
    '{{ this.name }}' as source_model
from {{ ref("gl_detail") }} as gl_detail
    left outer join {{ ref("stg_analytics_intacct__user") }} as u
        on gl_detail.fk_created_by_user_id = u.pk_user_id
where
    gl_detail.market_id in ({{ non_corporate_branch_list() }})
    and gl_detail.account_number not in
    (
        '7500', {# Other Insurance estimated from last month #}
        '6101' {# Pulling discounts and rebates from the retail sales app data #}
    )
    and {{ live_branch_earnings_date_filter(date_field='gl_detail.entry_date', timezone_conversion=false) }}
    and gl_detail.journal_transaction_number not in ({{ dropped_branch_earnings_journal_entries() }})
    and gl_detail.intacct_module not in ('3.AP', '4.AR', '9.PO')
    and not
    (
        gl_detail.journal_type = 'GJ'
        and gl_detail.journal_transaction_number in ({{ dropped_branch_earnings_journal_entries() }})
    )
    and u.username != 'APA_TRUE_UP'
    and gl_detail.journal_title not ilike '%entry to record rental% revenue accrual%'
    and gl_detail.journal_title not ilike '%1015%revenue accrual%'
    and gl_detail.journal_title not ilike '%1015 - unbilled revenue/deferred revenue accruals%'
    and gl_detail.journal_title not ilike '%1016 - % m2m capitalization%'
    and gl_detail.journal_title not ilike '%1241 - %m2m expense reclass%'
    and gl_detail.journal_title not ilike '1248 - %telematics%'
    and gl_detail.journal_title not ilike 'reversed - 1248 - %telematics%'
    and gl_detail.journal_title not ilike '%1248 - reclass telematics rental revenue%'
    and gl_detail.journal_title
    not ilike '%1275 - entry to reclassify external service expense to new account for better p&l reporting%'
    and gl_detail.journal_title not ilike '%2002 - re-rent estimate for assets with first rental but not in as4k/paid%'
    and gl_detail.journal_title not ilike '%telematics revenue reclass%'
    and gl_detail.journal_title
    not ilike '%1275 - Entry to reclassify external service expense to new account for better P&L reporting%'
    and gl_detail.journal_title not ilike '%profit%sharing%'
    and (gl_detail.account_number = '5501' or gl_detail.account_name not ilike '%COMMISSION%')
    and gl_detail.journal_title not ilike '%re-rent estimate for assets%'
    and gl_detail.journal_title not ilike '%Contractor Payouts - Crockett%'
    and gl_detail.account_name not ilike '%PAYROLL%' -- excluded because it is in payroll
    and gl_detail.account_name not ilike '%COMMISSION%' -- excluded because it is in payroll
    and gl_detail.journal_title not ilike '%1018 - Stripe Credit Card Fee Allocation%'
    -- remove trade in, these are offset in the credits model
    and gl_detail.journal_title not ilike '%1243 - Reinstatements and Trade Ins%'
    -- Remove the depreciation as we are using previous month as an estimate
    and gl_detail.journal_title not ilike '%1211 - Depreciation Expense%'
    and gl_detail.account_number not in ('8102') -- Remove Other Depreciation (using previous month as an estimate)
    and gl_detail.journal_title not ilike '%Rental Delivery Revenue Deferral%'
    and gl_detail.journal_title not ilike '%APA Cleanup - Invoice review (phase I)%'
    and gl_detail.journal_title not ilike '1241 - Warranty Passthrough Adjustment Reclass'
    and gl_detail.journal_title not ilike '%Reversal - 1241 - Warranty Passthrough Adjustment Reclass%'
