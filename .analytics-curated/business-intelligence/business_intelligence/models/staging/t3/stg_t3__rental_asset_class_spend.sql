{{ config(
    materialized='table'
    , cluster_by=['company_id', 'invoice_date']
) }}

with asset_list_rental as (
        select
        po.company_id,
        rental_billing_cycle_strategy,
        r.start_date as rental_start_date,
        r.rental_type_id,
        rt.name as rental_type_name,
        coalesce(ea.asset_id, r.asset_id) as asset_id,
        coalesce(ea.rental_id, r.rental_id) as rental_id,
        coalesce(ea.start_date, r.start_date) as start_date,
        coalesce(ea.end_date, r.end_date) as end_date,
        case
            when
                bcp.rental_billing_cycle_strategy = 'twenty_eight_day_cycle'
                or bcp.rental_billing_cycle_strategy is null
                then
                    case
                        when
                            r.start_date::date >= current_date - 28
                            then dateadd(day, 28, r.start_date::date)
                        else
                            dateadd(
                                day,
                                datediff(day, r.start_date::date, current_date)
                                + (
                                    28
                                    - mod(
                                        datediff(
                                            day,
                                            r.start_date::date,
                                            current_date
                                        ),
                                        28
                                    )
                                ),
                                r.start_date::date
                            )
                    end
            when bcp.rental_billing_cycle_strategy = 'thirty_day_cycle'
                then
                    case
                        when
                            r.start_date::date >= current_date - 30
                            then dateadd(day, 30, r.start_date::date)
                        else
                            dateadd(
                                day,
                                datediff(day, r.start_date::date, current_date)
                                + (30 - mod(datediff(
                                    day,
                                    r.start_date::date, current_date
                                ), 30)), r.start_date::date
                            )
                    end
            when bcp.rental_billing_cycle_strategy = 'first_of_month'
                then dateadd(month, 1, date_trunc('month', current_date))
            when
                r.start_date::date >= current_date - 28
                then dateadd(day, 28, r.start_date::date)
            else dateadd(
                day, datediff(day, r.start_date::date, current_date)
                + (
                    28
                    - mod(datediff(day, r.start_date::date, current_date), 28)
                ),
                r.start_date::date
            )
        end as next_cycle_date,
        case
            when
                r.rental_status_id not in (1, 2, 3, 4, 5, 8)
                and r.end_date <= current_date
                then 'Off Rent'
            when
                datediff(day, current_date, next_cycle_date) between 0 and 7
                then 'Cycling This Week'
            when r.rental_status_id = 5 then 'On Rent'
            when r.rental_status_id = 4 then 'Reservation'
            else 'Unknown'
        end as status

    from {{ ref('platform', 'es_warehouse__public__orders') }} as o
    -- perf: pull in viewing user ID at join level for some sec_levels?
    -- perf: pull in viewing user ID at join level for some sec_levels?
    join
        {{ ref('platform', 'es_warehouse__public__users') }} as u
        on o.user_id = u.user_id
    left join
        {{ ref('platform', 'es_warehouse__public__rentals') }} as r
        on o.order_id = r.order_id
    left join
        {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} as ea
        on r.rental_id = ea.rental_id
    inner join
        {{ ref('platform', 'es_warehouse__public__rental_types') }} as rt
        on r.rental_type_id = rt.rental_type_id
    inner join
        {{ ref('platform', 'es_warehouse__public__purchase_orders') }} as po
        on o.purchase_order_id = po.purchase_order_id
    left join
        {{ ref('platform', 'es_warehouse__public__billing_company_preferences') }}
            as bcp
        on po.company_id = bcp.company_id
    left join
        {{ ref('platform', 'es_warehouse__public__assets') }} as a
        on ea.asset_id = a.asset_id
),

asset_line_items as (
    select
        invoice_id,
        rental_id,
        coalesce(asset_id, extended_data:delivery.asset_id::number) as asset_id,
        sum(coalesce(amount, 0) + coalesce(tax_amount, 0))
            as asset_line_item_total,
        sum(
            case when line_item_type_id = 8 then coalesce(amount, 0) else 0 end
        ) as rental_asset_line_item_total
    from
        analytics.public.v_line_items
    where
        coalesce(asset_id, extended_data:delivery.asset_id::number) is not null
        and amount != 0
    group by
        invoice_id,
        rental_id,
        coalesce(asset_id, extended_data:delivery.asset_id::number)
),

