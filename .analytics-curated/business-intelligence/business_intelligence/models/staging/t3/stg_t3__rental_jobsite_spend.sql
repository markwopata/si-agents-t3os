{{ config(
    materialized='table'
    , cluster_by=['company_id', 'invoice_date']
) }}

with asset_list_rental as (
   SELECT
      coalesce(ea.asset_id, r.asset_id) as asset_id,
      coalesce(ea.rental_id, r.rental_id) as rental_id,
      a.asset_class,
      po.company_id,
      a.custom_name,
      u.user_id,
      case
        when (rental_billing_cycle_strategy = 'twenty_eight_day_cycle' or rental_billing_cycle_strategy is null) then
          case when r.start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, r.start_date::date)
          else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 28))::int, r.start_date::date)
          end
        when rental_billing_cycle_strategy = 'thirty_day_cycle' then
          case when r.start_date::date >= current_timestamp::date - 30 THEN dateadd(day, 30, r.start_date::date)
          else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (30-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 30))::int, r.start_date::date) end
        when rental_billing_cycle_strategy = 'first_of_month' then
         dateadd(month, 1, date_trunc(month,current_date()))
        else
          case when r.start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, r.start_date::date)
          else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 28))::int, r.start_date::date)
          end
      end as next_cycle_date,
      case
        when datediff(day,current_timestamp(),next_cycle_date) <= 7 AND datediff(day,current_timestamp(),next_cycle_date) >= 0 then 'Cycling This Week'
        when r.rental_status_id = 5 then 'On Rent'
        when r.rental_status_id = 4 then 'Reservation'
        else 'Off Rent'
      end as status,
      r.rental_type_id,
      rt.name as rental_type_name,
      coalesce(ea.start_date, r.start_date) as start_date,
      coalesce(ea.end_date, r.end_date, '2099-01-01'::timestamp_tz) as end_date
    FROM {{ ref('platform', 'es_warehouse__public__orders') }} as o
    join {{ ref('platform', 'es_warehouse__public__users') }} as  u on u.user_id = o.user_id -- perf: pull in viewing user ID at join level for some sec_levels?
    left join {{ ref('platform', 'es_warehouse__public__rentals') }} r on r.order_id = o.order_id
    left join {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} ea on ea.rental_id = r.rental_id
    join {{ ref('platform', 'es_warehouse__public__rental_types') }} rt on rt.rental_type_id = r.rental_type_id
    join {{ ref('platform', 'es_warehouse__public__purchase_orders') }} po on po.purchase_order_id = o.purchase_order_id
    left join {{ ref('platform', 'es_warehouse__public__billing_company_preferences') }} bcp on bcp.company_id = po.company_id
    left join {{ ref('platform', 'es_warehouse__public__assets') }}  a on a.asset_id = ea.asset_id
),

