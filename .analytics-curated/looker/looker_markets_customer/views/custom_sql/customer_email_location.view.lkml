view: customer_email_location {
  derived_table: {
    sql:    select c.COMPANY_ID, c.name , u.EMAIL_ADDRESS
            from ES_WAREHOUSE.PUBLIC.COMPANIES as c
            left join ES_WAREHOUSE.PUBLIC.users as u
            on c.OWNER_USER_ID = u.user_id;;
  }



  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: number
    sql: ${TABLE}.NAME ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.EMAIL_ADDRESS ;;
  }}
