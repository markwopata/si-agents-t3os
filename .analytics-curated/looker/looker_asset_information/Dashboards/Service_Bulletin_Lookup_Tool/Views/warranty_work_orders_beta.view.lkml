view: warranty_work_orders_beta {
  derived_table: {
    sql:with work_orders_to_remove as (
    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
        on wo.WORK_ORDER_ID = woct.WORK_ORDER_ID
    join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
        on woct.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    where (woct.company_tag_id = 40 --Make Ready
            and (aa.make not ilike '%CASE%' and aa.make not ilike '%HOLLAND%')) --Case make readys are warrantable
        or woct.company_tag_id in (
            31 --ANSI
            , 23 --Customer Damage
            , 980 --EQ Transfer
            , 846 --DOT Inspection
            , 2836 --DOT Documents
            )

    union

    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
        on woo.work_order_id = wo.work_order_id
    where woo.originator_type_id = 3
        and wo.description ilike '%ANSI%'

    union

    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    where (wo.description ilike '%Equipment Transfer%')
        or (wo.description ilike '%Transfer%')
        or (wo.description ilike '%Make Ready%' and ( aa.make not ilike '%CASE%' and aa.make not ilike '%HOLLAND%'))
        or (wo.description ilike '%DOT%')
)

, tag_list as (
    select wo.WORK_ORDER_ID, listagg(ct.NAME, ', ') as tags
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
        on wo.WORK_ORDER_ID = woct.WORK_ORDER_ID
    join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
        on woct.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
    where wo.ARCHIVED_DATE is null
    group by wo.WORK_ORDER_ID
)

, est_labor_hours as (
    select distinct wo.work_order_id
        , max(te.created_date) last_time_entry
        , sum(coalesce(te.REGULAR_HOURS,0)) as regular
        , sum(coalesce(te.overtime_hours,0)) as overtime
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
        on wo.WORK_ORDER_ID = te.WORK_ORDER_ID
          --  and te.APPROVAL_STATUS like 'Approved'
          --  and te.NEEDS_REVISION = false
            and te.ARCHIVED = false
            and te.event_type_id = 1
    group by wo.work_order_id
)

, wo_trans AS
        (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
              , IFF(TRANSACTION_TYPE_ID = 7, t.FROM_ID, t.TO_ID) as store_id
              , wo.BRANCH_ID
              , ti.PART_ID                                       AS part_id
              , t.transaction_type_id                            AS transaction_type_id
              , t.TRANSACTION_ID
              , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
          LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
          JOIN es_warehouse.WORK_ORDERS.WORK_ORDERS wo
              ON IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) = wo.WORK_ORDER_ID
          JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
            on wo.BRANCH_ID = m.MARKET_ID
          LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
            on m.COMPANY_ID = c.COMPANY_ID
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            AND qty is not null
            and date_cancelled is null
            AND qty > 0
            AND c.COMPANY_ID in (SELECT COMPANY_ID FROM ANALYTICS.PUBLIC.ES_COMPANIES)
)

, all_wo_parts AS (
    select wt.wo_id, wt.store_id
                , wt.part_id
                , sum(wt.qty) AS QTY
            from wo_trans wt
            group by wt.wo_id, wt.store_id, wt.part_id
)

, avg_cost_per_part_company_wide as (
    select product_id as part_id
        , round(avg(weighted_average_cost), 2) as average_cost_co
    from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS
    where is_current = true
    group by part_id
)

, snap as (
    select current_part_id
        , round(avg(avg_cost), 2) as snap_avg_cost
    from ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT
    where snapshot_date = '2023-11-30'
    group by current_part_id
)

, avg_cost_wac as (
select distinct aw.part_id
    , aw.store_id
    , snap.weighted_average_cost
    , snap.is_current
from all_wo_parts aw
left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS snap
    on aw.part_id = snap.product_id and aw.store_id = snap.inventory_location_id
where is_current = true
)

, wo_part_cost_combo as (
select aw.wo_id
, aw.part_id
, aw.QTY
, coalesce(coalesce(v.weighted_average_cost, acppcw.average_cost_co), snap.snap_avg_cost) as average_cost
, coalesce(aw.QTY * average_cost,0) as part_id_on_wo_cost
from all_wo_parts aw
left join avg_cost_wac v
on aw.part_id = v.part_id and aw.store_id = v.store_id
left join avg_cost_per_part_company_wide acppcw
on acppcw.part_id = aw.part_id
left join snap
on snap.current_part_id = aw.part_id
)

, part_cost as (
select wo_id, sum(coalesce(part_id_on_wo_cost,0)) as part_cost
from wo_part_cost_combo
group by wo_id
)

-- , test as (
select distinct w.*
    , case --
        when m.market_name ilike '%LANDMARK%' then 'Dave Vance'
        when tag.tags ilike '%engine%' then 'Justin Fitzgerald'
        when waa.warranty_admin is not null then waa.warranty_admin
        else 'No Admin Assigned' end as warranty_admin
    , elh.last_time_entry
    , tag.tags
    , coalesce(pc.part_cost,0) as parts_cost
    , (elh.regular + elh.overtime) as labor_hours
    , parts_cost + (labor_hours*100) as estimated_work_order_cost
    , coalesce(ond.notification_date, 30) as note_days
    , coalesce(ond.back_stop_date, 180) as back_days
    , dateadd (day, note_days, coalesce(elh.last_time_entry::DATE, w.date_completed::DATE)) as claim_due
    , datediff(day, current_date, claim_due)  as days_till_due
    , dateadd (day, back_days, coalesce(elh.last_time_entry::DATE, w.date_completed::DATE)) as last_chance
    , datediff(day, current_date, last_chance)  as days_till_last_chance
    , case
        when days_till_due >= 0 and days_till_due <= 5 then 1
        when days_till_due > 5 /*due date is not near yet*/ then 2
        when (days_till_due < 0 /*Missed due date*/ and days_till_last_chance >= 0 /*But still have a chance*/) then 3
        when days_till_last_chance < 0 /*We missed our chance*/ then 4
        else 5
        end as priority_tier
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS w
         left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_STATUSES s on w.WORK_ORDER_STATUS_ID = s.WORK_ORDER_STATUS_ID
         left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct on w.WORK_ORDER_ID = woct.WORK_ORDER_ID
         left join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct on woct.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
         left join tag_list tag on w.work_order_id = tag.work_order_id
         left join est_labor_hours elh on w.WORK_ORDER_ID = elh.WORK_ORDER_ID
         left join part_cost pc on w.work_order_id = pc.wo_id
         left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
            on aa.asset_id = w.asset_id
         left join ANALYTICS.WARRANTIES.OEM_NOTIFICATION_DATES ond
            on ond.oem = aa.make
        left join work_orders_to_remove wotr
            on wotr.work_order_id = w.work_order_id
        left join ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS waa
            on  upper(aa.make) = upper(waa.make)
                and waa.current_flag = 1
        join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
            on m.market_id = w.branch_id
where w.archived_date is null
and w.work_order_status_id = 3
and (w.BILLING_TYPE_ID = 1 or ct.name ilike '%warranty%')
and wotr.work_order_id is null
order by priority_tier asc, estimated_work_order_cost desc
       ;;
  }

  dimension: work_order_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  # dimension: warranty_work_order_id {
  #   type: yesno
  #   sql: ${BILLING_TYPE_ID = 1} OR ${COMPANY_TAG ILIKE "WARRANTY"}
  # }


  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension_group: date_billed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: days_since_completion {
    type: number
    sql: datediff(day, ${date_completed_date}, current_date())  ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_tag {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    label: "Work Order ID"
    sql: ${work_order_id} ;;
    html: <u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension_group: archived {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: service_bulletin {
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

  dimension: tagged_more_info_added {
    type: yesno
    sql: iff(${tags} ilike '%more info added%', true, false) ;;
  }

  dimension: estimated_labor_cost {
    type: number
    sql: ${TABLE}."LABOR_HOURS"*100 ;;
  }

  dimension: estimated_parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
  }

  dimension: estimated_work_order_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ESTIMATED_WORK_ORDER_COST" ;;
  }

  dimension: notification_days {
    type: number
    sql: ${TABLE}.note_days ;;
  }

  dimension: back_stop_days {
    type: number
    sql: ${TABLE}.back_days ;;
  }

  dimension_group: claim_due_date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:${TABLE}.claim_due ;;
  }

  dimension: days_till_due {
    type: number
    sql: ${TABLE}.days_till_due ;;
  }

  dimension_group: last_chance {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:${TABLE}.last_chance ;;
  }

  dimension: days_till_last_chance {
    type: number
    sql: ${TABLE}.days_till_last_chance;;
  }

  dimension: priority_tier {
    type: number
    sql: ${TABLE}.priority_tier ;;
  }

  measure: work_order_count {
    type: count
        drill_fields: [
      market_region_xwalk.market_name,
      work_order_id_with_link_to_work_order,
      date_completed_date,
      assets_under_warranty.max_warranty_end_date_date,
      estimated_work_order_cost,
      asset_id,
      assets.make,
      assets.model,
    ]
  }

  dimension: last_tech_entry {
    type: date
    sql: ${TABLE}.last_time_entry ;;
  }

  # measure: count {
  #   type: count
  #   filters: [
  #     scd_asset_inventory_status.current_flag: "1",
  #     warranty_work_orders.service_bulletin: "1"
  #   ]
    # drill_fields: [
    #   warranty_work_orders.date_created_date,
    #   warranty_work_orders.date_completed_date,
    #   warranty_work_orders.work_order_id_with_link_to_work_order,
    #   warranty_work_orders.status,
    #   warranty_work_orders.asset_id,
    #   scd_asset_inventory_status.asset_inventory_status,
    #   scd_asset_inventory_status.current_flag,
    #   assets.make,
    #   assets.model,
    #   market_region_xwalk.market_name
    # ]}

}
