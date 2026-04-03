
view: salesperson_general_information {
  derived_table: {
    sql:
    SELECT
          si.name,
          si.email_address,
          si.employee_id,
          si.user_id,
          si.direct_manager_email_present,
          si.date_hired_initial,
          si.date_rehired_present,
          si.employee_title_dated,
          si.home_market_dated,
          si.first_date_as_TAM
    FROM
          analytics.bi_ops.salesperson_info si
    WHERE record_ineffective_date IS NULL AND employee_status_present = 'Active'

;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: direct_manager_email_present {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL_PRESENT" ;;
  }

  dimension: date_hired_initial {
    type: date
    sql: ${TABLE}."DATE_HIRED_INITIAL" ;;
  }

  dimension: date_rehired_present {
    type: date
    sql: ${TABLE}."DATE_REHIRED_PRESENT" ;;
  }

  dimension: employee_title_dated {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: first_date_as_TAM {
    type: date
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: home_market_dated {
    type: string
    sql: ${TABLE}."HOME_MARKET_DATED" ;;
  }

  dimension: rep_and_market {
    type: string
    sql: concat(${name}, ' - ', ${home_market_dated}) ;;
    html:
    <b>{{ name._rendered_value }}</b> - <font style="color: #8C8C8C; text-align: right;">{{ home_market_dated._rendered_value }}</font> ;;
  }

  dimension: formatted_date_hired_initial {
    type: date
    sql: ${date_hired_initial} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_date_rehired {
    type: date
    sql: ${date_rehired_present} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_first_date_TAM {
    type:  date
    sql:  ${first_date_as_TAM} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: start_date {
    type: date
    sql: IFF(${date_rehired_present} is not null,${formatted_date_rehired},${formatted_date_hired_initial}) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }


  set: detail {
    fields: [
        name,
  email_address,
  employee_id,
  user_id,
  direct_manager_email_present,
  date_hired_initial,
  date_rehired_present,
  employee_title_dated
    ]
  }
}
