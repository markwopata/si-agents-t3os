view: monthly_annualized_claims {
  derived_table: {
    sql:
with market_oec as (
    select dd.month
        , coalesce(rsp.rental_branch_id, isp.inventory_branch_id) as market_id
        , a.asset_equipment_make as make
        , sum(zeroifnull(a.asset_current_oec)) as oec
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY isp
        on dd.month between isp.date_start and isp.date_end
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSET_RSP_PIT rsp
        on rsp.asset_id = isp.asset_id
            and dd.month between rsp.start_window and rsp.end_window
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on a.asset_id = isp.asset_id
    group by 1,2,3
)

, asset_hour_limits as ( --All assets over on hours
    select aa.asset_id
        , case
            --Allmand Light Towers/Heaters (1000 hours/1 Year)
            when aa.model in ('350 Night-Lite', 'MAXI-LITE II', 'NIGHT-LITE', 'Night-Lite Pro II', 'NLPROii-LD', 'NLV3GR', 'GR-Series') then 1000
            --Allmand Generators
            when aa.model in ('MA185', 'Maxi-Power 150', 'MP25', 'MP65') or aa.make in ('TAKEUCHI' , 'JOHN DEERE' , 'JCB') then 2000
            --Sany Telehandlers
            when aa.model in ('STH1256', 'STH1056', 'STH844', 'STH1056A') or aa.make in ('BOBCAT' , 'ATLAS COPCO') then 3000
            --Genie and JLG ultras, sany excavators and wheel loaders
            when aa.model in ('SX-125 XC', 'S-125', 'SX-150', 'SX-180', '1200SJP', '1350SJP', '1500SJ', '1850SJ', 'SW405K', 'SY135C', 'SY155', 'SY155U', 'SY16', 'SY215', 'SY225C', 'SY235C', 'SY26', 'SY265C LC', 'SY35U', 'SY365C LC', 'SY50', 'SY500', 'SY60C', 'SY75C', 'SY95C') then 5000
            else 1000000000 end as hour_limits
        , min(scd.date_start)::DATE as over_hour_limit
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS scd
        on scd.asset_id = aa.asset_id
    -- join warrantable_assets wa
    --     on wa.asset_id = aa.asset_id
    where hour_limits < scd.hours
    group by aa.asset_id, hour_limits
)

, warranty_oec as (
    select a.asset_id
        , a.asset_equipment_make make
        , a.asset_current_oec
        , case
            when a.asset_oem_delivery_date::DATE <> '0001-01-01' then a.asset_oem_delivery_date::DATE
            when add.delivery_date::DATE is not null then add.delivery_date::DATE
            when wo.first_wo::DATE is not null then wo.first_wo::DATE
            when a.asset_purchase_date::DATE <> '0001-01-01' then a.asset_purchase_date::DATE
          else null end as warranty_start_date
        , max(wi.time_value::NUMBER) warranty_length
        , case --This is written like this because on the 08/06/25 the normal dateadd stopped working. looked to be something with incompatible datatypes, but don't know for sure
            when a.asset_oem_delivery_date::DATE <> '0001-01-01' then dateadd(month, warranty_length,a.asset_oem_delivery_date::DATE)
            when add.delivery_date::DATE is not null then dateadd(month, warranty_length, add.delivery_date::DATE)
            when wo.first_wo::DATE is not null then dateadd(month, warranty_length, wo.first_wo::DATE)
            when a.asset_purchase_date::DATE <> '0001-01-01' then dateadd(month, warranty_length, a.asset_purchase_date::DATE)
          else null end as warranty_end_date
    from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    join ES_WAREHOUSE.PUBLIC.ASSET_WARRANTY_XREF x
        on x.asset_id = a.asset_id
            and x.date_deleted is null
    join ANALYTICS.WARRANTIES.REVIEWED_WARRANTY_ITEMS rwi
        on rwi.warranty_id = x.warranty_id
            and rwi.is_warrantable
    join ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS wi
        on wi.warranty_item_id = rwi.warranty_item_id
            AND wi.DATE_DELETED is null --previous table should be only active but just in case something gets deleted later
            AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)
    left join ANALYTICS.PARTS_INVENTORY.ASSET_DELIVERY_DATE add
        on add.asset_id = a.asset_id
    left join (
            select asset_id, min(date_created::DATE) as first_wo
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
            where archived_date is null
            group by 1) wo
        on wo.asset_id = a.asset_id
    left join asset_hour_limits ohl
        on ohl.asset_id = a.asset_id
    group by 1,2,3,a.asset_oem_delivery_date, add.delivery_date, wo.first_wo, a.asset_purchase_date, warranty_start_date, ohl.over_hour_limit
    -- having current_date between warranty_start_date and warranty_end_date
)

, month_market_make_oec as (
    select dd.month
        , market_id
        , woec.make
        , sum(zeroifnull(wo.work_order_value_completed)) as work_order_value_completed
        , sum(zeroifnull(woec.asset_current_oec)) as warranty_oec
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between '2019-01-01' and current_date) dd
    join warranty_oec woec
        on dd.month between woec.warranty_start_date and woec.warranty_end_date
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSET_RSP_PIT rsp
        on rsp.asset_id = woec.asset_id
            and dd.month between rsp.start_window and rsp.end_window
    left join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY isp
        on isp.asset_id = woec.asset_id
            and dd.month between isp.date_start and isp.date_end
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = coalesce(rsp.rental_branch_id, isp.inventory_branch_id)
    left join (
            select date_trunc(month, dateadd(day, 15, dd.dt_date)) as month
                , da.asset_id
                , sum(zeroifnull(wol.work_order_line_amount)) work_order_value_completed
            from PLATFORM.GOLD.DIM_WORK_ORDERS wo
            join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wol
                on wol.work_order_line_work_order_key = wo.work_order_key
            join PLATFORM.GOLD.DIM_DATES dd
                on dd.dt_key = wo.work_order_date_completed_key
            join PLATFORM.GOLD.DIM_ASSETS da
                on da.asset_key = wo.work_order_asset_key
                    and da.asset_id <> -1
            group by 1,2 ) wo
        on wo.asset_id = woec.asset_id
            and wo.month = dd.month
    group by 1,2,3
)

