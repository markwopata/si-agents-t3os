
view: customer_service_es_admin_actions {
  derived_table: {
    sql: select
            concat(cd.first_name,' ',cd.last_name) as full_name,
            u.EMAIL_ADDRESS,
            cd.employee_id as cs_compnay_directory_id,
            ca.user_id as cs_T3_user_id,
            cd.location as company_directory_location,
            ca.command,
            ca.parameters,
            ca.date_created,
            parameters:asset_id as asset_id,
            parameters:company_id as customer_company_id,
            parameters:rental_id as rental_id,
            parameters:order_id as order_id,
            c.name as company_name,
            cd.employee_title as cs_employee_title,
            cd.direct_manager_employee_id as cs_direct_manager_employee_id,
            cd.direct_manager_name as cs_direct_manager_name
            from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT CA
            left join ES_WAREHOUSE.PUBLIC.companies c on (c.company_id = ca.parameters:company_id )
            left join ES_WAREHOUSE.PUBLIC.USERS U on (CA.USER_ID = u.USER_ID)
            left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on (cd.work_email = u.email_address)
            where
            cd.location = 'Customer Support'
            and CA.DATE_CREATED >= dateadd(day, -30, current_timestamp)
            order by CA.DATE_CREATED ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: cs_compnay_directory_id {
    type: number
    sql: ${TABLE}."CS_COMPNAY_DIRECTORY_ID" ;;
  }

  dimension: cs_t3_user_id {
    type: number
    sql: ${TABLE}."CS_T3_USER_ID" ;;
  }

  dimension: company_directory_location {
    type: string
    sql: ${TABLE}."COMPANY_DIRECTORY_LOCATION" ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: customer_company_id {
    type: string
    sql: ${TABLE}."CUSTOMER_COMPANY_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: cs_employee_title {
    type: string
    sql: ${TABLE}."CS_EMPLOYEE_TITLE" ;;
  }

  dimension: cs_direct_manager_employee_id {
    type: string
    sql: ${TABLE}."CS_DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: cs_direct_manager_name {
    type: string
    sql: ${TABLE}."CS_DIRECT_MANAGER_NAME" ;;
  }

  set: detail {
    fields: [
      full_name,
      email_address,
      cs_compnay_directory_id,
      cs_t3_user_id,
      company_directory_location,
      command,
      parameters,
      date_created_time,
      asset_id,
      customer_company_id,
      rental_id,
      order_id,
      company_name,
      cs_employee_title,
      cs_direct_manager_employee_id,
      cs_direct_manager_name
    ]
  }
}
