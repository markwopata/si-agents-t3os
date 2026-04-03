view: wac_by_part_and_branch {
 derived_table: {
   sql: with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
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
                     from wac_prep)

select li.BRANCH_ID,
       li.PART_ID,
       li.LINE_ITEM_ID,
       li.AMOUNT,
       wacs.WEIGHTED_AVERAGE_COST,
       avg(wac_history.WEIGHTED_AVERAGE_COST) as cw_wac
from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__LINE_ITEMS li
         left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__INVENTORY_LOCATIONS il
                   on li.BRANCH_ID = il.MARKET_ID
                    and il.IS_DEFAULT_STORE = true
         left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs -- join on part id and date
                   on li.PART_ID = wacs.PRODUCT_ID
                       and li.DATE_CREATED::date = wacs.DATE_APPLIED::date
                       and il.STORE_ID = wacs.INVENTORY_LOCATION_ID
         left join wac_history on li.part_id = wac_history.product_id
    and li.date_created::date between wac_history.date_applied::date and coalesce(date_end::date, '9999-12-31')
group by li.PART_ID, li.AMOUNT, wacs.WEIGHTED_AVERAGE_COST, li.BRANCH_ID, li.LINE_ITEM_ID; ;;
 }

  dimension: line_item_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.line_item_id ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}.part_id ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: amount {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.amount ;;
  }

  dimension: weighted_average_cost {
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.weighted_average_cost ;;
  }

  dimension: cw_wac {
    label: "Current Window WAC"
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.cw_wac ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, part_id, branch_id]
  }

  measure: distinct_parts {
    type: count_distinct
    sql: ${part_id} ;;
  }

  measure: distinct_branches {
    type: count_distinct
    sql: ${branch_id} ;;
  }

  measure: sum_amount {
    label: "Total Amount"
    type: sum
    value_format_name: decimal_2
    sql: ${amount} ;;
    group_label: "Line Item"
  }

  measure: avg_point_wac {
    label: "Point-in-Time WAC"
    type: sum
    value_format_name: decimal_4
    sql: ${weighted_average_cost} ;;
  }

  measure: avg_window_wac {
    label: "Avg Window WAC"
    type: sum
    value_format_name: decimal_4
    sql: ${cw_wac} ;;
  }

  measure: total_cost_point_wac {
    label: "Weighted Average Cost"
    description: "If there is no real WAC that matches on date, use average WAC for part and branch."
    type: number
    value_format_name: decimal_2
    sql: coalesce(${weighted_average_cost},${cw_wac}) ;;
  }

}
