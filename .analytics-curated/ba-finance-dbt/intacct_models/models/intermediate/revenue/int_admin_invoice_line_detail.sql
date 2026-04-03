select
    i.invoice_id,
    i.invoice_no as invoice_number,
    i.billing_approved_date,
    i.billing_approved_date as gl_date,
    i.billing_approved as is_billing_approved,
    i.is_deleted,
    i.is_pending,
    i.invoice_date,
    i.market_id,
    m.market_name,
    i.company_id,
    c.customer_name,
    i.invoice_memo,
    i.public_note,
    li.line_item_id,
    li.line_item_type_id,
    lit.line_item_type_name,
    i.avalara_transaction_id,
    gla.account_number,
    gla.account_name,
    li.amount,
    li.tax_amount,
    li.taxable as is_taxable,
    li.description as line_item_description,
    i.date_created as invoice_date_created,
    i.date_updated as invoice_date_updated,
    li.date_created as line_item_date_created,
    li.date_updated as line_item_date_updated,
    li.asset_id,
    li.rental_id,
    i.start_date as invoice_cycle_start_date,
    i.end_date as invoice_cycle_end_date,
    li.extended_data__rental__rental_bill_type as rental_bill_type,
    li.extended_data__rental__cheapest_period_hour_count as rental_cheapest_period_hour_count,
    li.extended_data__rental__cheapest_period_day_count as rental_cheapest_period_day_count,
    li.extended_data__rental__cheapest_period_week_count as rental_cheapest_period_week_count,
    li.extended_data__rental__cheapest_period_four_week_count as rental_cheapest_period_four_week_count,
    li.extended_data__rental__cheapest_period_month_count as rental_cheapest_period_month_count,
    li.extended_data__rental__price_per_hour as rental_price_per_hour,
    li.extended_data__rental__price_per_day as rental_price_per_day,
    li.extended_data__rental__price_per_week as rental_price_per_week,
    li.extended_data__rental__price_per_four_weeks as rental_price_per_four_weeks,
    li.extended_data__rental__price_per_month as rental_price_per_month,
    i.due_date,
    case when not i.is_paid then datediff('day', i.paid_date, current_date) else 0 end as days_past_due,
    i.paid_date,
    i.is_paid,
    ec.company_id is not null as is_intercompany,
    ais.primary_salesperson_id, -- Do not use the saleperson_user_id on invoices
    ais.secondary_salesperson_ids,
    i.order_id,
    i.sent as is_sent,
    li.part_id,
    li.part_number,
    li.number_of_units,
    li.price_per_unit,
    i.url_admin,
    i.ship_to__branch_id as ship_to_branch_id,
    i.ship_to__location_id as ship_to_location_id,
    i.ship_to__nickname as ship_to_nickname,
    i.ship_to__address__country as ship_to_country,
    i.ship_to__address__state_abbreviation as ship_to_state,
    i.ship_to__address__city as ship_to_city,
    i.ship_to__address__street_1 as ship_to_street,
    i.ship_to__address__zip_code as ship_to_zip_code,
    i.ship_to__address__longitude as ship_to_longitude,
    i.ship_to__address__latitude as ship_to_latitude,
    i.ship_from__branch_id as ship_from_branch_id,
    i.ship_from__location_id as ship_from_location_id,
    i.ship_from__nickname as ship_from_nickname,
    i.ship_from__address__country as ship_from_country,
    i.ship_from__address__state_abbreviation as ship_from_state,
    i.ship_from__address__city as ship_from_city,
    i.ship_from__address__street_1 as ship_from_street,
    i.ship_from__address__zip_code as ship_from_zip_code,
    i.ship_from__address__longitude as ship_from_longitude,
    i.ship_from__address__latitude as ship_from_latitude
from {{ ref('stg_es_warehouse_public__invoices') }} as i
    inner join {{ ref('stg_es_warehouse_public__line_items') }} as li
        on i.invoice_id = li.invoice_id
    inner join {{ ref('stg_es_warehouse_public__line_item_types') }} as lit
        on li.line_item_type_id = lit.line_item_type_id
        -- left join because some line_item_types don't have erp_ref
    left join {{ ref('stg_es_warehouse_public__line_item_type_erp_refs') }} as liter
        on li.line_item_type_id = liter.line_item_type_id
    left join {{ ref('stg_analytics_intacct__gl_account') }} as gla
        on liter.intacct_gl_account_no = gla.account_number
    inner join {{ ref('stg_es_warehouse_public__companies') }} as c
        on i.company_id = c.company_id
    left join {{ ref('stg_analytics_public__es_companies') }} as ec
        on i.company_id = ec.company_id
            and ec.owned
    left join {{ ref('stg_es_warehouse_public__markets') }} as m
        on i.market_id = m.market_id
    left join {{ ref("base_es_warehouse_public__approved_invoice_salespersons") }} as ais
        on i.invoice_id = ais.invoice_id
