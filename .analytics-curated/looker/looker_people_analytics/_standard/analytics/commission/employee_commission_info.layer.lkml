include: "/_base/analytics/commission/employee_commission_info.view.lkml"


view: +employee_commission_info {
  label: "Employee Commission Info"

  dimension: employee_commission_info_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYEE_COMMISSION_INFO_ID" ;;
    hidden: yes
  }
  dimension_group: commission_end {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${commission_end};;
  }
  dimension_group: commission_start {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${commission_start} ;;
  }
  dimension: commission_type_id {
    value_format_name:id
  }
  dimension_group: date_updated {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: guarantee_amount {
    value_format_name: usd
  }
  dimension_group: guarantee_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${guarantee_end} ;;
  }
  dimension_group: guarantee_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${guarantee_start} ;;
  }
  dimension: user_id {
    value_format_name:id
  }

}
