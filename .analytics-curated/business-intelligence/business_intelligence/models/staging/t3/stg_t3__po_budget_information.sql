with asset_line_items as (
  select
        invoice_id,
        rental_id,
        asset_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as asset_line_item_total,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_asset_line_item_total
  from {{ ref('int_t3__line_items_base') }}
  where asset_id is not null
    and asset_id != -1
    and amount != 0
  group by invoice_id, rental_id, asset_id
),
non_asset_line_items as (
    select
        invoice_id,
        rental_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as non_asset_line_items,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_non_asset_line_item_total
    from {{ ref('int_t3__line_items_base') }}
    where asset_id is null or asset_id = -1
    group by invoice_id, rental_id
),
asset_count_by_invoice as (
    SELECT
        invoice_id,
        count(distinct asset_id) as distinct_assets
    FROM asset_line_items
    group by 1
    union
    SELECT
        invoice_id,
        0 as distinct_assets
    FROM non_asset_line_items
    where invoice_id not in (select invoice_id from asset_line_items)
    group by 1
),
invoice_combine_true as (
    select
        ali.invoice_id,
        ali.rental_id,
        ali.asset_id,
        'true' as rental_rate_filter,
        sum(coalesce(ali.rental_asset_line_item_total,0)) +
        coalesce(sum(nali.rental_non_asset_line_item_total)/nullif(sum(aci.distinct_assets), 0), 0) as line_item_total
    from asset_line_items ali
    left join non_asset_line_items nali on nali.invoice_id = ali.invoice_id and nali.rental_id = ali.rental_id
    left join asset_count_by_invoice aci on aci.invoice_id = ali.invoice_id
    group by ali.invoice_id, ali.rental_id, ali.asset_id
    union
    select
        nali.invoice_id,
        min(nali.rental_id) as rental_id,
        null as asset_id,
        'true' as rental_rate_filter,
        sum(nali.rental_non_asset_line_item_total) as line_item_total
    from non_asset_line_items nali
    left join asset_count_by_invoice aci on aci.invoice_id = nali.invoice_id
    where aci.distinct_assets = 0
    group by nali.invoice_id
),
invoice_combine_false as (
    select
        ali.invoice_id,
        ali.rental_id,
        ali.asset_id,
        'false' as rental_rate_filter,
        sum(coalesce(ali.asset_line_item_total,0)) +
        coalesce(sum(nali.non_asset_line_items)/nullif(sum(aci.distinct_assets), 0), 0) as line_item_total
    from asset_line_items ali
    left join non_asset_line_items nali on nali.invoice_id = ali.invoice_id and nali.rental_id = ali.rental_id
    left join asset_count_by_invoice aci on aci.invoice_id = ali.invoice_id
    group by ali.invoice_id, ali.rental_id, ali.asset_id
    union
    select
        nali.invoice_id,
        min(nali.rental_id) as rental_id,
        null as asset_id,
        'false' as rental_rate_filter,
        sum(nali.non_asset_line_items) as line_item_total
    from non_asset_line_items nali
    left join asset_count_by_invoice aci on aci.invoice_id = nali.invoice_id
    where aci.distinct_assets = 0
    group by nali.invoice_id
), 
invoice_combine as (
select * from invoice_combine_true
union all
select * from invoice_combine_false
),