, warranty_revenue as (
    select dd.date_month_start as month
        , market_region_name as region
        , market_district as district
        , market_id
        , market_name as market
        -- , u.user_full_name as invoice_creator --Might add in later, we'll see if they want it
        , a.asset_equipment_make make
        , sum(w.warranty_credits_pending_amount + w.warranty_credits_paid_amount + w.warranty_credits_denied_amount) as claim_total
        , datediff(day, dateadd(day, -1, date_month_start), date_month_end) as days_in_month
        , (claim_total / days_in_month) * 365 as annualized_claims
    from FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS w
    join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
        on i.invoice_key = w.warranty_credits_invoice_key
            and i.invoice_credit_note_indicates_error = false
            and i.invoice_billing_approved
    join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dd
        on dd.dt_key = i.invoice_billing_approved_date_key
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_key = w.warranty_credits_market_key
    join FLEET_OPTIMIZATION.GOLD.DIM_USERS_FLEET_OPT u
        on u.user_key = i.invoice_creator_user_key
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on a.asset_key = w.warranty_credits_asset_key
    where dt_date between dateadd(month, -24, current_date) and current_date
    group by 1,2,3,4,5,6,8
)

, prep as (
    select coalesce(dd.month, wr.month) as month
        , coalesce(mmmo.market_id, wr.market_id) as market_id
        , coalesce(mmmo.make, wr.make) as make
        , zeroifnull(work_order_value_completed) as work_order_value_completed
        , zeroifnull(warranty_oec) as warranty_oec
        , zeroifnull(wr.claim_total) as claim_total
        , zeroifnull(wr.annualized_claims) as annualized_claims
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    left join month_market_make_oec mmmo
        on mmmo.month = dd.month
    full outer join warranty_revenue wr
        on wr.market_id = mmmo.market_id
            and wr.month = dd.month
            and wr.make = mmmo.make
)

