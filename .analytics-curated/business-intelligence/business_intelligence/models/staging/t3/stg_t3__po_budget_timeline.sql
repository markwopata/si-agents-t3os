with generate_series as (
  {{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2021-01-01' as timestamp)",
    end_date="cast(current_timestamp as timestamp)"
  ) }}
),
asset_line_items as (
  select
        invoice_id,
        rental_id,
        asset_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as asset_line_item_total,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_asset_line_item_total
  from {{ ref('int_t3__line_items_base') }}
  where asset_id is not null and asset_id != -1 and amount != 0
  group by invoice_id, rental_id, asset_id
),
non_asset_line_items as (
    select
        invoice_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as non_asset_line_items,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_non_asset_line_item_total
    from {{ ref('int_t3__line_items_base') }}
    where asset_id is null or asset_id = -1
    group by invoice_id
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
    left join non_asset_line_items nali on nali.invoice_id = ali.invoice_id
    left join asset_count_by_invoice aci on aci.invoice_id = ali.invoice_id
    group by ali.invoice_id, ali.rental_id, ali.asset_id
    union
    select
        nali.invoice_id,
        null as rental_id,
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
    left join non_asset_line_items nali on nali.invoice_id = ali.invoice_id
    left join asset_count_by_invoice aci on aci.invoice_id = ali.invoice_id
    group by ali.invoice_id, ali.rental_id, ali.asset_id
    union
    select
        nali.invoice_id,
        null as rental_id,
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
budget_by_total_invoice as (
select 
    ic.invoice_id,
    ic.rental_id,
    ic.asset_id,
    ic.rental_rate_filter,
    fli.rental_status_id,
    rs.name as rental_status,
    fli.rental_end_date,
    fli.rental_start_date,
    fli.purchase_order_name as po_name,
    fli.purchase_order_id,
    dl.location_nickname as jobsite,
    fli.invoice_no,
    coalesce(ea_asset.asset_custom_name, fli.asset_custom_name) as custom_name,
    coalesce(ea_asset.asset_equipment_class_name, fli.asset_equipment_class_name) as asset_class,
    fli.vendor,
    fli.order_id,
    fli.invoice_date::date as invoice_date,
    fli.billing_approved_date,
    coalesce(dlc.company_id, po.purchase_order_company_id) as company_id,
    fli.ordered_by,
    du_invoice.user_company_id,

    coalesce(po.purchase_order_budget_amount, 0) as budget_amount,
    po.purchase_order_start_date,
    po.purchase_order_end_date,
    sum(ic.line_item_total) as total_billed_amount
from invoice_combine as ic

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

left join {{ ref('platform', 'rental_location_assignments') }} rla 
    on rla.rental_id = fli.rental_id 
    and rla.end_date is null
left join {{ ref('platform', 'dim_locations') }} dl on dl.location_id = rla.location_id
left join {{ ref('platform', 'dim_companies') }} dlc 
    on dl.location_company_key = dlc.company_key
    and dlc.company_id = po.purchase_order_company_id

left join {{ ref('platform', 'rentals') }} r on r.rental_id = ic.rental_id

left join {{ ref('platform', 'equipment_assignments') }} ea 
    on ea.rental_id = r.rental_id 
    and ea.asset_id = coalesce(ic.asset_id, r.asset_id)
left join {{ ref('platform', 'dim_assets') }} ea_asset 
    on ea_asset.asset_id = ea.asset_id

left join {{ ref('platform', 'rental_statuses') }} rs on rs.rental_status_id = fli.rental_status_id
where fli.billing_approved_date >= po.purchase_order_start_date
and fli.invoice_billing_approved is not null
and po.purchase_order_active = true 
and (ea_asset.asset_id is not null or  dlc.company_id is not null)
group by all
),

po_per_date as (
  select
    ds.date_day::date as generated_date,
    po.po_name,
    po.company_id,
    po.user_company_id,
    po.rental_rate_filter,
    po.budget_amount
  from generate_series as ds
  cross join (

    select 
      bti.po_name, 
      bti.company_id, 
      bti.user_company_id, 
      bti.rental_rate_filter, 
      sum(distinct bti.budget_amount) as budget_amount,
      min(bti.purchase_order_start_date) as po_start_date,
      max(bti.purchase_order_end_date) as po_end_date,
      max(bti.billing_approved_date::date) as latest_billing_date
    from budget_by_total_invoice bti
    group by bti.po_name, bti.company_id, bti.user_company_id, bti.rental_rate_filter
  ) po
  where ds.date_day >= po.po_start_date
    and (

      po.po_end_date is null 
      or po.po_end_date = '0001-01-01'::date 
      or ds.date_day <= greatest(
        po.po_end_date, 
        coalesce(po.latest_billing_date, po.po_end_date)
      )
    )
),

invoice_info as (
  select
    billing_approved_date::date as billing_approved_date,
    po_name,
    total_billed_amount,
    rental_id,
    asset_id,
    rental_rate_filter,
    rental_status_id,
    rental_status,
    rental_end_date,
    rental_start_date,
    purchase_order_id,
    jobsite,
    invoice_no,
    custom_name,
    asset_class,
    vendor,
    order_id,
    invoice_date,
    invoice_id,
    company_id,
    ordered_by,
    user_company_id,
    coalesce(budget_amount,0) as budget_amount,
    sum(total_billed_amount) over (partition by po_name, company_id, user_company_id, rental_rate_filter order by po_name, billing_approved_date rows between unbounded preceding and current row) as cumulative_amount,
  from budget_by_total_invoice
),

joined_series as (
  select
    ppd.generated_date,
    ppd.po_name,
    ppd.company_id,
    ppd.user_company_id,
    ppd.rental_rate_filter,
    ppd.budget_amount,
    coalesce(sum(ii.total_billed_amount),0) as total_billed_on_day
  from po_per_date ppd
  left join invoice_info ii
    on ii.po_name = ppd.po_name
    and (ii.company_id = ppd.company_id or (ii.company_id is null and ppd.company_id is null))
    and (ii.user_company_id = ppd.user_company_id or (ii.user_company_id is null and ppd.user_company_id is null))
    and ii.billing_approved_date = ppd.generated_date
    and ii.rental_rate_filter = ppd.rental_rate_filter
  group by
    ppd.generated_date,
    ppd.po_name,
    ppd.company_id,
    ppd.user_company_id,
    ppd.rental_rate_filter,
    ppd.budget_amount
),
running_budget as (
select
  *,
  sum(coalesce(total_billed_on_day, 0)) over (
    partition by po_name, company_id, user_company_id, rental_rate_filter
    order by generated_date
    rows between unbounded preceding and current row
  ) as cumulative_amount, 
  budget_amount - cumulative_amount as remaining_budget
from joined_series
),
final as (
select 
rb.generated_date, 
rb.po_name,
rb.company_id,
rb.user_company_id,
rb.rental_rate_filter,
ii.vendor,
ii.rental_status,
ii.purchase_order_id,
ii.jobsite,
ii.asset_class,
ii.asset_id,
ii.custom_name,
ii.order_id,
ii.ordered_by,
ii.billing_approved_date,
ii.total_billed_amount,
rb.budget_amount,
rb.cumulative_amount, 
rb.remaining_budget
from 
running_budget rb
left join invoice_info ii
  on rb.po_name = ii.po_name
  and (rb.company_id = ii.company_id or (rb.company_id is null and ii.company_id is null))
  and (rb.user_company_id = ii.user_company_id or (rb.user_company_id is null and ii.user_company_id is null))
  and rb.rental_rate_filter = ii.rental_rate_filter
  and rb.generated_date = ii.billing_approved_date
)
select * from final