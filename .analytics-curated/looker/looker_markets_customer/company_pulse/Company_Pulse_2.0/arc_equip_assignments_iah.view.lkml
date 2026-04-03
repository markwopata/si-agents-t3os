view: arc_equip_assignments_iah {
  sql_table_name: business_intelligence.triage.stg_bi__daily_actively_renting_customers
          -- YOU CAN ONLY SUM UP THE OEC OR ASSETS ON RENT AT THE COMPANY LEVEL WITH THIS SOURCE.
        -- USE MARKET LEVEL ASSET METRICS DAILY FOR OEC/AOR MARKET/DISTRICT/REGION/COMPANY NUMBERS
        ;;

    dimension_group: date {
      type: time
      sql: ${TABLE}."DATE" ;;
    }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month {
    group_label: "HTML Formatted Date"
    label: "Month Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${date_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

    dimension: asset_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    measure: asset_count {
      label: "Assets On Rent"
      type: count_distinct
      sql: ${asset_id} ;;
    }

    dimension: oec {
      group_label: "Asset Information"
      type: number
      sql: ${TABLE}."OEC" ;;
    }

    measure: oec_sum {
      label: "OEC"
      type: sum
      sql: ${oec} ;;
      value_format_name: usd_0
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension_group: date_start {
      type: time
      sql: ${TABLE}."DATE_START" ;;
    }

    dimension_group: date_end {
        type: time
    sql: ${TABLE}."DATE_END" ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: company_name {
      type: string
      sql: ${TABLE}."COMPANY_NAME" ;;
      html: {{rendered_value}} <br>
      Company ID: {{company_id._value}};;
    }

  dimension: is_current_day {
    type: yesno
    sql: current_date = ${TABLE}."DATE" ;;
  }

  dimension: is_yesterday {
    type: yesno
    sql: ${TABLE}."DATE" = DATEADD(day, -1,current_date)  ;;
  }

  dimension: is_last_30_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_30_DAYS" ;;
  }

  dimension: is_last_31_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_31_DAYS" ;;
  }

  dimension: is_last_60_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_60_DAYS" ;;
  }

  dimension: is_last_90_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_90_DAYS" ;;
  }

  dimension: is_prior_month_to_date {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_MONTH_TO_DATE" ;;
  }

  dimension: is_prior_month {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_MONTH" ;;
  }

  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }

  dimension: is_first_day_of_month {
    type: yesno
    sql: ${TABLE}."IS_FIRST_DAY_OF_MONTH" ;;
  }

  dimension: is_last_day_of_month {
    type: yesno
    sql: ${TABLE}."IS_LAST_DAY_OF_MONTH" ;;
  }

  measure: actively_renting_customers {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [arc_details*]
  }

  measure: avg_actively_renting_customers {
    type: number
    sql:  SUM(${actively_renting_customers})/COUNT(DISTINCT ${date_date}) ;;
    value_format_name: decimal_1
  }


  measure: max_actively_renting_customers {
    type: max
    sql:  ${actively_renting_customers} ;;
  }

  set: arc_details {
    fields: [market_region_xwalk.market_name, company_name, asset_count, oec_sum]
  }

}
