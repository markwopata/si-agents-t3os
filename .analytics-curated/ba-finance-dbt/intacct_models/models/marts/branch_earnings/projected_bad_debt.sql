select
    dateadd(day, -1, dateadd(month, 10, date_trunc(month, i.invoice_date)))
        as expected_bad_debt_date,
    to_varchar(expected_bad_debt_date, 'MMMM yyyy') as expected_bad_debt_month,
    i.ship_from:branch_id::int as market_id,
    i.billing_approved_date::date as billing_approved_date,
    i.paid_date,
    i.invoice_id,
    i.invoice_no as invoice_number,
    c.customer_name,
    concat(su.last_name, ', ', su.first_name) as salesperson,
    -- exclude warranty line items 22, 23 (parts and labor revenue)
    round(greatest(i.owed_amount - sum(iff(li.line_item_type_id in (22,23), li.amount, 0)), 0), 2) as amount,
    coalesce(bcp.prefs:legal_audit, false) as legal_audit_flag
from {{ ref("stg_es_warehouse_public__orders") }} as o
    inner join {{ ref("stg_es_warehouse_public__invoices") }} as i
        on o.order_id = i.order_id
    inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
        on i.invoice_id = li.invoice_id
    inner join {{ ref("stg_es_warehouse_public__users") }} as u
        on o.user_id = u.user_id
    left join {{ ref("stg_es_warehouse_public__users") }} as su
        on i.salesperson_user_id = su.user_id
    inner join {{ ref("stg_es_warehouse_public__companies") }} as c
        on u.company_id = c.company_id
    left join {{ ref('stg_analytics_public__es_companies') }} as ec
        on c.company_id = ec.company_id
    left join {{ ref("stg_es_warehouse_public__billing_company_preferences") }} as bcp
        on i.company_id = bcp.company_id
where
    1 = 1
    and c.company_id not in (
        6954, -- EZ Equipment Zone
        55524 -- Premiere Industrial Equipment LLC
    -- Exclude these companies - low branch control on when these get paid
    )
    -- Don't show any intercompany invoices
    and ec.company_id is null
    and i.owed_amount != 0
    and i.line_item_amount != 0
    and i.billing_approved
    
group by
    dateadd(day, -1, dateadd(month, 10, date_trunc(month, i.invoice_date))),
    to_varchar(expected_bad_debt_date, 'MMMM yyyy'),
    i.ship_from:branch_id,
    i.billing_approved_date::date,
    i.paid_date,
    i.invoice_id,
    i.invoice_no,
    c.customer_name,
    concat(su.last_name, ', ', su.first_name),
    coalesce(bcp.prefs:legal_audit, false), i.line_item_amount, i.owed_amount
