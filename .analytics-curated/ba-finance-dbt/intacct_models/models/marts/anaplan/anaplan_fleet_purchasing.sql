with pos as (
    select
        dpo.purchase_order_type,
        dpo.purchase_order_id,
        dpoli.po_line_purchase_order_line_item_number as line_item_number,
        dpoli.po_line_key,
        coalesce(nullif(v.vendor_sage_id, 'N/A'), dc.company_key) as vendor_id,
        dc.company_name as vendor_name,
        dec.sub_category_name,
        dpoli.po_line_equipment_class as po_class,
        dpoli.po_line_equipment_make as po_make,
        assets.asset_description,
        dec.business_segment_name,
        dpoli.po_line_order_status,
        ddi.dt_date as invoice_date,
        dpoli.po_line_release_date as release_date,
        ddp.dt_date as current_promise_date,
        case when
                current_promise_date < current_date and current_promise_date != '0001-01-01'
                then last_day(dateadd(month, 1, current_date))
            else current_promise_date
        end as current_promise_date_adjusted,
        --logic for buckets of orders
        case when
                invoice_date != '0001-01-01'
                and dpoli.po_line_order_status in ('Shipped', 'Received')
                then 'Invoiced'
            when
                invoice_date = '0001-01-01' and release_date != '0001-01-01'
                and dpoli.po_line_order_status in ('Okay to Ship')
                then 'Released'
            when
                invoice_date = '0001-01-01' and release_date = '0001-01-01'
                and current_promise_date_adjusted != '0001-01-01'
                and dpoli.po_line_order_status in ('Ordered')
                then 'Promised'
            else 'Other - check'
        end as capex_status,
        dpoli.po_line_calculated_oec as oec,
        dpoli.po_line_quantity as qty,
        dpo.purchase_order_days_in_net_term as net_payment_terms,
        case
            when
                capex_status = 'Invoiced' then extract(year from (invoice_date + net_payment_terms))
            when capex_status = 'Released' then extract(year from (release_date + net_payment_terms + 28))
            when capex_status = 'Promised' then extract(year from (current_promise_date_adjusted + net_payment_terms))
            else 2200
        end as calc_payment_year,
        case
            when
                capex_status = 'Invoiced' then (invoice_date + net_payment_terms)
            when capex_status = 'Released' then (release_date + net_payment_terms + 28)
            when capex_status = 'Promised' then (current_promise_date_adjusted + net_payment_terms + 28)
            else '2200-1-1'
        end as calc_payment_date
    from
        {{ ref('stg_fleet_optimization_gold__fact_purchasing') }} as fp
        left join
            {{ ref('stg_fleet_optimization_gold__dim_equipment_classes_fleet_opt') }} as dec
            on fp.equipment_class_key = dec.equipment_class_key
        left join
            {{ ref('stg_fleet_optimization_gold__dim_assets_fleet_opt') }} as assets
            on fp.asset_key = assets.asset_key
        inner join
            {{ ref('stg_fleet_optimization_gold__dim_dates_fleet_opt') }} as ddi
            on fp.po_line_invoice_date_key = ddi.dt_key
        inner join
            {{ ref('stg_fleet_optimization_gold__dim_dates_fleet_opt') }} as ddp
            on fp.current_promise_date_key = ddp.dt_key
        inner join {{ ref('stg_fleet_optimization_gold__dim_vendors') }} as v
            on fp.vendor_key = v.vendor_key
        inner join
            {{ ref('stg_fleet_optimization_gold__dim_purchase_order_line_items') }} as dpoli
            on fp.po_line_key = dpoli.po_line_key
        inner join
            {{ ref('stg_fleet_optimization_gold__dim_purchase_orders') }} as dpo
            on fp.purchase_order_key = dpo.purchase_order_key
        left join {{ ref('stg_fleet_optimization_gold__dim_companies_fleet_opt') }} as dc
            on v.vendor_company_key = dc.company_key
    where
        1 = 1
        and dpo.purchase_order_note_indicates_void_or_delete = false
        and dpoli.po_line_order_status not in ('Cancelled', 'Returned')
        and dpoli.po_line_is_likely_to_be_cancelled = false
),

union_group as (
    select
        purchase_order_type,
        purchase_order_id,
        line_item_number,
        po_line_key,
        vendor_id,
        vendor_name,
        asset_description,
        po_class,
        po_make,
        sub_category_name,
        business_segment_name,
        po_line_order_status,
        invoice_date as date, -- noqa: RF04
        capex_status,
        oec,
        qty,
        date_trunc('month', date) as month_date,
        net_payment_terms,
        calc_payment_year
    from pos
    where capex_status = 'Invoiced'

    union all

    select
        purchase_order_type,
        purchase_order_id,
        line_item_number,
        po_line_key,
        vendor_id,
        vendor_name,
        asset_description,
        po_class,
        po_make,
        sub_category_name,
        business_segment_name,
        po_line_order_status,
        release_date,
        capex_status,
        oec,
        qty,
        date_trunc('month', release_date) as month_date,
        net_payment_terms,
        calc_payment_year
    from pos
    where capex_status = 'Released'

    union all

    select
        purchase_order_type,
        purchase_order_id,
        line_item_number,
        po_line_key,
        vendor_id,
        vendor_name,
        asset_description,
        po_class,
        po_make,
        sub_category_name,
        business_segment_name,
        po_line_order_status,
        current_promise_date_adjusted,
        capex_status,
        oec,
        qty,
        date_trunc('month', current_promise_date_adjusted) as month_date,
        net_payment_terms,
        calc_payment_year
    from pos
    where capex_status = 'Promised'

    union all


    select
        purchase_order_type,
        purchase_order_id,
        line_item_number,
        po_line_key,
        vendor_id,
        vendor_name,
        asset_description,
        po_class,
        po_make,
        sub_category_name,
        business_segment_name,
        po_line_order_status,
        case when
                greatest(invoice_date, release_date, current_promise_date_adjusted) in ('2100-12-31', '0001-01-01') then null
            else greatest(invoice_date, release_date, current_promise_date_adjusted)
        end as date, -- noqa: RF04
        capex_status,
        oec,
        qty,
        case when
                date_trunc('month', greatest(invoice_date, release_date, current_promise_date_adjusted)) in ('2100-12-01','0001-01-01')
                then null
            else date_trunc('month', greatest(invoice_date, release_date, current_promise_date_adjusted))
        end as month_date,
        net_payment_terms,
        calc_payment_year
    from pos
    where capex_status = 'Other - check'
)

select *
from union_group
where calc_payment_year >= '2025'
--and date between '2025-07-01' and '2025-07-31'
    and oec > 0
--and po_class not ilike '%truck%'