asset_line_items as (
    select
        invoice_id,
        rental_id,
        coalesce(asset_id, extended_data:delivery.asset_id::number) as asset_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as asset_line_item_total,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_asset_line_item_total
    from
    ANALYTICS.PUBLIC.V_LINE_ITEMS
    where coalesce(asset_id, extended_data:delivery.asset_id::number) is not null
    and amount != 0
    group by
    invoice_id,
    rental_id,
    coalesce(asset_id, extended_data:delivery.asset_id::number)
),
 non_asset_line_items as (
    select
        invoice_id,
        sum(coalesce(amount,0) + coalesce(tax_amount,0)) as non_asset_line_items,
        sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_non_asset_line_item_total
    from
    ANALYTICS.PUBLIC.V_LINE_ITEMS
    where coalesce(asset_id, extended_data:delivery.asset_id::number) is null
    group by
    invoice_id,
    coalesce(asset_id, extended_data:delivery.asset_id::number)
),
asset_count_by_invoice as (
    SELECT
        invoice_id,
        count(distinct asset_id) as distinct_assets
    FROM
        asset_line_items
    group by 1
    union
    SELECT
        invoice_id,
        0 as distinct_assets
    FROM
        non_asset_line_items
    where invoice_id not in (select invoice_id from asset_line_items)
    group by 1
),
rental_filter_values as (
    select true as rental_rate_filter
    union all
    select false as rental_rate_filter
),
invoice_combine as (
    select
        ali.invoice_id,
        ali.rental_id,
        ali.asset_id,
        rfv.rental_rate_filter,
        case
            when rfv.rental_rate_filter = true then
                sum(coalesce(ali.rental_asset_line_item_total, 0)) +
                coalesce(sum(nali.rental_non_asset_line_item_total) / nullif(sum(aci.distinct_assets), 0), 0)
            else
                sum(coalesce(ali.asset_line_item_total, 0)) +
                coalesce(sum(nali.non_asset_line_items) / nullif(sum(aci.distinct_assets), 0), 0)
        end as line_item_total
    from asset_line_items ali
    left join non_asset_line_items nali on nali.invoice_id = ali.invoice_id
    left join asset_count_by_invoice aci on aci.invoice_id = ali.invoice_id
    cross join rental_filter_values rfv
    group by ali.invoice_id, ali.rental_id, ali.asset_id, rfv.rental_rate_filter
    union
    select
        nali.invoice_id,
        null as rental_id,
        null as asset_id,
        rfv.rental_rate_filter,
        case
            when rfv.rental_rate_filter = true then
                sum(nali.rental_non_asset_line_item_total)
            else
                sum(nali.non_asset_line_items)
        end as line_item_total
    from non_asset_line_items nali
    left join asset_count_by_invoice aci on aci.invoice_id = nali.invoice_id
    cross join rental_filter_values rfv
    where coalesce(aci.distinct_assets, 0) = 0
    group by nali.invoice_id, rfv.rental_rate_filter
)
select 
    a.asset_id,
    a.custom_name,
    -- filter options
    a.asset_class,
    i.company_id,
--    alr.rental_id,
--    alr.user_id,
    alr.status as rental_status ,
    ic.rental_rate_filter,
    -- original query 
    cm.name as vendor,
    po.name as purchase_order,
    l.nickname as jobsite,
    o.order_id,
    i.invoice_no,
    i.invoice_id,
    i.billing_approved_date::date as billing_approved_date,
    i.invoice_date::date as invoice_date,
    listagg(distinct(a.custom_name),', ') as asset_list,
    ic.line_item_total,
    concat(ou.first_name, ' ', ou.last_name) as ordered_by
from invoice_combine ic
join {{ref('platform', 'es_warehouse__public__invoices')}} i on i.invoice_id = ic.invoice_id
join {{ref('platform', 'es_warehouse__public__orders')}} o on o.order_id = i.order_id
left join {{ref('platform','es_warehouse__public__users')}} ou on ou.user_id = o.user_id
left join {{ref('platform', 'es_warehouse__public__rentals')}} r on r.rental_id = ic.rental_id
left JOIN {{ref('platform', 'es_warehouse__public__purchase_orders')}} po ON i.purchase_order_id = po.purchase_order_id
inner join {{ ref('platform', 'es_warehouse__public__users') }} as u on o.user_id = u.user_id
left join {{ref('platform', 'es_warehouse__public__equipment_assignments')}} ea on ea.rental_id = r.rental_id AND ea.asset_id = coalesce(ic.asset_id,r.asset_id)
left join {{ref('platform', 'es_warehouse__public__assets')}} a on a.asset_id = ea.asset_id
left join {{ref('platform', 'es_warehouse__public__rental_location_assignments')}} rla on rla.rental_id = r.rental_id AND rla.end_date is null
left join {{ref('platform', 'es_warehouse__public__locations')}} l
    on l.location_id = rla.location_id
    and l.company_id = po.company_id
left join {{ref('platform', 'es_warehouse__public__markets')}} m on m.market_id = o.market_id
left join {{ref('platform', 'es_warehouse__public__companies')}} cm on cm.company_id = m.company_id
left join asset_list_rental alr on alr.rental_id = r.rental_id
where
     i.billing_approved is not null
    and (
        a.asset_id in (select asset_id from asset_list_rental)
        or r.rental_type_id != 4
    )
group by
all


