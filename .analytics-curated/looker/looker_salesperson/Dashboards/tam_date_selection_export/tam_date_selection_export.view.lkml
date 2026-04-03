
view: tam_date_selection_export {
  derived_table: {
    sql: select
      'current' as metric_selection,
      salesperson_user_id,
      sp_full_name,
      sum(assets_on_rent) as assets_on_rent,
      sum(oec_on_rent) as oec_on_rent
      from
      analytics.bi_ops.daily_sp_market_rollup
      where
      --sp_full_name = 'Katie Laxson' --injection from query value
      {% condition rep_filter %} sp_full_name {% endcondition %}
      AND date = DATE_FROM_PARTS( {% parameter current_year %}, {% parameter current_month %}, {% parameter current_day %} )
      group by
      salesperson_user_id,
      sp_full_name
      UNION
      select
      'historical' as metric_selection,
      salesperson_user_id,
      sp_full_name,
      sum(assets_on_rent) as assets_on_rent,
      sum(oec_on_rent) as oec_on_rent
      from
      analytics.bi_ops.daily_sp_market_rollup
      where
      --sp_full_name = 'Katie Laxson' --injection from query value
      {% condition rep_filter %} sp_full_name {% endcondition %}
      AND date = DATE_FROM_PARTS( {% parameter historical_year %}, {% parameter historical_month %}, {% parameter historical_day %} )
      group by
      salesperson_user_id,
      sp_full_name ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: metric_selection {
    type: string
    sql: ${TABLE}."METRIC_SELECTION" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sp_full_name {
    type: string
    sql: ${TABLE}."SP_FULL_NAME" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: total_assets_on_rent {
    type: sum
    sql: ${assets_on_rent} ;;
  }

  measure: total_oec_on_rent {
    label: "Total OEC on Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }

  parameter: current_month {
    label: "Current Month"
    type: number
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: current_day {
    label: "Current Day"
    type: number
    allowed_value: {
      value: "1"
    }
    allowed_value: {
      value: "2"
    }
    allowed_value: {
      value: "3"
    }
    allowed_value: {
      value: "4"
    }
    allowed_value: {
      value: "5"
    }
    allowed_value: {
      value: "6"
    }
    allowed_value: {
      value: "7"
    }
    allowed_value: {
      value: "8"
    }
    allowed_value: {
      value: "9"
    }
    allowed_value: {
      value: "10"
    }
    allowed_value: {
      value: "11"
    }
    allowed_value: {
      value: "12"
    }
    allowed_value: {
      value: "13"
    }
    allowed_value: {
      value: "14"
    }
    allowed_value: {
      value: "15"
    }
    allowed_value: {
      value: "16"
    }
    allowed_value: {
      value: "17"
    }
    allowed_value: {
      value: "18"
    }
    allowed_value: {
      value: "19"
    }
    allowed_value: {
      value: "20"
    }
    allowed_value: {
      value: "21"
    }
    allowed_value: {
      value: "22"
    }
    allowed_value: {
      value: "23"
    }
    allowed_value: {
      value: "24"
    }
    allowed_value: {
      value: "25"
    }
    allowed_value: {
      value: "26"
    }
    allowed_value: {
      value: "27"
    }
    allowed_value: {
      value: "28"
    }
    allowed_value: {
      value: "29"
    }
    allowed_value: {
      value: "30"
    }
    allowed_value: {
      value: "31"
    }
  }

  parameter: current_year {
    label: "Current Year"
    type: number
    allowed_value: {value: "2024"}
    allowed_value: {value: "2023"}
  }

  parameter: historical_month {
    label: "Historical Month"
    type: number
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: historical_day {
    label: "Historical Day"
    type: number
    allowed_value: {
      value: "1"
    }
    allowed_value: {
      value: "2"
    }
    allowed_value: {
      value: "3"
    }
    allowed_value: {
      value: "4"
    }
    allowed_value: {
      value: "5"
    }
    allowed_value: {
      value: "6"
    }
    allowed_value: {
      value: "7"
    }
    allowed_value: {
      value: "8"
    }
    allowed_value: {
      value: "9"
    }
    allowed_value: {
      value: "10"
    }
    allowed_value: {
      value: "11"
    }
    allowed_value: {
      value: "12"
    }
    allowed_value: {
      value: "13"
    }
    allowed_value: {
      value: "14"
    }
    allowed_value: {
      value: "15"
    }
    allowed_value: {
      value: "16"
    }
    allowed_value: {
      value: "17"
    }
    allowed_value: {
      value: "18"
    }
    allowed_value: {
      value: "19"
    }
    allowed_value: {
      value: "20"
    }
    allowed_value: {
      value: "21"
    }
    allowed_value: {
      value: "22"
    }
    allowed_value: {
      value: "23"
    }
    allowed_value: {
      value: "24"
    }
    allowed_value: {
      value: "25"
    }
    allowed_value: {
      value: "26"
    }
    allowed_value: {
      value: "27"
    }
    allowed_value: {
      value: "28"
    }
    allowed_value: {
      value: "29"
    }
    allowed_value: {
      value: "30"
    }
    allowed_value: {
      value: "31"
    }
  }

  parameter: historical_year {
    label: "Historical Year"
    type: number
    allowed_value: {value: "2024"}
    allowed_value: {value: "2023"}
  }

  filter: rep_filter {
  }

  set: detail {
    fields: [
        metric_selection,
  salesperson_user_id,
  assets_on_rent,
  oec_on_rent
    ]
  }
}
