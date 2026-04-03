view: net_terms_finance_status {
  sql_table_name: analytics."PUBLIC"."NET_TERMS_FINANCE_STATUS"
    ;;

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: net_terms_days {
    type: number
    sql: ${TABLE}."NET_TERMS_DAYS" ;;
  }

  dimension: net_terms_days_to_use {
    type: number
    sql: case when ${net_terms_days} is null then 30 else ${net_terms_days} end ;;
  }


  dimension: due_date {
    type: date
    sql: dateadd(day,${net_terms_days_to_use},${assets.purchase_created_date}) ;;
    #sql: add_days(${net_terms_days_to_use},${asset_purchase_created_date_snowflake.asset_purchase_created_date}) ;;
  }


  dimension: days_until_due {
    type: number
    #sql: DATE_PART('day', ${due_date}::timestamp - CURRENT_TIMESTAMP()::timestamp)  ;;
    #sql: datediff(day, ${due_date} , CURRENT_TIMESTAMP())  ;;
    sql: datediff(day, CURRENT_TIMESTAMP() , ${due_date})  ;;
  }




  dimension: due_days_buckets {

    sql:
     CASE
     WHEN ${days_until_due} <= 0  THEN '0 or Less: Past Due'
     WHEN ${days_until_due} between 1 and 30 THEN '1 - 30'
      WHEN ${days_until_due} between 31 and 60 THEN '31 - 60'
       WHEN ${days_until_due} between 61 and 90 THEN '61 - 90'
     ELSE '91+'
     END ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
