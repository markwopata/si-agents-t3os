with base_invoice_data as (
    select
        li.line_item_id,
        lit.line_item_type_name as line_item_type,
        i.invoice_id,
        i.invoice_no,
        i.billing_approved_date,
        i.paid_date,
        i.market_id,
        m.child_market_name as market_name,
        m.market_id as parent_market_id,
        m.market_name as parent_market_name,
        m.region,
        m.region_name,
        m.district,
        i.ship_to__address__state_abbreviation as ship_to_state,
        li.line_item_type_id,
        i.company_id,
        c.customer_name as company_name,
        li.amount,
        o.order_id,
        o.date_created as order_date,
        li.asset_id,
        li.extended_data__rental__equipment_class_name as rental_class,
        li.rental_billed_days,
        li.cheapest_period,
        li.quoted_rates,
        li.price_per_unit,
        aa.make as invoice_asset_make,
        aa.equipment_class_id as invoice_class_id,
        aa.class as invoice_class,
        -- there are changes being made in aa table without date update. rac table gets inserted on hourly basis, which
        -- makes it more reliable. using coalesce incase there are any missing business segments.
        coalesce(rac.business_segment_id, aa.business_segment_id) as business_segment_id,
        r.rental_id,
        r.date_created as rental_date_created,
        r.start_date as rental_start_date,
        r.equipment_class_id as rental_class_id,
        rac.rate_tier_id as norm_rate_tier_id,
        rac.itl_rep_rate_tier_id,
        rac.book_rate,
        rac.benchmark_rate,
        rac.floor_rate,
        rac.rate_tier_name as norm_rate_tier_name,
        rac.itl_rate_tier_name as itl_rate_tier_name,
        rac.commission_percentage,
        rac.itl_commission_percentage
    from {{ ref("stg_es_warehouse_public__line_items") }} as li
        inner join {{ ref("stg_es_warehouse_public__line_item_types") }} as lit
            on li.line_item_type_id = lit.line_item_type_id
        inner join {{ ref("stg_es_warehouse_public__invoices") }} as i
            on li.invoice_id = i.invoice_id
        inner join {{ ref("stg_es_warehouse_public__companies") }} as c
            on i.company_id = c.company_id
        left join {{ ref("market") }} as m
            on i.market_id = m.child_market_id
        inner join {{ ref("stg_es_warehouse_public__orders") }} as o
            on i.order_id = o.order_id
        left join {{ ref("stg_es_warehouse_public__assets_aggregate") }} as aa
            on li.asset_id = aa.asset_id
        left join {{ ref("stg_es_warehouse_public__rentals") }} as r
            on li.rental_id = r.rental_id
        left join {{ ref("int_commissions_rate_achievement_combined") }} as rac
            on li.line_item_id = rac.line_item_id
),

line_item_salesperson as (
    select
        li.line_item_id,
        i.billing_approved_date,
        iff(ais.salesperson_id::int = nca.nam_user_id::int, null, ais.salesperson_id) as salesperson_user_id,
        ais.salesperson_type_id,
        ais.sales_person_type,
        ais.secondary_rep_count
    from {{ ref("stg_es_warehouse_public__approved_invoice_salespersons") }} as ais
        inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on ais.invoice_id = li.invoice_id
        inner join {{ ref("stg_es_warehouse_public__invoices") }} as i
            on li.invoice_id = i.invoice_id
        left join {{ ref("stg_analytics_commission__nam_company_assignments") }} as nca
            on i.company_id = nca.company_id
                and i.billing_approved_date between nca.effective_start_date and nca.effective_end_date
),

nam_salesperson as (
    select
        li.line_item_id,
        i.billing_approved_date,
        nca.nam_user_id as salesperson_user_id,
        1 as salesperson_type_id,
        'NAM Salesperson' as sales_person_type,
        0 as secondary_rep_count
    from {{ ref("stg_analytics_commission__nam_company_assignments") }} as nca
        inner join {{ ref("stg_es_warehouse_public__invoices") }} as i
            on nca.company_id = i.company_id
                and i.billing_approved_date between nca.effective_start_date and nca.effective_end_date
        inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on i.invoice_id = li.invoice_id
    where nca.nam_user_id is not null
),

salesperson_line_item as (
    select *
    from line_item_salesperson

    union all

    select *
    from nam_salesperson
),

daily_company_directory_vault as (
    select
        *,
        case when default_cost_centers_full_path ilike '%tooling%'
                and employee_title ilike '%territory%' then True 
                else False end as is_itl_rep,
        row_number() over (
            partition by employee_id, date_trunc('day', _es_update_timestamp)
            order by _es_update_timestamp desc
        ) as row_num
    from {{ ref("stg_analytics_payroll__company_directory_vault") }}
    where _es_update_timestamp between '2022-01-01' and dateadd(day, 1, current_date)
    qualify row_num = 1
),

complete_salesperson_data as (
    select
        sli.line_item_id,
        sli.billing_approved_date,
        sli.salesperson_user_id::int as salesperson_user_id,
        sli.salesperson_type_id,
        sli.sales_person_type,
        sli.secondary_rep_count,
        u.email_address,
        u.employee_id,
        u.full_name,
        cdv.employee_title,
        cdv.date_terminated,
        cdv.direct_manager_employee_id as employee_manager_id,
        cdv.direct_manager_name as employee_manager,
        cdv.is_itl_rep
    from salesperson_line_item as sli
        left join {{ ref("stg_es_warehouse_public__users") }} as u
            on sli.salesperson_user_id = u.user_id
        asof join
            daily_company_directory_vault as cdv
            match_condition(
                date_trunc('day', sli.billing_approved_date) <= date_trunc('day', cdv._es_update_timestamp)
            ) on try_to_number(u.employee_id) = cdv.employee_id
)

select
    bid.line_item_id,
    bid.line_item_type,
    bid.invoice_id,
    bid.invoice_no,
    bid.billing_approved_date,
    bid.paid_date,
    bid.market_id,
    bid.market_name,
    bid.parent_market_id,
    bid.parent_market_name,
    bid.region,
    bid.region_name,
    bid.district,
    bid.ship_to_state,
    bid.line_item_type_id,
    bid.company_id,
    bid.company_name,
    bid.amount,
    bid.order_id,
    bid.order_date,
    bid.asset_id,
    bid.rental_class,
    bid.rental_billed_days,
    bid.cheapest_period,
    bid.quoted_rates,
    bid.price_per_unit,
    bid.invoice_asset_make,
    bid.invoice_class_id,
    bid.invoice_class,
    bid.business_segment_id,
    bid.rental_id,
    bid.rental_date_created,
    bid.rental_start_date,
    bid.rental_class_id,
    case 
        when csd.is_itl_rep = true and line_item_type_id = 8
            then bid.itl_rep_rate_tier_id 
        else bid.norm_rate_tier_id 
        end 
            as rate_tier_id,
    
    bid.book_rate,
    bid.benchmark_rate,
    bid.floor_rate,

    case 
        when csd.is_itl_rep = true and line_item_type_id = 8
            then bid.itl_rate_tier_name 
            else bid.norm_rate_tier_name 
        end 
            as rate_tier_name,

    case 
        when  csd.is_itl_rep = true  and line_item_type_id = 8
            then bid.itl_commission_percentage 
            else bid.commission_percentage 
        end 
            as commission_percentage, 

    csd.* exclude (line_item_id, billing_approved_date)
from base_invoice_data as bid
    left join complete_salesperson_data as csd
        on bid.line_item_id = csd.line_item_id
