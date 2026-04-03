with base_invoice_data as (
select 
    li.line_item_id,
    lit.line_item_type_name as line_item_type,
    i.invoice_id,
    i.invoice_no,
    i.billing_approved_date,
    i.DATE_CREATED as invoice_created_date,
    i.paid_date,
    i.market_id,
    m.child_market_name as market_name,
    m.market_id as parent_market_id,
    m.market_name as parent_market_name,
    m.region,
    m.region_name as region_name,
    m.district,
    i.ship_to__address__state_abbreviation as ship_to_state,
    li.line_item_type_id,
    i.company_id,
    c.customer_name as company_name,
    li.amount,
    o.order_id,
    o.date_created as order_date,
    li.asset_id,
    li.price_per_unit,
    aa.make as invoice_asset_make,
    aa.equipment_class_id as invoice_class_id,
    aa.class as invoice_class,
    cra.nbv,
    cra.profit_margin,
    cra.FLOOR_RATE,
    cra.BENCHMARK_RATE,
    cra.ONLINE_RATE,

    cra.rate_tier_id,
    cra.rate_tier_name,
    cra.commission_rate
from {{ ref("int_retail_sales_commissions_rate_achievement") }} cra

join {{ ref("stg_es_warehouse_public__line_items") }} li 
    on cra.line_item_id = li.line_item_id
inner join {{ ref("stg_es_warehouse_public__line_item_types") }} lit
    on li.line_item_type_id = lit.line_item_type_id
inner join {{ ref("stg_es_warehouse_public__invoices") }} i
    on li.invoice_id = i.invoice_id
inner join {{ ref("stg_es_warehouse_public__companies") }} c
    on i.company_id = c.company_id
left join {{ ref("market") }} m 
    on i.market_id = m.child_market_id
inner join {{ ref("stg_es_warehouse_public__orders") }} o 
    on i.order_id = o.order_id
left join {{ ref("stg_es_warehouse_public__assets_aggregate") }} aa 
    on li.asset_id = aa.asset_id

),
line_item_salesperson as (
    select 
        li.line_item_id,
        i.billing_approved_date,
        iff(ais.salesperson_id::int = nca.nam_user_id::int, null, ais.salesperson_id) as salesperson_user_id,
        ais.salesperson_type_id,
        ais.sales_person_type,
        ais.secondary_rep_count
    from {{ ref("stg_es_warehouse_public__approved_invoice_salespersons") }} ais
    join {{ ref("stg_es_warehouse_public__line_items") }} li 
        on ais.invoice_id = li.invoice_id
        join {{ ref("stg_es_warehouse_public__invoices") }} i 
        on li.invoice_id = i.invoice_id
    left join {{ ref("stg_analytics_commission__nam_company_assignments") }} nca
        on nca.company_id = i.company_id
            and i.billing_approved_date between nca.effective_start_date and nca.effective_end_date
    where 
        (
            billing_approved_date < '2025-09-01'
            and ais.sales_person_type = 'Primary Salesperson' -- anything before the 2025-09-01 is not subject for splits
        )
        or
        (
            billing_approved_date >= '2025-09-01' -- anything after the 2025-09-01 is subject for splits
        )

),  
nam_salesperson as (
    select 
        li.line_item_id,
        i.billing_approved_date,
        nca.nam_user_id as salesperson_user_id,
        1 as salesperson_type_id,
        'NAM Salesperson' as sales_person_type,
        0 as secondary_rep_count
    from {{ ref("stg_analytics_commission__nam_company_assignments") }} nca
    join {{ ref("stg_es_warehouse_public__invoices") }} i 
        on nca.company_id = i.company_id
        and i.billing_approved_date between nca.effective_start_date and nca.effective_end_date
    join {{ ref("stg_es_warehouse_public__line_items") }} li 
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
        cdv.direct_manager_name as employee_manager
    from salesperson_line_item sli
    left join {{ ref("stg_es_warehouse_public__users") }} u
        on sli.salesperson_user_id = u.user_id
    asof join
            (SELECT *,
                      ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_ID, DATE_TRUNC('day', _es_update_timestamp)
                          ORDER BY _es_update_timestamp DESC) AS row_num
               FROM {{ ref("stg_analytics_payroll__company_directory_vault") }}
               WHERE _es_update_timestamp BETWEEN '2022-01-01' AND CURRENT_DATE
               QUALIFY row_num = 1) cdv
    match_condition(date_trunc('day',sli.billing_approved_date)<=date_trunc('day',cdv._es_update_timestamp)) on try_to_number(u.EMPLOYEE_ID) = cdv.EMPLOYEE_ID
)
select
    bid.*,
    csd.* exclude (line_item_id,billing_approved_date)
from base_invoice_data bid
left join complete_salesperson_data csd
    on bid.line_item_id = csd.line_item_id

