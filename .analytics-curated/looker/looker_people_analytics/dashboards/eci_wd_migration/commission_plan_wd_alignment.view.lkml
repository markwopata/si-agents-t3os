
view: commission_plan_wd_alignment {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."COMMISSION_PLAN_WD_ALIGNMENT" ;;


  dimension: employee_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: worker {
    type: string
    sql: ${TABLE}.WORKER ;;

    link: {
      label: "Open Workday Employee Compensation"
      url: "https://wd5.myworkday.com/equipmentshare/d/inst/1$worker/{{ id._value }}.htmld#TABTASKID=2998%246374"
    }

    link: {
      label: "Open Workday Employee Documents"
      url: "https://wd5.myworkday.com/equipmentshare/d/inst/1$worker/{{ id._value }}.htmld#TABTASKID=2998%243380"
    }

    link: {
      label: "Open Compensation Request Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/2622?Employee%20ID={{ employee_id._value }}"
    }
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}.EMPLOYEE_STATUS ;;
  }

  dimension_group: date_terminated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_TERMINATED ;;
  }

  dimension_group: date_hired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_TERMINATED ;;
  }

  dimension_group: date_rehired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_TERMINATED ;;
  }

  dimension: compensation_plan_type {
    type: string
    sql: ${TABLE}.COMPENSATION_PLAN_TYPE ;;
  }

  dimension: compensation_plan {
    type: string
    sql: ${TABLE}.COMPENSATION_PLAN ;;
  }

  dimension_group: wd_start_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.WD_START_DATE ;;
  }

  dimension_group: wd_end_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.WD_END_DATE ;;
  }

  dimension_group: eci_start_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ECI_START_DATE ;;
  }

  dimension_group: eci_end_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ECI_END_DATE ;;
  }

  dimension: start_date_match_flag {
    type: yesno
    sql: ${wd_start_date_date} = ${eci_start_date_date} ;;
  }

  dimension: end_date_match_flag {
    type: yesno
    sql: ${wd_end_date_date} = ${eci_end_date_date} ;;
  }

  dimension: missing_eci_start_date_flag {
    type: yesno
    sql: ${eci_start_date_date} IS NULL ;;
  }

  dimension: missing_eci_end_date_flag {
    type: yesno
    sql: ${eci_end_date_date} IS NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [
      employee_id,
      user_id,
      worker,
      employee_status,
      compensation_plan,
      wd_start_date_date,
      wd_end_date_date,
      eci_start_date_date,
      eci_end_date_date
    ]
  }

  measure: matched_start_date_count {
    type: count
    filters: [start_date_match_flag: "yes"]
  }

  measure: mismatched_start_date_count {
    type: count
    filters: [start_date_match_flag: "no"]
  }

  measure: matched_end_date_count {
    type: count
    filters: [end_date_match_flag: "yes"]
  }

  measure: mismatched_end_date_count {
    type: count
    filters: [end_date_match_flag: "no"]
  }
}