, final_prep as (
    select dd.month
        , dd.month_name
        , m.market_region_name  as region
        , m.market_district  as district
        , m.market_id
        , m.market_name as market
        , p.make as make
        , zeroifnull(mo.oec) as branch_oec
        , zeroifnull(p.work_order_value_completed) as potential_warranty_work_order_value_completed
        , zeroifnull(p.warranty_oec) as warranty_oec
        , zeroifnull(p.claim_total) as warranty_claims
        , zeroifnull(p.annualized_claims) as annualized_claims
    from (select distinct date_month_start as month, dt_month_name as month_name from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    full outer join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT c
        on c.company_id = m.market_company_id
            and c.company_is_equipmentshare_company
    left join prep p
        on p.month = dd.month
            and p.market_id = m.market_id
    left join market_oec mo
        on mo.month = dd.month
            and mo.market_id = m.market_id
            and p.make = mo.make
)

, bottom_markets as (
    select top {% parameter max_rank %}
        market_id, market
        , round((((sum(zeroifnull(warranty_oec)) * 0.02) - sum(zeroifnull(annualized_claims))) /  12), 2) as estimated_under_goal
        , TRUE as bottom_branches
    from final_prep fp
    where date_trunc(year, fp.month) = date_trunc(year, current_date)
      and fp.region ilike concat('%', {% parameter region_name_param %}, '%')
      and market not ilike 'Main Branch'
    group by 1,2
    order by estimated_under_goal desc
)

select month
    , month_name
    , region
    , district
    , fp.market_id
    , fp.market
    , make
    , branch_oec
    , potential_warranty_work_order_value_completed
    , warranty_oec
    , warranty_claims
    , annualized_claims
    , coalesce(bm.bottom_branches, FALSE) as bottom_market
from final_prep fp
left join bottom_markets bm
    on fp.market_id = bm.market_id
where region ilike concat('%', {% parameter region_name_param %}, '%')
;;
  }

  dimension_group: reference {
    type: time
    timeframes: [
      date,
      month,
      year
    ]
    sql: dateadd(day, 1, ${TABLE}.month) ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}.month_name ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: market_make_oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}.branch_oec ;;
  }

  measure: oec {
    type: sum
    value_format_name: usd_0
    sql: ${market_make_oec} ;;
  }

  dimension: market_make_work_orders_completed_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.potential_warranty_work_order_value_completed ;;
  }

  measure: potential_warranty_work_orders_completed_value {
    type: sum
    value_format_name: usd_0
    sql: ${market_make_work_orders_completed_value} ;;
  }

  measure: potenital_warranty_wo_completed_value_by_oec {
    type: number
    value_format_name: percent_2
    sql: ${potential_warranty_work_orders_completed_value} / iff(${warranty_oec} = 0, null, ${warranty_oec}) ;;
  }

  dimension: market_make_warranty_oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}.warranty_oec ;;
  }

  measure: warranty_oec {
    type: sum
    value_format_name: usd_0
    sql: ${market_make_warranty_oec} ;;
  }

  measure: perc_oec_under_warranty {
    type: number
    value_format_name: percent_0
    html: {{perc_oec_under_warranty._rendered_value}} <br> <p style="font-size:12px"> {{oec._rendered_value}} OEC <br> {{warranty_oec._rendered_value}} Under Warranty </p>;;
    sql: ${warranty_oec} / nullifzero(${oec}) ;;
  }

  measure: warranty_goal {
    type: number
    value_format_name: usd_0
    sql: 0.02 * ${warranty_oec} ;;
  }

  measure: dollars_to_goal {
    type: number
    value_format_name: usd_0
    sql: (${warranty_goal} - ${annualized_claims}) / 12 ;;
  }

  dimension: market_make_warranty_claims {
    type: number
    value_format_name: usd
    sql: ${TABLE}.warranty_claims ;;
  }

  measure: warranty_claims {
    type: sum
    value_format_name: usd_0
    sql: ${market_make_warranty_claims} ;;
  }

  dimension: market_make_annualized_claims {
    type: number
    value_format_name: usd
    sql: ${TABLE}.annualized_claims ;;
  }

  measure: annualized_claims {
    type: sum
    value_format_name: usd_0
    sql: ${market_make_annualized_claims} ;;
  }

  measure: annualized_claims_perc_of_warranty_oec {
    type: number
    value_format_name: percent_2
    sql: ${annualized_claims} / nullifzero(${warranty_oec}) ;;
  }

  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Warranty Admin"}
    allowed_value: { value: "OEM"}
    allowed_value: { value: "Billed Company"}
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  dimension: dynamic_axis {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'OEM'" %}
      ${make}
    {% elsif drop_down_selection._parameter_value == "'Region'" %}
      ${region}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: bottom_performing_market {
    type: yesno
    sql: ${TABLE}.bottom_market ;;
  }

  parameter: region_name_param {
    type: string
  }

  parameter: bottom_branch_date {
    type: date
  }
}
