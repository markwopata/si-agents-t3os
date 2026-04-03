with credit_note_reasons as (
    select
        cnrx.credit_note_id,
        array_agg(cnrx.credit_note_request_reason_id)
        within group (order by cnrx.credit_note_request_reason_id) as reason_ids,
        array_agg(cnrr.description)
        within group (order by cnrx.credit_note_request_reason_id) as request_reasons,
        array_agg(cnrx.notes)
        within group (order by cnrx.credit_note_request_reason_id) as notes
    from {{ ref('stg_es_warehouse_public__credit_notes_reasons_xref') }} as cnrx
        inner join {{ ref('stg_es_warehouse_public__credit_note_request_reasons') }} as cnrr
            on cnrx.credit_note_request_reason_id = cnrr.credit_note_request_reason_id
    group by all
)

select
    cn.credit_note_id,
    cn.credit_note_number,
    cn.credit_note_type_id,
    cnt.credit_note_type_name,
    cn.credit_note_status_id,
    cns.credit_note_status_name,
    cnr.reason_ids,
    cnr.request_reasons,
    cnr.notes,
    -- Credit note date appears closer to booked gl_date than date_created, with only minor differences between
    -- date_created and credit_note_date otherwise.
    cn.credit_note_date as gl_date,
    cn.credit_note_date,
    cn.market_id,
    m.market_name,
    cn.company_id,
    c.customer_name,
    cn.memo as credit_note_memo,
    cn.reference as credit_note_reference,
    cnli.credit_note_line_item_id,
    ild.line_item_id,
    cnli.line_item_type_id,
    lit.line_item_type_name,
    cn.avalara_transaction_id,
    gla.account_number,
    gla.account_name,
    cnli.credit_amount,
    cnli.credit_tax_amount,
    cnli.amount as original_line_amount,
    cnli.tax_amount as original_line_tax_amount,
    cnli.taxable as is_taxable,
    cnli.description as line_item_description,
    cn.date_created as credit_note_date_created,
    cn.date_updated as credit_note_date_updated,
    cnli.date_created as credit_note_line_item_date_created,
    cnli.date_updated as credit_note_line_item_date_updated,
    cn.originating_invoice_id,
    cn.originating_invoice_id is not null as is_generated_from_invoice,
    ild.invoice_number,
    ild.billing_approved_date as invoice_billing_approved_date,
    ild.invoice_date,
    ild.invoice_memo,
    ild.asset_id,
    ild.rental_id,
    ild.invoice_cycle_start_date,
    ild.invoice_cycle_end_date,
    ild.rental_bill_type,
    ild.rental_cheapest_period_hour_count,
    ild.rental_cheapest_period_day_count,
    ild.rental_cheapest_period_week_count,
    ild.rental_cheapest_period_four_week_count,
    ild.rental_cheapest_period_month_count,
    ild.rental_price_per_hour,
    ild.rental_price_per_day,
    ild.rental_price_per_week,
    ild.rental_price_per_four_weeks,
    ild.rental_price_per_month,
    ec.company_id is not null as is_intercompany,
    cnli.branch_id as line_item_market_id, -- not sure what we do with this yet
    ild.primary_salesperson_id, -- Do not use the saleperson_user_id on invoices
    ild.secondary_salesperson_ids,
    cn.url_credit_note_admin,
    ild.url_admin as url_invoice_admin,
    cn.ship_to_branch_id,
    cn.ship_to_location_id,
    cn.ship_to_nickname,
    cn.ship_to_country,
    cn.ship_to_state,
    cn.ship_to_city,
    cn.ship_to_street,
    cn.ship_to_zip_code,
    cn.ship_to_longitude,
    cn.ship_to_latitude,
    cn.ship_from_branch_id,
    cn.ship_from_location_id,
    cn.ship_from_nickname,
    cn.ship_from_country,
    cn.ship_from_state,
    cn.ship_from_city,
    cn.ship_from_street,
    cn.ship_from_zip_code,
    cn.ship_from_longitude,
    cn.ship_from_latitude
from {{ ref('stg_es_warehouse_public__credit_notes') }} as cn
    inner join {{ ref('stg_es_warehouse_public__credit_note_types') }} as cnt
        on cn.credit_note_type_id = cnt.credit_note_type_id
    -- As of 2025-08-04, there is 1 credit note without a credit_note_status_id
    inner join {{ ref("stg_es_warehouse_public__credit_note_statuses") }} as cns
        on cn.credit_note_status_id = cns.credit_note_status_id
    inner join {{ ref('stg_es_warehouse_public__credit_note_line_items') }} as cnli
        on cn.credit_note_id = cnli.credit_note_id
    inner join {{ ref('stg_es_warehouse_public__line_item_types') }} as lit
        on cnli.line_item_type_id = lit.line_item_type_id
    -- left join because some line_item_types don't have erp_ref
    left join {{ ref('stg_es_warehouse_public__line_item_type_erp_refs') }} as liter
        on cnli.line_item_type_id = liter.line_item_type_id
    left join {{ ref('stg_analytics_intacct__gl_account') }} as gla
        on liter.intacct_gl_account_no = gla.account_number
    inner join {{ ref('stg_es_warehouse_public__companies') }} as c
        on cn.company_id = c.company_id
    left join {{ ref('stg_analytics_public__es_companies') }} as ec
        on cn.company_id = ec.company_id
            and ec.owned
    left join {{ ref('stg_es_warehouse_public__markets') }} as m
        on cn.market_id = m.market_id
    left join {{ ref('int_admin_invoice_line_detail') }} as ild
        on cnli.line_item_id = ild.line_item_id
    left join credit_note_reasons as cnr
        on cn.credit_note_id = cnr.credit_note_id
