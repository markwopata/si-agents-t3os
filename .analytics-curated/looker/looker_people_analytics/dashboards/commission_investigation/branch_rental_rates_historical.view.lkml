view: branch_rental_rates_historical {

  sql_table_name: ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES ;;

  dimension: branch_rental_rate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.BRANCH_RENTAL_RATE_ID ;;
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}.RATE_TYPE_ID ;;
  }

  dimension: rate_type {
    type: string
    sql:
      CASE ${TABLE}.RATE_TYPE_ID
        WHEN 1 THEN 'Book'
        WHEN 2 THEN 'Bench'
        WHEN 3 THEN 'Floor'
      END ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension_group: date_voided {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}.DATE_VOIDED ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}.PRICE_PER_HOUR ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}.PRICE_PER_DAY ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}.PRICE_PER_WEEK ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}.PRICE_PER_MONTH ;;
  }
}
