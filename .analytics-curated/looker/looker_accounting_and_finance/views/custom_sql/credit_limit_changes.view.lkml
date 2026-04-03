view: credit_limit_changes {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.TREASURY.CREDIT_LIMIT_CHANGES;;
  }

  dimension: change_date {
    type: string
    sql: ${TABLE}."CHANGE_DATE" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ credit_limit_changes.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: prior_credit_limit {
    type: number
    sql: ${TABLE}."PRIOR_CREDIT_LIMIT" ;;
  }

  dimension: updated_credit_limit {
    type: number
    sql: ${TABLE}."UPDATED_CREDIT_LIMIT" ;;
  }


  }
