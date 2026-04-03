view: warranty_vendor_level {
  derived_table: {
    sql:
select v.vendorid
    , v.vendor_name
    , v.vendor_type
    , i.invoice_id
    , i.invoice_no
    , (zeroifnull(wi.warranty_credits_paid_amount) + zeroifnull(wi.warranty_credits_pending_amount) + zeroifnull(wi.warranty_credits_denied_amount)) as total_amt
    , wi.warranty_credits_paid_amount as paid_amt
    , wi.warranty_credits_pending_amount as pending_amt
    , wi.warranty_credits_denied_amount as total_denied_amt
    , iff(wi.warranty_credits_claim_closure_days >= 0, wi.warranty_credits_claim_closure_days, null) as claim_closure_days
    , datediff(day, wo.date_completed, bad.dt_date) as days_to_claim
    , wi.warranty_credits_invoice_credit_amount as credit_am
    , i.invoice_paid as paid
    , cd.dt_date as date_created
    , bad.dt_date as billing_approved_date
    , CASE WHEN paid = 'FALSE' or paid is null THEN 'Pending'
      WHEN paid = 'TRUE' and paid_amt = 0 THEN 'Denied'
      ELSE 'Paid'
      END AS warranty_status
    , pd.dt_date as paid_date
    , iff(ici.invoice_no is not null, TRUE, FALSE) is_child_invoice
    , cw.warranty_credits_paid_amount as child_paid_amt
from FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS wi
join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
    on wi.warranty_credits_invoice_key = i.invoice_key
        and i.invoice_credit_note_indicates_error = false
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    on m.market_key = wi.warranty_credits_market_key
join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT cd
    on cd.dt_key = i.invoice_date_key
join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT bad
    on bad.dt_key = i.invoice_billing_approved_date_key
        and i.invoice_billing_approved = TRUE
join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT pd
    on pd.dt_key = i.invoice_paid_date_key
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT aa
    on aa.asset_key = wi.warranty_credits_asset_key
join (
        select vendorid
            , vendor_name
            , mapped_vendor_name
            , vendor_type
            , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
            , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
        from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
        where primary_vendor ilike 'yes' and mapped_vendor_name is not null
        ) v
    on upper(join1) = aa.asset_equipment_make or upper(join2) = aa.asset_equipment_make
left join ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc
    on trim(rc.invoice_no) = i.invoice_no
left join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT ci
    on trim(ci.invoice_no) = rc.child_invoice_no
left join FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS cw
    on cw.warranty_credits_invoice_key = ci.invoice_key
left join ANALYTICS.WARRANTIES.RETOOL_CLAIMS ici
    on trim(ici.child_invoice_no) = i.invoice_no
left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS woi
    on i.invoice_id = woi.invoice_id
left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    on coalesce(rc.work_order_id, woi.work_order_id) = wo.work_order_id
      ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: warranty_status {
    type: string
    sql: ${TABLE}.warranty_status ;;
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.billing_approved_date ;;
  }

  dimension: paid_date {
    type: date
    sql: ${TABLE}.paid_date ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.date_created ;;
  }

  dimension: invoice_id {
    type:  string
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: CAST(
          CONCAT(
          ${TABLE}.invoice_id,
          ${TABLE}.vendorid)
          as VARCHAR) ;;
  }

  dimension: claim_closure_days {
    type:  number
    sql: ${TABLE}.claim_closure_days ;;
  }

  dimension: days_to_claim {
    type:  number
    sql: ${TABLE}.days_to_claim ;;
  }

  dimension: total_amt_requested {
    type: number
    sql: ${TABLE}.total_amt ;;
  }

  dimension: Paid_amt {
    type: number
    sql: ${TABLE}.Paid_amt ;;
  }

  dimension: Pending_amt {
    type: number
    sql: ${TABLE}.Pending_amt ;;
  }

  dimension: Denied_amt {
    type: number
    sql: ${TABLE}.TOTAL_DENIED_AMT;;
  }

  dimension: credit_amt {
    type: number
    sql: ${TABLE}.credit_amt ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}.paid ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${date_created} <= current_date AND ${date_created} >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  last_12_months{
    type: yesno
    sql:  ${date_created} <= current_date AND ${date_created} >= (current_date - INTERVAL '12 months')
      ;;
  }

  dimension: warranty_drill {
    type: string
    sql: 'Warranty Detail' ;;
    html: <a style="color:rgb(26, 115, 232)" href="https://equipmentshare.looker.com/looks/796?f[get_past_dates_filter.generateddate_date]={{ _filters['get_past_dates_filter.generateddate_date'] | url_encode }}&f[top_vendor_mapping.vendor_name]={{ _filters['top_vendor_mapping.vendor_name'] | url_encode }}&toggle=det" target="_blank">{{value}}</a> ;;
  }

  measure: paid_claim_count {
    type: count_distinct
    filters: [warranty_status: "Paid"]
    sql: ${TABLE}.invoice_id ;;
  }

  measure: pending_claim_count {
    type: count_distinct
    filters: [warranty_status: "Pending"]
    sql: ${TABLE}.invoice_id ;;
  }

  measure: claim_count {
    type: count_distinct
    sql: ${TABLE}.invoice_id ;;
  }

  measure: days_30_paid_war {
    type: sum
    filters: [last_30_days: "No", warranty_status: "Paid"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.total_amt ;;
  }

  measure: days_30_pending_war {
    type: sum
    filters: [last_30_days: "No", warranty_status: "Pending"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.total_amt ;;
  }

  measure: days_30_total_war {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.total_amt ;;
  }

  # dimension: total_percent_war {
  #   type: number
  #   value_format_name: usd
  #   value_format: "$#,##0"
  #   sql: sum(case when warranty_status = 'Paid' then ${TABLE}.total_amt_requested else 0 end) / sum(${TABLE}.total_amt_requested);;
  # }

  # measure: paid_percent_warranty {
  #   type: number
  #   sql: (case when ${warranty_status} = 'Paid' then ${TABLE}.total_amt_requested else 0 end) /
  #   ${TABLE}.total_amt_requested;;
  #   value_format_name: percent_1
  #   #drill_fields: [detail*]
  # }

  measure: paid_war {
    type: sum
    filters: [warranty_status: "Paid"]
    value_format: "[>=1000000000]$0.0,,,\"B\";[>=1000000]$0.0,,\"M\";[>=1000]$0.0,\"K\";$0"
    sql: ${TABLE}.total_amt ;;
  }


  measure: pending_war {
    type: sum
    label: "Pending Warranty"
    value_format_name: usd_0
    sql: ${Pending_amt} ;;
    html: {{pending_war._rendered_value}} <br> <p style="font-size:20px"> {{pending_claim_count._rendered_value}} Claims </p>;;
    drill_fields: [
      vendorid,
      vendor_name,
      billing_approved_date,
      claim_closure_days,
      warranty_status,
      invoice_id,
      date_created,
      total_amt_requested,
      Pending_amt,
      Denied_amt,
      Paid_amt,
      credit_amt,
      invoice_no,
      paid,
      billing_approved_date
    ]
  }

  measure: pending_war_30_days {
    type: sum
    label: "Pending Warranty Filtered 30 days"
    filters: [last_30_days: "Yes"]
    value_format_name: usd_0
    sql: ${Pending_amt}  ;;
    #html: {{pending_war._rendered_value}} <br> <p style="font-size:20px"> {{pending_claim_count._rendered_value}} Claims </p>;;
    drill_fields: [
      vendorid,
      vendor_name,
      billing_approved_date,
      claim_closure_days,
      warranty_status,
      invoice_id,
      date_created,
      total_amt_requested,
      Pending_amt,
      Denied_amt,
      Paid_amt,
      credit_amt,
      invoice_no,
      paid,
      billing_approved_date
    ]
  }

  measure: total_war {
    type: sum
    value_format_name: usd
    value_format: "[>=1000000000]$0.0,,,\"B\";[>=1000000]$0.0,,\"M\";[>=1000]$0.0,\"K\";$0"
    sql: ${TABLE}.total_amt ;;
  }

  measure: warranty_pending_scaled {
    type: number
    value_format_name: usd
    value_format: "$#,##0"
    sql: case when ${pending_war} = 0 or ${get_past_dates_filter.day_count} = 0 then 0 else ${pending_war}/${get_past_dates_filter.day_count} end ;;
    html: {{warranty_pending_scaled._rendered_value}} <br> {{pending_claim_count._rendered_value}} Claims;;
  }

  measure: warranty_pending_scaled_12_months {
    type: number
    value_format_name: usd
    value_format: "$#,##0"
    label: "Pending Warranty Scaled 12mo"
    sql: case when ${warranty_pending_scaled} = 0 then 0
    --when ${last_12_months} = 'No' then 0 --issue with this
    else ${warranty_pending_scaled} end ;;
    html: {{warranty_pending_scaled._rendered_value}} <br> {{pending_claim_count._rendered_value}} Claims;;
  }


  measure: warranty_recovery_percent {
    type: number
    label: "Warranty Recovery"
    sql: case when ${paid_war} = 0 or ${total_war} = 0 then 0 else ${paid_war}/${total_war} end ;;
    html: {{warranty_recovery_percent._rendered_value}} <br> {{paid_war._rendered_value}} Warranty Paid | {{total_war._rendered_value}} Total Warranty;;
    value_format_name: percent_0
    #drill_fields: [detail*]
  }

  measure: days_30_avg_claim_closure {
    type: average
    filters: [last_30_days: "No"]
    value_format: "0"
    sql: ${TABLE}.claim_closure_days ;;
  }

  measure: avg_claim_closure {
    description: "The difference between the billing approved date and the paid date."
    type: average
    value_format: "0"
    sql: ${TABLE}.claim_closure_days ;;
    drill_fields: [
      vendorid,
      vendor_name,
      billing_approved_date,
      claim_closure_days,
      warranty_status,
      invoice_id,
      date_created,
      total_amt_requested,
      Pending_amt,
      Denied_amt,
      Paid_amt,
      credit_amt,
      invoice_no,
      paid,
      billing_approved_date
    ]
  }

  measure: days_30_avg_days_to_claim {
    type: average
    filters: [last_30_days: "No"]
    value_format: "0"
    sql: ${TABLE}.days_to_claim ;;
  }

measure: avg_days_to_claim {
  description: "The difference between the billing approved date and the paid date."
  type: average
  value_format: "0"
  sql: ${TABLE}.days_to_claim ;;
  drill_fields: [
    vendorid,
    vendor_name,
    billing_approved_date,
    claim_closure_days,
    warranty_status,
    invoice_id,
    date_created,
    total_amt_requested,
    Pending_amt,
    Denied_amt,
    Paid_amt,
    credit_amt,
    invoice_no,
    paid,
    billing_approved_date
  ]
}
}

view: vendor_warranty_score {
  derived_table: {
    sql:
with vendor_types as (
    select tvm.vendorid
        , avg(claim_closure_days) as peers_avg_claim_closure_days
    from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" tvm
    join ${warranty_vendor_level.SQL_TABLE_NAME} vo
        on vo.vendorid <> tvm.vendorid
            and vo.vendor_type = tvm.vendor_type
            and vo.billing_approved_date >= dateadd(month, -12, current_date)
    where tvm.primary_vendor ilike 'yes'
    group by 1
)

, cte as (
    select vendorid
        , vendor_name
        , vendor_type
        , sum(zeroifnull(paid_amt) + zeroifnull(child_paid_amt)) as adj_paid_amount
        , sum(total_amt) as claim_total
        , avg(claim_closure_days) as avg_claim_closure_days
        , count(invoice_id) as claims
    from ${warranty_vendor_level.SQL_TABLE_NAME}
    where billing_approved_date >= dateadd(month, -12, current_date)
    group by 1,2,3
)

select v.vendorid
    , v.vendor_name
    , v.vendor_type
    , v.adj_paid_amount
    , v.claim_total
    , (v.adj_paid_amount / nullifzero(v.claim_total)) as vendor_recovery_perc
    , sum(g.adj_paid_amount) peers_paid_amount
    , sum(g.claim_total) as peers_claim_total
    , round((peers_paid_amount / peers_claim_total), 2) as peers_recovery_perc
    , round(greatest(coalesce(peers_recovery_perc, 0), 0.9), 2) as recovery_perc_target
    , round(iff(((vendor_recovery_perc / recovery_perc_target) * (1/14)) > (1/14), (1/14), ((vendor_recovery_perc / recovery_perc_target) * (1/14))), 2) as recovery_perc_score
    , round(iff(((vendor_recovery_perc / recovery_perc_target) * 10) > 10, 10, ((vendor_recovery_perc / recovery_perc_target) * 10)), 2) as recovery_perc_score10

    , v.avg_claim_closure_days
    , vt.peers_avg_claim_closure_days
    , least(coalesce(peers_avg_claim_closure_days, 1000000000), 8) as claim_closure_days_target
    , round(iff((claim_closure_days_target / nullifzero(v.avg_claim_closure_days)) * (1/14) > (1/14), (1/14), (claim_closure_days_target / nullifzero(v.avg_claim_closure_days)) * (1/14)), 2) as claim_closure_days_score
    , round(iff((claim_closure_days_target / nullifzero(v.avg_claim_closure_days)) > 1, 10, (claim_closure_days_target / nullifzero(v.avg_claim_closure_days)) * 10), 2) as claim_closure_days_score10
from cte v
left join cte g
    on g.vendorid <> v.vendorid
        and g.vendor_type = v.vendor_type
left join vendor_types vt
    on vt.vendorid = v.vendorid
-- where v.vendor_type = 'Aerial'
group by 1,2,3,4,5, v.avg_claim_closure_days, vt.peers_avg_claim_closure_days
;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: adj_paid_amount {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.adj_paid_amount ;;
  }
  dimension: claim_total {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claim_total ;;
  }
  dimension: vendor_recovery_perc {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.vendor_recovery_perc ;;
  }
  dimension: peers_recovery_perc {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.peers_recovery_perc ;;
  }
  dimension: recovery_perc_target {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.recovery_perc_target ;;
  }
  dimension: recovery_perc_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.recovery_perc_score, 0) ;;
  }
  dimension: recovery_perc_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.recovery_perc_score10, 0) ;;
  }



  dimension: avg_claim_closure_days {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.avg_claim_closure_days ;;
  }
  dimension: peers_avg_claim_closure_days {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peers_avg_claim_closure_days ;;
  }
  dimension: claim_closure_days_target {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.claim_closure_days_target ;;
  }
  dimension: claim_closure_days_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.claim_closure_days_score, 0) ;;
  }
  dimension: claim_closure_days_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.claim_closure_days_score10, 0) ;;
  }

}
