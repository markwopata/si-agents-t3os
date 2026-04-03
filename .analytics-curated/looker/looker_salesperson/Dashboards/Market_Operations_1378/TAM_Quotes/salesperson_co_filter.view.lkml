view: salesperson_co_filter {
  derived_table: {
    sql: SELECT DISTINCT
      q.company_id,
      q.company_name,
      q.sales_rep_id as salesperson_user_id,
      concat(si.name, ' - ', COALESCE(si.home_market_dated, concat('District ', si.district_dated), si.region_name_dated) ) as rep_location

      FROM quotes.quotes.quote q
      LEFT JOIN analytics.bi_ops.salesperson_info si ON q.sales_rep_id = si.user_id and record_ineffective_date IS NULL
      WHERE created_date >= dateadd(day, '-30', CONVERT_TIMEZONE('America/Chicago', current_timestamp)::DATE) OR order_created_date >= dateadd(day, '-30', CONVERT_TIMEZONE('America/Chicago', current_timestamp)::DATE)
       ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: rep_location {
    type: string
    sql: ${TABLE}."REP_LOCATION" ;;
  }


}
