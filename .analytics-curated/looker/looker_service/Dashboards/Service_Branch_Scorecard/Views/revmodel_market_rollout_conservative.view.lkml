view: revmodel_market_rollout_conservative {
  derived_table: {
    sql: SELECT  r._ROW
                , r.MARKET_LEVEL
                , r.FINANCING_START_MONTH
                , r.MARKET_END_MONTH
                , r.XERO_MARKET_NAME
                , r.MARKET_ID
                , r.MARKET_START_MONTH
                , COALESCE(x.MARKET_NAME, r.MARKET_NAME) AS MARKET_NAME
                , r.MODEL_NAME
                , r.SALES_MODEL
                , r.SALE_LEASEBACK_MONTH
                , r.SALES_START_MONTH
                , r.MARKET_FACTOR
                , r.OUTSIDE_SERVICE_START_MONTH
                , r.OUTSIDE_SERVICE_MODEL
                , r._FIVETRAN_SYNCED
                , r.SALE_LEASEBACK
                , r.RENTAL_MODEL_START_MONTH
                --, r.FVV
                , r.BRANCH_EARNINGS_START_MONTH

      FROM    ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE r
      LEFT OUTER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK x
      ON r.MARKET_ID = x.MARKET_ID

      WHERE   r.MARKET_ID BETWEEN 0 AND 500000
      AND r.MARKET_ID != 15967
      ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension_group: financing_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FINANCING_START_MONTH" ;;
  }

  dimension_group: market_end_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MARKET_END_MONTH" ;;
  }

  dimension: market_factor {
    type: number
    sql: ${TABLE}."MARKET_FACTOR" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }

  dimension: market_level {
    type: number
    sql: ${TABLE}."MARKET_LEVEL" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: market_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }

  dimension: market_start_date_formatted {
    type: string
    label: "Market Start Month"
    sql: to_varchar(${TABLE}."BRANCH_EARNINGS_START_MONTH"::date, 'MMMM yyyy') ;;
  }

  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }

  dimension: branch_earnings_date_formatted {
    type: string
    label: "Branch Earnings Start Month"
    sql: to_varchar(${TABLE}."BRANCH_EARNINGS_START_MONTH"::date, 'MMMM yyyy') ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${TABLE}."BRANCH_EARNINGS_START_MONTH", current_date)+1 ;;
  }

  # dimension: greater_twelve_months_open {
  #   type: string
  #   sql: case when ${months_open} >= 12 then '>12 Months Open'
  #         else '<12 Months Open'
  #         end;;
  # }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  dimension: month_three_open {
    label: "Market Month 3"
    type: string
    sql: to_varchar(dateadd(month, +2, date(${TABLE}."BRANCH_EARNINGS_START_MONTH")), 'MMMM yyyy');;
    #Only added +2 months because market_start_month is month 1
  }

  dimension: month_six_open {
    label: "Market Month 6"
    type: string
    sql: to_varchar(dateadd(month, +5, date(${TABLE}."BRANCH_EARNINGS_START_MONTH")), 'MMMM yyyy');;
    #Only added +5 months because market_start_month is month 1
  }

  dimension: month_nine_open {
    label: "Market Month 9"
    type: string
    sql: to_varchar(dateadd(month, +8, date(${TABLE}."BRANCH_EARNINGS_START_MONTH")), 'MMMM yyyy');;
    #Only added +8 months because market_start_month is month 1
  }

  dimension: month_twelve_open {
    label: "Market Month 12"
    type: string
    sql: to_varchar(dateadd(month, +11, date(${TABLE}."BRANCH_EARNINGS_START_MONTH")), 'MMMM yyyy');;
    #Only added +11 months because market_start_month is month 1
  }

  dimension: model_name {
    type: string
    sql: ${TABLE}."MODEL_NAME" ;;
  }

  dimension: outside_service_model {
    type: string
    sql: ${TABLE}."OUTSIDE_SERVICE_MODEL" ;;
  }

  dimension_group: outside_service_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OUTSIDE_SERVICE_START_MONTH" ;;
  }

  dimension_group: rental_model_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_MODEL_START_MONTH" ;;
  }

  dimension: sale_leaseback {
    type: number
    sql: ${TABLE}."SALE_LEASEBACK" ;;
  }

  dimension: sale_leaseback_month {
    type: string
    sql: ${TABLE}."SALE_LEASEBACK_MONTH" ;;
  }

  dimension: sales_model {
    type: string
    sql: ${TABLE}."SALES_MODEL" ;;
  }

  dimension_group: sales_start_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SALES_START_MONTH" ;;
  }

  dimension: xero_market_name {
    type: string
    sql: ${TABLE}."XERO_MARKET_NAME" ;;
  }

  dimension: new_market_review_status {
    label: "New Market Review Status"
    type: string
    sql: case when ${branch_earnings_start_month_date} is null and ${market_start_month_date} is null then 'Needs Market & Branch Start Date'
              when ${branch_earnings_start_month_date} is null and ${market_start_month_date} is not null then 'Needs Branch Start Date Only'
              when ${branch_earnings_start_month_date} is not null and ${market_start_month_date} is null then 'Needs Market Start Date Only'
              else 'No Action Needed' end;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, xero_market_name, model_name]
  }
}