rental_location_lookup as (
    select 
        rental_id,
        location_id
    from (
        select 
            rla.rental_id,
            rla.location_id,
            ROW_NUMBER() OVER (
                PARTITION BY rla.rental_id 
                ORDER BY rla.location_id
            ) as rn
        from {{ ref('platform', 'rental_location_assignments') }} rla
        where rla.end_date is null
    )
    where rn = 1
),
budget_invoice_combine as (
SELECT
        ic.invoice_id,
        ic.rental_id,
        ic.asset_id,
        ic.rental_rate_filter,
        sum(ic.line_item_total) as billed_amount,
        fli.purchase_order_name as po_name,
        fli.purchase_order_id,
        dl.location_nickname as jobsite,
        fli.invoice_no,
        fli.invoice_date::date as invoice_date,
        fli.asset_custom_name as custom_name,
        fli.asset_equipment_class_name as asset_class,
        fli.vendor,
        fli.order_id,
        coalesce(dlc.company_id, po.purchase_order_company_id) as company_id,
        du_invoice.user_company_id,
        fli.rental_status_id,
        fli.rental_start_date,
        fli.ordered_by,
        fli.rental_end_date
FROM invoice_combine ic

left join {{ ref('int_t3__line_items_base') }} fli 
    on fli.invoice_id = ic.invoice_id 
    and fli.rn = 1
    and (

        (ic.rental_id IS NULL AND ic.asset_id IS NULL AND (fli.asset_id IS NULL OR fli.asset_id = -1))  

        OR (fli.rental_id = ic.rental_id AND coalesce(fli.asset_id, -1) = coalesce(ic.asset_id, -1))  

        OR (ic.rental_id IS NOT NULL AND ic.asset_id IS NULL AND fli.rental_id = ic.rental_id AND (fli.asset_id IS NULL OR fli.asset_id = -1))
    )

JOIN  {{ ref('platform', 'dim_purchase_orders') }}  po ON po.purchase_order_id = fli.purchase_order_id
LEFT JOIN  {{ ref('platform', 'dim_users') }} du_invoice on fli.ordered_by_user_id = du_invoice.user_id

left join rental_location_lookup rla on rla.rental_id = fli.rental_id
left join  {{ ref('platform', 'dim_locations') }} dl on dl.location_id = rla.location_id
left join {{ ref('platform', 'dim_companies') }} dlc on dl.location_company_key = dlc.company_key 
    and dlc.company_id = po.purchase_order_company_id

left join {{ ref('platform', 'rentals') }} r on r.rental_id = fli.rental_id

left join {{ ref('platform', 'equipment_assignments') }} ea 
    on ea.rental_id = fli.rental_id 
    and ea.asset_id = coalesce(fli.asset_id, r.asset_id)
left join {{ ref('platform', 'dim_assets') }} ea_asset 
    on ea_asset.asset_id = ea.asset_id
left join {{ ref('platform', 'billing_company_preferences') }} bcp on bcp.company_id = po.purchase_order_company_id
where fli.billing_approved_date >= po.purchase_order_start_date

and fli.invoice_billing_approved = true
and po.purchase_order_active = true 
and (
    (ea_asset.asset_id is not null and ea_asset.asset_id != -1)
    or dlc.company_id is not null
    or du_invoice.user_company_id is not null
)
GROUP BY all
),
lifetime_budget_remaining as (
    select
        bic.purchase_order_id,
        bic.company_id,
        bic.rental_rate_filter,
        sum(bic.billed_amount) as lifetime_amount,
        max(po.purchase_order_budget_amount) as budget_amount,
        max(po.purchase_order_budget_amount) - sum(bic.billed_amount) as lifetime_budget_remaining
    from budget_invoice_combine bic
    join {{ ref('platform', 'dim_purchase_orders') }} po on po.purchase_order_id = bic.purchase_order_id
    where po.purchase_order_active = true
    group by bic.purchase_order_id, bic.company_id, bic.rental_rate_filter
),
rentals_per_po as (
SELECT
        poi.purchase_order_id,
        poi.purchase_order_name as po_name,
        poi.purchase_order_company_id as company_id,
        listagg(distinct a.asset_custom_name, ', ') as assets_on_po,
        count(distinct a.asset_custom_name) as asset_count
from {{ ref('platform', 'rentals') }}  r
left join {{ ref('platform', 'equipment_assignments') }}  ea on r.rental_id = ea.rental_id
left join {{ ref('platform', 'dim_assets') }} a on a.asset_id = ea.asset_id
left join {{ref('platform', 'orders')}} o on r.order_id = o.order_id
join {{ ref('platform', 'dim_purchase_orders') }} poi ON poi.purchase_order_id = o.purchase_order_id
    and poi.purchase_order_active = true
where (r.rental_status_id = 5) 
group by poi.purchase_order_id, poi.purchase_order_name, poi.purchase_order_company_id
)
select 
    bic.po_name,
    bic.purchase_order_id,
    bic.jobsite,
    bic.invoice_no,
    bic.invoice_date,
    bic.asset_id,
    bic.custom_name,
    bic.asset_class,
    bic.vendor,
    bic.order_id,
    bic.company_id,
    bic.user_company_id,
    bic.ordered_by,
    bic.rental_status_id,
    bic.rental_start_date,
    bic.rental_end_date,
    bic.rental_rate_filter,
    coalesce(rpo.assets_on_po, 'None') as assets_on_po,
    coalesce(rpo.asset_count, 0) as asset_count,
    sum(bic.billed_amount) as selected_date_range_spend,
    sum(bic.billed_amount) as lifetime_amount,
    lbr.lifetime_amount as lifetime_amount_2,
    lbr.budget_amount,
    lbr.lifetime_budget_remaining,
    coalesce(lbr.budget_amount - sum(bic.billed_amount), 0) as budget_remaining,
    case
        when lbr.budget_amount > 0 then lbr.lifetime_budget_remaining / nullif(lbr.budget_amount, 0)
        else 0
    end as pcnt_budget_remaining,
    case
        when coalesce(lbr.budget_amount, 0) = 0 then 'No Budget Set'
        when lbr.lifetime_budget_remaining > 0 then 'Within Budget'
        when lbr.lifetime_budget_remaining < 0 then 'Over Budget'
    end as budget_status
from budget_invoice_combine as bic 
left join lifetime_budget_remaining lbr 
    on lbr.purchase_order_id = bic.purchase_order_id
    and (lbr.company_id = bic.company_id or lbr.company_id = bic.user_company_id)
    and lbr.rental_rate_filter = bic.rental_rate_filter
left join rentals_per_po rpo
    on rpo.purchase_order_id = bic.purchase_order_id
    and (rpo.company_id = bic.company_id or rpo.company_id = bic.user_company_id)
group by all
