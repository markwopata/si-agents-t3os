view: rental_part_assignments {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTAL_PART_ASSIGNMENTS" ;;
  drill_fields: [rental_part_assignment_id]

  dimension: rental_part_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_PART_ASSIGNMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: from_inventory_transaction_id {
    type: number
    sql: ${TABLE}."FROM_INVENTORY_TRANSACTION_ID" ;;
  }
  dimension: currently_on_rent { #need to verify this works as expected; ka edited 12-10-25
    type: yesno
    sql: current_date() between ${start_date}::date and coalesce(${end_date}::date,'2099-12-31') ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: quantity_purchased {
    type: number
    sql: case when ${TABLE}."QUANTITY_PURCHASED" is not null then ${TABLE}."QUANTITY_PURCHASED" else 0 end ;;
  }
  dimension: quantity_returned {
    type: number
    sql: case when ${TABLE}."QUANTITY_RETURNED" is not null then ${TABLE}."QUANTITY_RETURNED" else 0 end ;;

  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: rental_link {
    type: string
    sql: 'https://admin.equipmentshare.com/#/home/rentals/'||${rental_id}||'' ;;
  }
  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: to_inventory_transaction_id {
    type: number
    sql: ${TABLE}."TO_INVENTORY_TRANSACTION_ID" ;;
  }
  measure: count {
    type: count
  }
  measure: units_on_rent {
    type: sum
    sql: zeroifnull(${quantity}) - zeroifnull(${quantity_returned}) ;;
  }
}
