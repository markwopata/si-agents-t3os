select
    roif.line_idx,
    roif.upload_date as ocr_upload_timestamp,
    p.account_type,
    tv.employee_id as cardholder_employee_id,
    cd.full_name as cardholder_full_name,
    cd.work_email as cardholder_email,
    cd.default_cost_centers_full_path,
    cd.employee_status as cardholder_employment_status,
    p.purchase_id,
    roif.amount as line_item_amount,
    p.grand_total as transaction_total,
    tv.transaction_merchant_name,
    p.market_id,
    p.notes,
    roif.item_text,
    roif.category,
    roif.fraud_flag,
    roif.fraud_confidence,
    roif.fraud_reasoning,
    roif.need_further_review,
    roif.line_notes,
    cd.direct_manager_employee_id,
    cd_man.full_name as direct_manager_name,
    cd_man.work_email as direct_manager_work_email,
    p.purchased_at,
    p.submitted_at,
    p.modified_at,
    roif.image_url,
    tv.expense_line,
    tv.transaction_mcc_code,
    tv.transaction_mcc,
    tv.transaction_id
from {{ ref('stg_procurement_public__purchases') }} as p
    inner join {{ ref('stg_analytics_credit_card__receipt_ocr_itemization_fraud') }} as roif
        on p.purchase_id = roif.purchase_id
    left join {{ ref('transaction_verification') }} as tv
        on roif.purchase_id = tv.upload_id
    left join {{ ref('stg_analytics_payroll__company_directory' ) }} as cd
        on tv.employee_id = cd.employee_id
    left join {{ ref('stg_analytics_payroll__company_directory' ) }} as cd_man
        on cd.direct_manager_employee_id = cd_man.employee_id
