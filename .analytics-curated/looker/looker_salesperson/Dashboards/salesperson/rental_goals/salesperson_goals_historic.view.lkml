view: salesperson_goals_historic {
  sql_table_name: "BI_OPS"."SALESPERSON_GOALS_HISTORIC" ;;

  dimension_group: date_goal_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GOAL_CREATED" ;;
  }

  dimension: direct_manager_user_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: in_district_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."IN_DISTRICT_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: in_market_goal {
    type: number
    sql: ${TABLE}."IN_MARKET_GOAL" ;;
  }

  dimension: in_market_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."IN_MARKET_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: out_district_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."OUT_DISTRICT_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: out_market_goal {
    type: number
    sql: ${TABLE}."OUT_MARKET_GOAL" ;;
  }

  dimension: out_market_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."OUT_MARKET_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: revenue_goal {
    type: number
    sql: ${TABLE}."REVENUE_GOAL" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: sp_district_present {
    type: string
    sql: ${TABLE}."SP_DISTRICT_PRESENT" ;;
  }

  dimension_group: sp_hire {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SP_HIRE_DATE" ;;
  }

  dimension: sp_jurisdiction_present {
    type: string
    sql: ${TABLE}."SP_JURISDICTION_PRESENT" ;;
  }

  dimension: sp_market_id_present {
    type: string
    sql: ${TABLE}."SP_MARKET_ID_PRESENT" ;;
  }

  dimension: sp_market_present {
    type: string
    sql: ${TABLE}."SP_MARKET_PRESENT" ;;
  }

  dimension: sp_region_present {
    type: string
    sql: ${TABLE}."SP_REGION_PRESENT" ;;
  }

  dimension_group: start_date_as_sp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE_AS_SP" ;;
  }

  dimension: tam_goal_id {
    type: number
    sql: ${TABLE}."TAM_GOAL_ID" ;;
  }

  dimension: total_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: total_in_market_revenue {
    type: sum
    sql: ${in_market_monthly_rental_revenue} ;;
    value_format_name: usd
  }

  measure: total_out_of_market_revenue {
    type: sum
    sql: ${out_market_monthly_rental_revenue} ;;
    value_format_name: usd
  }

  measure: count {
    type: count
  }

  dimension: month_name {
    type: string
    sql: ${month} ;;
    html: {% if value == 1 %}
      Jan
    {% elsif value == 2 %}
      Feb
    {% elsif value == 3 %}
      Mar
    {% elsif value == 4 %}
      Apr
    {% elsif value == 5 %}
      May
    {% elsif value == 6 %}
      Jun
    {% elsif value == 7 %}
      Jul
    {% elsif value == 8 %}
      Aug
    {% elsif value == 9 %}
      Sep
    {% elsif value == 10 %}
      Oct
    {% elsif value == 11 %}
      Nov
    {% elsif value == 12 %}
      Dec
    {% else %}
      Out of Range
    {% endif %};;
  }

  dimension: mmm_yyyy {
    label: "Month Year"
    type: date
    sql: DATEFROMPARTS(${year}, ${month}, 1);;
    html: {{rendered_value | date: "%b %Y"}} ;;
  }
}
