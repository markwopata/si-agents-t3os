select distinct
    md5(
        concat(
            market_id,
            '-',
            account_number,
            '-',
            gl_date,
            '-',
            coalesce(description, ''),
            '-',
            coalesce(transaction_number, ''),
            '-',
            coalesce(amount, 0)
        )
    ) as pk_id,
    region,
    region_name,
    district,
    market_type,
    market_id,
    market_name,
    revenue_expense,
    segment,
    fk_account_category_id as account_category_id,
    account_category,
    category_sort_order,
    account_number,
    account_name,
    gl_date,
    gl_month::date as gl_month,
    filter_month,
    is_payroll_expense,
    is_overtime_wage,
    is_paid_delivery_revenue,
    is_delivery_expense_account,
    is_commission_expense,
    additional_data,
    description,
    transaction_number_format,
    transaction_number,
    source_model,
    case
        when url_admin is not null then url_admin
        when
            additional_data:credit_note_id is not null
            then 'https://admin.equipmentshare.com/#/home/transactions/credit-notes/' || additional_data:credit_note_id
        when
            additional_data:invoice_id is not null
            then 'https://admin.equipmentshare.com/#/home/transactions/invoices/' || additional_data:invoice_id
        when
            additional_data:asset_id is not null
            then 'https://admin.equipmentshare.com/#/home/assets/asset/' || additional_data:asset_id
        else url_admin
    end as url_admin,
    url_concur,
    url_sage,
    case
        when url_t3 is not null then url_t3
        when
            additional_data:asset_id is not null
            then 'https://app.estrack.com/#/assets/all/asset/' || additional_data:asset_id
        else url_t3
    end as url_t3,
    url_gitlab,
    market_greater_than_12_months,
    gl_month <= '{{ last_branch_earnings_published_date() }}' as admin_only_data,
    case when account_number = 'IBAB' then additional_data:original_equipment_cost else 0 end
        as original_equipment_cost,
    round(amount, 2) as amount,
    current_timestamp() as timestamp -- noqa: RF04
from {{ ref("int_live_branch_earnings_results") }}
where gl_month::date >= '{{ live_be_start_date() }}'
