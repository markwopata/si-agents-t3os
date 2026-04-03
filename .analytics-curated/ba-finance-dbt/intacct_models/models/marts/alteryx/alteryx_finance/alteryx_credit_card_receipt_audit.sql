with cost_center_base_paths as (
    select
        market_id,
        left(
            default_cost_centers_full_path,
            len(default_cost_centers_full_path) - charindex('/', reverse(default_cost_centers_full_path))
        ) as base_path
    from {{ ref('stg_analytics_payroll__cost_center_to_market_id') }}
    group by
        all
        
)

select

    -- grain
    p.purchase_id,
    t.ocr_data_raw,
    t.image_url,

    u.employee_id as cardholder_employee_id,
    concat(c.first_name, ' ', c.last_name) as cardholder_full_name,
    c.work_email as cardholder_email,
    cbp.base_path,
    c.employee_status as cardholder_employment_status,
    p.grand_total,
    t.transaction_merchant_name,
    p.market_id,
    p.notes,
    t.receipt_flag,
    t.receipt_confidence,
    t.evaluation_reasoning,
    t.handwritten_confidence,
    t.image_quality,
    t.upload_date AS ocr_upload_timestamp,
    t.image_evaluation,
    c.direct_manager_employee_id,
    regexp_substr(c.direct_manager_name, '^[^(]+') as direct_manager_name,
    cd.work_email as direct_manager_work_email,
    p.purchased_at,
    p.submitted_at,
    p.modified_at,
    tv.expense_line,
    tv.transaction_mcc_code,
    tv.transaction_mcc,
    tv.transaction_id
from {{ ref('stg_procurement_public__purchases') }} as p
inner join {{ ref('stg_analytics_credit_card__receipt_ocr_itemization_analysis') }} as t on p.purchase_id = t.purchase_id
left join {{ ref('transaction_verification') }} as tv on t.purchase_id = tv.upload_id
left join {{ ref('stg_es_warehouse_public__users') }} as u on p.user_id = u.user_id
left join {{ ref('stg_analytics_payroll__company_directory' )}} as c on u.employee_id = c.employee_id::varchar
left join {{ ref('stg_analytics_payroll__company_directory' )}} as cd on c.direct_manager_employee_id = cd.employee_id
left join cost_center_base_paths as cbp 
    on c.market_id = cbp.market_id 
    and left(c.default_cost_centers_full_path,len(c.default_cost_centers_full_path) - charindex('/', reverse(c.default_cost_centers_full_path))) = cbp.base_path
