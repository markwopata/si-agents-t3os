{{ config(
    materialized='table'
    , cluster_by=['company_id', 'rental_start_date']
) }}

with 
 orders_salesperson_breakdown AS (
SELECT DISTINCT
    order_id,
    MAX(CASE WHEN salesperson_type_id = 1 THEN user_id END) AS primary_salesperson_id,
    NULLIF(
        LISTAGG(CASE WHEN salesperson_type_id = 2 THEN user_id END, ',') ,
        ''
    ) AS secondary_salesperson_ids,
    SUM(CASE WHEN salesperson_type_id = 2 THEN 1 ELSE 0 END) as total_secondary_salespersons,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 1),'') AS secondary_salesperson_1,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 2),'') AS secondary_salesperson_2,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 3),'') AS secondary_salesperson_3
FROM es_warehouse.public.order_salespersons
GROUP BY order_id
)
, base_rentals as (
    select
        r.rental_id,
        r.rental_status_id,
        r.start_date,
        r.end_date,
        r.price_per_day,
        r.price_per_week,
        r.price_per_month,
        u.user_id as ordered_by_id,
        u.first_name,
        u.last_name,
        ea.asset_id,
        a.custom_name,
        a.asset_class,
        p.part_id,
        pt.description AS description,
        po.purchase_order_id,
        po.name AS purchase_order,
        dl.street_1,
        dl.street_2,
        dl.city,
        s.abbreviation AS abbreviation,
        dl.zip_code,
        bcp.rental_billing_cycle_strategy,
        u.company_id,
        l.nickname as jobsite,
        c.name as vendor, 
        o.order_id,
        o.sub_renter_id,
        cv.sub_renting_company,
        cv.sub_renting_contact,
        o.market_id,
        r.shift_type_id,
        osb.primary_salesperson_id,
        concat(ps.first_name,' ', ps.last_name) as primary_salesperson_name,
        osb.total_secondary_salespersons,
        osb.secondary_salesperson_1,
        concat(ss.first_name,' ', ss.last_name) as secondary_salesperson_name,
        pcr.parent_company_id,
        pc.name as parent_company_name,
        ---- FOR APIs ----
        NULL as latest_fuel_level,
        NULL as dashcam_events,
        NULL as approver_ueser_id,
        NULL as approver_first_last_name,
        NULL as primary_salesperson,
        NULL as secondary_salesperson,
        CASE
        WHEN DATEDIFF(day, r.start_date, r.end_date) > 365 THEN TRUE
        ELSE FALSE end as long_term_rental_flag,
        ---- FOR APIs ----
        ROW_NUMBER() OVER (PARTITION BY r.rental_id ORDER BY ea.end_date DESC) AS asset_assignment_rank
    from {{ ref('platform', 'es_warehouse__public__rentals') }} r 
    left join es_warehouse.public.orders o on r.order_id = o.order_id
    left join {{ref('platform', 'es_warehouse__public__markets')}} m on m.market_id = o.market_id
    left join {{ ref("platform", "analytics__public__market_region_xwalk") }} as mrx on m.market_id = mrx.market_id
    left join {{ref('platform', 'es_warehouse__public__companies')}} c on c.company_id = m.company_id
    left join {{ref('platform','es_warehouse__public__users')}} u on u.user_id = o.user_id
    left join {{ref('platform','es_warehouse__public__equipment_assignments')}} ea on r.rental_id = ea.rental_id
    left join {{ref('platform', 'es_warehouse__public__assets')}} a on a.asset_id = ea.asset_id
    left join {{ref('platform', 'es_warehouse__public__asset_types')}} ast on ast.asset_type_id = a.asset_type_id
    --left join {{ref('platform','es_warehouse__public__categories')}} cat on cat.category_id = a.category_id
    left join {{ref('platform', 'es_warehouse__public__rental_part_assignments')}} rpa on rpa.rental_id = r.rental_id
    left join {{ref('platform', 'es_warehouse__inventory__parts')}} p on p.part_id = rpa.part_id
    left join {{ref('platform', 'es_warehouse__inventory__part_types')}} pt on pt.part_type_id = p.part_type_id
    left join {{ref('platform', 'es_warehouse__public__purchase_orders')}} po on po.purchase_order_id = o.purchase_order_id
    left join {{ref('platform', 'es_warehouse__public__deliveries')}} d on d.delivery_id = r.drop_off_delivery_id
    left join {{ref('platform', 'es_warehouse__public__locations')}} dl on dl.location_id = d.location_id 
    left join {{ref('platform', 'es_warehouse__public__states')}} s on s.state_id = dl.state_id
    left join {{ref('platform', 'es_warehouse__public__rental_location_assignments')}} rla on rla.rental_id = r.rental_id
    left join {{ref('platform', 'es_warehouse__public__locations')}} l on l.location_id = rla.location_id
    left join {{ref('platform', 'es_warehouse__public__companies')}} cm on cm.company_id = o.company_id
    left join {{ref('platform', 'es_warehouse__public__billing_company_preferences')}} bcp on o.company_id = bcp.company_id
    left join business_intelligence.triage.stg_t3__company_values cv on cv.rental_id = r.rental_id
    left join orders_salesperson_breakdown osb on osb.order_id = o.order_id
    left join {{ref('platform','es_warehouse__public__users')}} ps on ps.user_id = osb.primary_salesperson_id
    left join {{ref('platform','es_warehouse__public__users')}} ss on ss.user_id = osb.secondary_salesperson_1
    left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments pcr on pcr.company_id = o.company_id
    left join es_warehouse.public.companies pc on pc.company_id = pcr.parent_company_id

),
billing_cycles as (
    select
        rental_id, 
        rental_billing_cycle_strategy,
        case
        when (rental_billing_cycle_strategy = 'twenty_eight_day_cycle' or rental_billing_cycle_strategy is null) then
            case 
                when start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, start_date::date)
            else dateadd(day, TIMESTAMPDIFF('day',start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',start_date::date , current_date()), 28))::int, start_date::date)
            end
        when rental_billing_cycle_strategy = 'thirty_day_cycle' then
            case 
                when start_date::date >= current_timestamp::date - 30 THEN dateadd(day, 30, start_date::date)
            else dateadd(day, TIMESTAMPDIFF('day',start_date::date , current_timestamp()) + (30-mod(TIMESTAMPDIFF('day',start_date::date , current_date()), 30))::int, start_date::date)
            end
        when rental_billing_cycle_strategy = 'first_of_month' then dateadd(month, 1, date_trunc(month,current_date()))
        else
            case
                when start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, start_date::date)
            else dateadd(day, TIMESTAMPDIFF('day',start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',start_date::date , current_date()), 28))::int, start_date::date)
            end
        end as next_cycle_date
    from base_rentals 
    where rental_status_id = 5 and asset_assignment_rank = 1
    and rental_status_id != 8
),
on_rent as (
    select
        br.rental_id,
        'on_rent' AS status,
        asset_id,
        start_date::DATE AS rental_start_date,
        end_date::DATE AS rental_end_date,
        start_date AS rental_start_datetime,
        end_date AS rental_end_datetime,
        coalesce(price_per_day, 0) AS price_per_day,
        coalesce(price_per_week, 0) AS price_per_week,
        coalesce(price_per_month, 0) AS price_per_month,
        ordered_by_id,
        concat(first_name,' ',last_name) as ordered_by,
        coalesce(custom_name, concat('Bulk Item - ', part_id), 'No Asset Assigned') as asset,
        coalesce(asset_class, description,'Unknown') as asset_class,
        purchase_order,
        purchase_order_id,
        concat(street_1,' ',ifnull(street_2,' '),city,', ',abbreviation,' ',zip_code) as delivery_address,
        company_id,
        jobsite as jobsite,
        vendor,
        bc.next_cycle_date,
        br.order_id,
        br.sub_renter_id,
        br.sub_renting_company,
        br.sub_renting_contact,
        br.market_id,
        br.shift_type_id,
        br.primary_salesperson_id,
        br.primary_salesperson_name,
        br.secondary_salesperson_1,
        br.secondary_salesperson_name,
        br.total_secondary_salespersons,
        br.parent_company_id,
        br.parent_company_name,
        ---- FOR APIs ----
        NULL as miles_in,
        NULL as miles_out,
        NULL as hours_in,
        NULL as hours_out,
        bc.rental_billing_cycle_strategy,
        ---- FOR APIs ----
        case 
            when datediff(day,current_timestamp(),bc.next_cycle_date) <= 7 AND datediff(day,current_timestamp(),bc.next_cycle_date) >= 0 then TRUE
        Else FALSE end as cycles_next_seven_days,
        null as pull_recent_asset_assignment 
    from base_rentals br 
    left join billing_cycles  bc on bc.rental_id = br.rental_id
    where br.rental_status_id = 5  and br.asset_assignment_rank = 1
    and br.rental_status_id != 8
), 
off_rent as (
    select
        rental_id,
        case when rental_status_id in (2,3,4) then 'reservation' else 'off_rent' end as status,
        asset_id,
        start_date::DATE AS rental_start_date,
        end_date::DATE AS rental_end_date,
        start_date AS rental_start_datetime,
        end_date AS rental_end_datetime,
        coalesce(price_per_day, 0) AS price_per_day,
        coalesce(price_per_week, 0) AS price_per_week,
        coalesce(price_per_month, 0) AS price_per_month,
        ordered_by_id,
        concat(first_name,' ',last_name) as ordered_by,
        coalesce(custom_name, concat('Bulk Item - ', part_id), 'No Asset Assigned') as asset,
        coalesce(asset_class, description,'Unknown') as asset_class,
        purchase_order,
        purchase_order_id,
        concat(street_1,' ',ifnull(street_2,' '),city,', ',abbreviation,' ',zip_code) as delivery_address,
        company_id,
        jobsite,
        vendor,
        null as next_cycle_date,
        br.order_id,
        br.sub_renter_id,
        br.sub_renting_company,
        br.sub_renting_contact,
        br.market_id,
        br.shift_type_id,
        br.primary_salesperson_id,
        br.primary_salesperson_name,
        br.secondary_salesperson_1,
        br.secondary_salesperson_name,
        br.total_secondary_salespersons,
        br.parent_company_id,
        br.parent_company_name,
        ---- FOR APIs ----
        NULL as miles_in,
        NULL as miles_out,
        NULL as hours_in,
        NULL as hours_out,
        NULL as rental_billing_cycle_strategy, -- this should be NULL
        ---- FOR APIs ----
        null AS cycles_next_seven_days,
        asset_assignment_rank as pull_recent_asset_assignment
    from base_rentals br
    where asset_assignment_rank = 1 and rental_status_id != 5
    and rental_status_id != 8
)
select * from on_rent 
union all 
select * from off_rent 
