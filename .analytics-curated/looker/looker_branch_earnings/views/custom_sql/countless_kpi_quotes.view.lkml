view: countless_kpi_quotes {
  derived_table: {
    sql:
with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
    select *
    from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs
    qualify row_number() over (
        partition by wacs.inventory_location_id, wacs.product_id, date_applied
        order by wacs.date_created desc)
                = 1
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

   , wac_history as (select *
                          , lead(DATE_APPLIED, 1) over (
        partition by PRODUCT_ID, INVENTORY_LOCATION_ID
        order by DATE_APPLIED asc) as date_end
                     from wac_prep),
part_margin as (
select q.BRANCH_ID,
       q.QUOTE_ID,
       et.PART_ID,
       et.EQUIPMENT_CLASS_ID,
       wacs.WEIGHTED_AVERAGE_COST,
       et.QUANTITY as number_of_units,
       avg(wac_history.WEIGHTED_AVERAGE_COST) as cw_wac,
from ANALYTICS.INTACCT_MODELS.STG_QUOTES_QUOTES__QUOTES q
left join quotes.quotes.quote_pricing qp
on q.QUOTE_ID = qp.QUOTE_ID
left join QUOTES.QUOTES.EQUIPMENT_TYPE et
on q.QUOTE_ID = et.QUOTE_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__INVENTORY_LOCATIONS il
on q.BRANCH_ID = il.MARKET_ID
and il.IS_DEFAULT_STORE = true
-- Joining on part id
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs -- join on part id and date
on et.PART_ID = wacs.PRODUCT_ID
and q.QUOTE_CREATED_AT::date = wacs.DATE_APPLIED::date
and il.STORE_ID = wacs.INVENTORY_LOCATION_ID
left join wac_history on et.part_id = wac_history.product_id
and q.QUOTE_CREATED_AT::date between wac_history.date_applied::date and coalesce(date_end::date, '9999-12-31')
-- Joining on equipment class - need to find a way to get average cost on these. These are actual equipment classes
-- left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs2 -- join on part id and date
-- on et.PART_ID = wacs.PRODUCT_ID
-- and q.QUOTE_CREATED_AT::date = wacs.DATE_APPLIED::date
-- and il.STORE_ID = wacs.INVENTORY_LOCATION_ID
-- left join wac_history wh2 on et.part_id = wh2.equipment_class_id
-- and q.QUOTE_CREATED_AT::date between wh2.date_applied::date and coalesce(date_end::date, '9999-12-31')
where et.equipment_class_id is null
group by et.PART_ID, et.EQUIPMENT_CLASS_ID, wacs.WEIGHTED_AVERAGE_COST, q.BRANCH_ID, q.QUOTE_ID, et.QUANTITY),
-- agging part_margin_agg because I don't know the rate type mapping to the possible rates (day, week, four week, etc. vs online, combo, bench, custom, etc.)
part_margin_agg as (
select pm.branch_id,
       pm.quote_id,
       sum(coalesce(pm.WEIGHTED_AVERAGE_COST,pm.cw_wac)) as weighted_average_cost,
       sum(coalesce(pm.WEIGHTED_AVERAGE_COST,pm.cw_wac) * NUMBER_OF_UNITS) as total_part_cost
from part_margin pm
group by pm.BRANCH_ID, pm.QUOTE_ID
)
select q.QUOTE_ID,
       q.QUOTE_NUMBER,
       qp.total,
       qp.SALE_ITEMS_SUBTOTAL,
       q.COMPANY_ID,
       q.COMPANY_NAME,
       q.LOCATION_DESCRIPTION,
       q.HAS_PDF,
       q.QUOTE_CREATED_AT,
       q.START_DATE,
       q.END_DATE,
       q.ORDER_CREATED_AT,
       ROUND(DATEDIFF(second, q.QUOTE_CREATED_AT, coalesce(q.ORDER_CREATED_AT,current_date)) / 86400.0, 2) as response_time_days,
       q.DELIVER_TO,
       q.PO_ID,
       q.PO_NAME,
       q.CONTACT_NAME,
       q.CONTACT_PHONE,
       q.CONTACT_EMAIL,
       q.BRANCH_ID,
       q.SALES_REP_ID,
       u.FULL_NAME,
       q.CREATED_BY as quote_created_by_user_id,
       u2.FULL_NAME  as quote_created_by_name,
--        et.PART_ID,
       weighted_average_cost,
       total_part_cost
from ANALYTICS.INTACCT_MODELS.STG_QUOTES_QUOTES__QUOTES q
left join quotes.quotes.quote_pricing qp
on q.QUOTE_ID = qp.QUOTE_ID
-- left join QUOTES.QUOTES.EQUIPMENT_TYPE et
-- on q.QUOTE_ID = et.QUOTE_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__USERS u
on q.SALES_REP_ID = u.USER_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__USERS u2
on q.CREATED_BY = u2.USER_ID
join part_margin_agg pma -- joining to eliminate quotes without retail parts
on q.QUOTE_ID = pma.QUOTE_ID;;
  }

  dimension: quote_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.QUOTE_ID ;;
  }

  dimension: quote_number {
    type: string
    sql: ${TABLE}.QUOTE_NUMBER ;;
  }

  dimension: total {
    type: number
    value_format_name: usd
    sql: ${TABLE}.TOTAL ;;
  }

  measure: total_sum {
    label: "Total Revenue"
    type: sum
    sql: ${total} ;;
    value_format_name: usd
  }

  measure: total_avg {
    type: average
    sql: ${total} ;;
  }

  measure: total_median {
    type: median
    sql: ${total} ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: location_description {
    type: string
    sql: ${TABLE}.LOCATION_DESCRIPTION ;;
  }

  dimension: has_pdf {
    type: yesno
    sql: ${TABLE}.HAS_PDF ;;
  }

  dimension_group: quote_created_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.QUOTE_CREATED_AT ;;
  }

  dimension_group: start_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.START_DATE ;;
  }

  dimension_group: end_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.END_DATE ;;
  }

  dimension_group: order_created_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ORDER_CREATED_AT ;;
  }

  dimension: response_time_days {
    type: number
    value_format: "0.00"
    sql: ${TABLE}.RESPONSE_TIME_DAYS ;;
  }

  measure: avg_response_time_days {
    type: average
    sql: ${response_time_days} ;;
    value_format_name: decimal_2
  }

  measure: p90_response_time_days {
    type: percentile
    percentile: 90
    sql: ${response_time_days} ;;
  }

  measure: max_response_time_days {
    type: max
    sql: ${response_time_days} ;;
  }

  measure: min_response_time_days {
    type: min
    sql: ${response_time_days} ;;
  }

  dimension: responded_same_day {
    type: yesno
    sql:
      CASE
        WHEN ${response_time_days} <= 1 THEN TRUE
        ELSE FALSE
      END ;;
  }

  measure: responded_same_day_rate {
    type: average
    value_format_name: decimal_2
    sql:
      CASE
        WHEN ${response_time_days} <= 1 THEN 1
        ELSE 0
      END ;;
  }

  dimension: deliver_to {
    type: string
    sql: ${TABLE}.DELIVER_TO ;;
  }

  dimension: po_id {
    type: string
    sql: ${TABLE}.PO_ID ;;
  }

  dimension: po_name {
    type: string
    sql: ${TABLE}.PO_NAME ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}.CONTACT_NAME ;;
  }

  dimension: contact_phone {
    type: string
    sql: ${TABLE}.CONTACT_PHONE ;;
  }

  dimension: contact_email_raw {
    hidden: yes
    type: string
    sql: ${TABLE}.CONTACT_EMAIL ;;
  }

  dimension: contact_email_link {
    type: string
    html: yes
          sql:
            CASE
              WHEN ${contact_email_raw} IS NOT NULL THEN
                CONCAT('<a href="mailto:', ${contact_email_raw}, '">', ${contact_email_raw}, '</a>')
              ELSE NULL
            END ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: sales_rep_id {
    type: number
    sql: ${TABLE}.SALES_REP_ID ;;
  }

  dimension: sales_rep_name {
    type: string
    sql: ${TABLE}.FULL_NAME ;;
  }

  dimension: quote_created_by_user_id {
    label: "Inside Employee ID"
    type: number
    sql: ${TABLE}.quote_created_by_user_id ;;
  }

  dimension: quote_created_by_name {
    label: "Inside Employee Name"
    type: string
    sql: ${TABLE}.quote_created_by_name ;;
  }

  measure: distinct_quotes {
    type: count_distinct
    sql: ${quote_id} ;;
  }

  dimension: weighted_average_cost {
    type: number
    sql: ${TABLE}.weighted_average_cost ;;
  }

  measure: weighted_average_cost_agg {
    label: "Weighted Average Cost (WAC)"
    type: sum
    sql: ${weighted_average_cost} ;;
  }

  dimension: total_part_cost {
    type: number
    sql: ${TABLE}.total_part_cost ;;
  }

  measure: total_part_cost_agg {
    label: "Total Estimated Cost"
    type: sum
    sql: ${total_part_cost} ;;
    value_format_name: usd
  }


  drill_fields:  [
    quote_number,
    company_name,
    sales_rep_name,
    total,
    response_time_days,
    contact_email_link
  ]
}
