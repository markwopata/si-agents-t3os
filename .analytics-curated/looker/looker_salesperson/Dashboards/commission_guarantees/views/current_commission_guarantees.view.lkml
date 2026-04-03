view: current_commission_guarantees {
    derived_table: {
    sql: SELECT csd.*,
                DATEADD(MONTH, 1, csd.commission_start_date)::timestamp  AS payroll_commission_start_date,
                DATEADD(MONTH, 1, csd.guarantee_end_date)::timestamp     AS payroll_guarantee_end_date,
                u.email_address,
                u.first_name,
                u.last_name,
                cd.employee_title,
                cd.market_id,
                coalesce(cd.date_rehired,cd.date_hired)            AS hire_rehire_date,
                cd.date_terminated,
                row_number() over (partition by csd.salesperson_user_id order by commission_start_date desc) as row_num
          FROM analytics.public.commissions_salesperson_data csd
                 LEFT JOIN es_warehouse.public.users u
                 ON csd.salesperson_user_id = u.user_id
                 LEFT JOIN analytics.payroll.company_directory cd
                 ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
          WHERE payroll_commission_start_date >= current_date()
          QUALIFY row_num = 1;;
  }

  dimension: salesperson_user_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: full_name_with_ID {
    type: string
    sql: concat(${first_name},' ',${last_name},' - ',${salesperson_user_id}) ;;
  }

  dimension: full_name_with_dashboard_links {
    type: string
    sql: ${full_name_with_ID} ;;

    link: {
      label: "View Salesperson Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/5?Sales%20Rep={{ value | url_encode }}"
    # }
    # link: {
    #   label: "View Product Specialist Dashboard"
    #   url: "https://equipmentshare.looker.com/dashboards/575?Salesperson={{ value | url_encode }}"
    }
  }

  dimension: commission_type {
    type: string
    sql: ${TABLE}."COMMISSION_TYPE" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: guarantee_amount {
    type: number
    sql: ${TABLE}."GUARANTEE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension_group: guarantee_start_date {
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
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }

  dimension_group: guarantee_end_date {
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
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }

  dimension_group: commission_start_date {
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
    sql: ${TABLE}."COMMISSION_START_DATE" ;;
  }

  dimension_group: commission_end_date {
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
    sql: ${TABLE}."COMMISSION_END_DATE" ;;
  }

  dimension: email_address {
    type: date
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension_group: payroll_guarantee_end_date {
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
    sql: ${TABLE}."PAYROLL_GUARANTEE_END_DATE" ;;
  }

  dimension_group: payroll_commission_start_date {
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
    sql: ${TABLE}."PAYROLL_COMMISSION_START_DATE" ;;
  }

  dimension: change_request_deadline {
    type: date
    sql: date_trunc('month',${payroll_commission_start_date_raw}) ;;
  }

  dimension: make_change_request {
    type: number
    sql:  ${salesperson_user_id};;
    value_format_name: id
    html: <b><p style="color:#B32F37;"><a href="https://docs.google.com/forms/d/e/1FAIpQLSeRSBt1ErVeBVJlaYp3QMgEiCRI4rhnY9hWW5WmyIds0WVFyQ/viewform?usp=pp_url&entry.1214858295={{value}}&entry.749541817={{first_name._value}}&entry.852149733={{last_name._value}}&entry.691111867={{payroll_guarantee_end_date_date._value}}&entry.799768097={{guarantee_amount._value}}">Submit Change Request</a></p></b>;;
}
}
