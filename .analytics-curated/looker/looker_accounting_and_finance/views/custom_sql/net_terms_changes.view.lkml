view: net_terms_changes {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.TREASURY.NET_TERMS_CHANGES;;
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
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ net_terms_changes.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: new_net_terms_id {
    type: number
    sql: ${TABLE}."NEW_NET_TERMS_ID" ;;
  }

  dimension: old_net_terms_id {
    type: number
    sql: ${TABLE}."OLD_NET_TERMS_ID" ;;
  }

  dimension: prior_net_terms {
    type: string
    sql: ${TABLE}."PRIOR_NET_TERMS" ;;
  }

  dimension: updated_net_terms {
    type: string
    sql: ${TABLE}."UPDATED_NET_TERMS" ;;
  }



  }