non_asset_line_items as (
    select
        invoice_id,
        sum(coalesce(amount, 0) + coalesce(tax_amount, 0))
            as non_asset_line_items,
        sum(
            case when line_item_type_id = 8 then coalesce(amount, 0) else 0 end
        ) as rental_non_asset_line_item_total
    from
        analytics.public.v_line_items
    where coalesce(asset_id, extended_data:delivery.asset_id::number) is null
    group by
        invoice_id,
        coalesce(asset_id, extended_data:delivery.asset_id::number)
),
asset_count_by_invoice as (
    select
        invoice_id,
        count(distinct asset_id) as distinct_assets
    from
        asset_line_items
    group by 1
    union
    select
        invoice_id,
        0 as distinct_assets
    from
        non_asset_line_items
    where invoice_id not in (select invoice_id from asset_line_items)
    group by 1
),
rental_filter_values as (
    select true as rental_rate_filter
    union all
    select false as rental_rate_filter
)
,
invoice_combine as (
    select
        ali.invoice_id,
        ali.rental_id,
        ali.asset_id,
        rf.rental_rate_filter,
        case
            when rf.rental_rate_filter
                then sum(coalesce(ali.rental_asset_line_item_total, 0)) +
                    coalesce(sum(nali.rental_non_asset_line_item_total) / nullif(sum(aci.distinct_assets), 0), 0)
            else sum(coalesce(ali.asset_line_item_total, 0)) +
                coalesce(sum(nali.non_asset_line_items) / nullif(sum(aci.distinct_assets), 0), 0)
        end as line_item_total
    from asset_line_items ali
    left join non_asset_line_items nali on ali.invoice_id = nali.invoice_id
    left join asset_count_by_invoice aci on ali.invoice_id = aci.invoice_id
    cross join rental_filter_values rf
    group by ali.invoice_id, ali.rental_id, ali.asset_id, rf.rental_rate_filter

    union

    select
        nali.invoice_id,
        null as rental_id,
        null as asset_id,
        rf.rental_rate_filter,
        case
            when rf.rental_rate_filter
                then sum(nali.rental_non_asset_line_item_total)
            else sum(nali.non_asset_line_items)
        end as line_item_total
    from non_asset_line_items nali
    left join asset_count_by_invoice aci on nali.invoice_id = aci.invoice_id
    cross join rental_filter_values rf
    where aci.distinct_assets = 0
    group by nali.invoice_id, rf.rental_rate_filter
)

select
    a.asset_id,
    a.custom_name,
    i.company_id,
    cm.name as vendor,
    po.name as purchase_order,
    l.nickname as jobsite,
    alr.status as rental_status,
    o.order_id,
    i.invoice_no,
    i.invoice_id,
    i.billing_approved_date::date as billing_approved_date,
    i.invoice_date::date as invoice_date,
    ic.line_item_total,
    ic.rental_rate_filter,
    coalesce (a.asset_class, 'No Class Assigned') as asset_class,
    concat(ou.first_name, ' ', ou.last_name) as ordered_by,
    listagg(distinct (a.custom_name), ', ') as asset_list
from invoice_combine as ic
inner join
    {{ ref('platform', 'es_warehouse__public__invoices') }} as i
    on ic.invoice_id = i.invoice_id
inner join
    {{ ref('platform', 'es_warehouse__public__orders') }} as o
    on i.order_id = o.order_id
left join {{ref('platform','es_warehouse__public__users')}} ou on ou.user_id = o.user_id
left join
    {{ ref('platform', 'es_warehouse__public__rentals') }} as r
    on ic.rental_id = r.rental_id
left join
    {{ ref('platform', 'es_warehouse__public__purchase_orders') }} as po
    on i.purchase_order_id = po.purchase_order_id
inner join
    {{ ref('platform', 'es_warehouse__public__users') }} as u
    on o.user_id = u.user_id
left join
    {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} as ea
    on
        r.rental_id = ea.rental_id
        and ea.asset_id = coalesce(ic.asset_id, r.asset_id)
left join
    {{ ref('platform', 'es_warehouse__public__assets') }} as a
    on ea.asset_id = a.asset_id
left join
    {{ ref('platform', 'es_warehouse__public__rental_location_assignments') }}
        as rla
    on r.rental_id = rla.rental_id and rla.end_date is null
-- with company id 
left join
    {{ ref('platform', 'es_warehouse__public__locations') }} as l
    on rla.location_id = l.location_id and po.company_id = l.company_id
left join
    {{ ref('platform', 'es_warehouse__public__markets') }} as m
    on o.market_id = m.market_id
left join
    {{ ref('platform', 'es_warehouse__public__companies') }} as cm
    on m.company_id = cm.company_id
left join asset_list_rental as alr on r.rental_id = alr.rental_id
where
     i.billing_approved is not null
    and (
        a.asset_id in (select asset_id from asset_list_rental)
        or r.rental_type_id != 4
    )
group by
    all
