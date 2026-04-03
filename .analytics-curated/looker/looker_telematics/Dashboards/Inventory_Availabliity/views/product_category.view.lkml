view: product_category {
  derived_table: {
    sql: select *
         from ANALYTICS.FISHBOWL_STAGING.PRODUCT_CATEGORY
         where reportdate in (select max(reportdate) from ANALYTICS.FISHBOWL_STAGING.PRODUCT_CATEGORY);;
  }
  #sql_table_name: "ANALYTICS"."FISHBOWL_STAGING"."PRODUCT_CATEGORY" ;;

  dimension: partid {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: part {
    type: string
    sql: ${TABLE}."PART" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: reportdate {
    type: time
    timeframes: [date, week, month, time]
    sql:  ${TABLE}."REPORTDATE" ;;
    convert_tz: no
  }

  }
