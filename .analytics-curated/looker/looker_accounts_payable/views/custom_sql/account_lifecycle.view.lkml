view: account_lifecycle {

  derived_table: {
    sql:
      select
        cca.company_id,
        company_name,
        market_name,
        t.account_created_date,
        max(snapshot_date) snapshot_date
      from analytics.bi_ops.collector_customer_assignments_daily_snapshot cca
      left join (
      select company_id, min(date_created) account_created_date from es_warehouse.public.users group by company_id
      ) t
      on cca.company_id = t.company_id
      group by 1,2,3,4

      ;;
  }


  # =========================
  # 🏢 Company Info
  # =========================

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;

    link: {
      label: "Drill Sorted"
      url: "/explore/account_lifecycle/account_lifecycle?fields=account_lifecycle.company_id,account_lifecycle.company_name,account_lifecycle_details.collector_type,account_lifecycle_details.window_start_date,account_lifecycle_details.window_end_date,account_lifecycle_details.window_length_days&f[account_lifecycle.company_id]={{ value }}&sorts=account_lifecycle_details.window_start_date+asc"
    }
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  # =========================
  # 📅 Dates
  # =========================

  dimension_group: snapshot_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.window_start_date ;;
  }

  dimension_group: account_created {
    group_label: "Account Created"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.account_created_date ;;
  }

  measure: count {
    type: count
  }


}
