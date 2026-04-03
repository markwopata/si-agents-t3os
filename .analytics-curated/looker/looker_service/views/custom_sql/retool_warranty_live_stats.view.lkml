view: retool_warranty_live_stats {
  derived_table: {
    sql:
--Using old tables to get live stats
select wr.work_order_id
    , wr.created_by
    , du.user_full_name as warranty_admin
    , wr.review_date
    , wr.warranty_state
    , i.invoice_id
    , wr.invoice_no
    , wr.claim_number
    , i.warranty_billed_amount
    , wr.pre_file_denial_code
from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS wr
left join (
        select i.invoice_id, invoice_no, sum(li.amount) as warranty_billed_amount
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
            on i.invoice_id = li.invoice_id
        where li.line_item_type_id in (22,23,156,133,134)
        group by 1,2
        ) i
    on i.invoice_no = trim(wr.invoice_no)
left join FLEET_OPTIMIZATION.GOLD.DIM_USERS_FLEET_OPT du
    on du.user_id = wr.created_by
where (warranty_state ilike any ('Segmented Claim', 'Claim') or is_current = TRUE);;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${TABLE}.work_order_id, ${TABLE}.invoice_id) ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  dimension: created_by {
    type: number
    value_format_name: id
    sql: ${TABLE}.created_by ;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  dimension_group: review {
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
    sql: CAST(${TABLE}.review_date AS TIMESTAMP_NTZ) ;;
  }

  dimension: warranty_state {
    type: string
    sql: ${TABLE}.warranty_state ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ invoice_id._value }}</a> ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  measure: count_invoiced {
    type: count
    filters: [is_claim: "Yes"]
    drill_fields: [
      work_order_id,
      warranty_admin,
      warranty_state,
      invoice_id,
      invoice_no,
      claim_no,
      invoice_billed_amount
    ]
  }

  dimension: claim_no {
    type: string
    sql: ${TABLE}.claim_number ;;
  }

  dimension: invoice_billed_amount {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warranty_billed_amount  ;;
  }

  dimension: is_claim {
    type: yesno
    sql: iff(${warranty_state} ilike any ('Claim', 'Segmented Claim'), TRUE, FALSE) ;;
  }

  measure: warranty_billed {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_billed_amount} ;;
    filters: [is_claim: "Yes"]
    drill_fields: [
      work_order_id,
      warranty_admin,
      warranty_state,
      invoice_id,
      invoice_no,
      claim_no,
      invoice_billed_amount
    ]
  }


  dimension: pre_file_denial_code {
    type: string
    sql: ${TABLE}.pre_file_denial_code ;;
  }

  measure: count {
    type: count
    drill_fields: [
      work_order_id,
      warranty_admin,
      review_date,
      warranty_state,
      pre_file_denial_code
    ]
  }
}

view: retool_warranty_live_stats_lookup_tool {
  derived_table: { #Matches the lookup tool code in retool as of 6/17/25 - TA
    sql:
with branch_override as ( --When someone flips it back to warranty after it has been marked not warranty
    select distinct wr.work_order_id--, wr.*
    from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS wr
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id = wr.work_order_id
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
        on woct.work_order_id = wo.work_order_id
    left join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
        on ct.company_tag_id = woct.company_tag_id
    where wr.is_current = TRUE and wr.warranty_state = 'Not Warranty' --Only when the most recent review was 'Not Warranty'
        and (wo.billing_type_id = 1 or ct.name ilike '%warranty%')
        and current_timestamp > dateadd(hour, 2, wr.review_date)
)

select iff(wr.warranty_state = 'Engine Warranty' or wwol.tags ilike '%eng%', 'Justin Fitzgerald', wwol.warranty_admin) as warranty_admin
    , wwol.work_order_id
    , case
        when bo.work_order_id is not null then 'Disputed'
        when wr.warranty_state ilike 'Segmented Claim' then wr.warranty_state
        when wwol.tags ilike '%More Info Added%' then 'More Info Added'
        when wr.warranty_state is not null then wr.warranty_state
        when wwol.tags ilike '%Needs More Info%' then 'Needs More Info'
        when wwol.tags ilike '%eng%' then 'Engine Warranty'
        else 'Not Reviewed' end as warranty_state
    , wr.review_date as last_review_date
from ANALYTICS.WARRANTIES.WARRANTY_WORK_ORDER_LOOKUP wwol
left join ${retool_warranty_live_stats.SQL_TABLE_NAME} wr
      on wr.work_order_id = wwol.work_order_id
--left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
  --  on aa.asset_id = wwol.asset_id
left join branch_override bo
    on bo.work_order_id = wwol.work_order_id
where (
  (wr.warranty_state <> 'Segmented Claim' and wr.warranty_state <> 'Claim' and wr.warranty_state <> 'Not Warranty')
  or (wr.warranty_state is null)
  or (bo.work_order_id is not null)
  )
;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  dimension: work_order_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  dimension: warranty_state {
    type: string
    sql: ${TABLE}.warranty_state ;;
  }

  dimension_group: review {
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
    sql: CAST(${TABLE}.last_review_date AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [
      work_order_id,
      warranty_admin,
      review_date,
      warranty_state
    ]
  }
}
