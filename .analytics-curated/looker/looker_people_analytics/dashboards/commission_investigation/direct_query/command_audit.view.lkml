view: command_audit {

  filter: line_item_id { type: number }

  derived_table: {
    sql:
      select cali._ES_UPDATE_TIMESTAMP,
       COMMAND_AUDIT_ID,
       cali.USER_ID as updated_by_user_id,
       concat(u.FIRST_NAME, ' ', u.LAST_NAME)                                                         as FULL_NAME,
       u.EMAIL_ADDRESS                                                                                as email_address,
       cd.EMPLOYEE_TITLE                                                                              as EMPLOYEE_TITLE,
       COMMAND,
       PARAMETERS,
       cali.DATE_CREATED,
       AUDIT_EVENT_SOURCE_ID,
       IDENTITY_ID,
       PARAMETERS:line_item_id::int                                                                   as line_item_id_,
       coalesce(parameters:changes:pricePerUnit::number, parameters:changes:price_per_unit::decimal)  as price_per_unit,
       coalesce(parameters:changes:numberofUnit::number, parameters:changes:number_of_units::decimal) as quantity
      from analytics.commission.command_audit_line_item cali
         left join ES_WAREHOUSE.PUBLIC.USERS u on cali.USER_ID = u.USER_ID
         left join analytics.PAYROLL.COMPANY_DIRECTORY cd on cd.WORK_EMAIL = u.EMAIL_ADDRESS
      where {% condition line_item_id %} PARAMETERS:line_item_id::int {% endcondition %}
      OR {% condition line_item_id %} PARAMETERS:lineItemId::int {% endcondition %}
      order by command_audit_id ;;
  }

  # --- Keys / identifiers ---
  dimension: command_audit_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.command_audit_id ;;
  }

  dimension: line_item_id_ {
    label: "line item from table"
    type: string
    sql: ${TABLE}.line_item_id_ ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}.command ;;
  }

  # --- Time ---
  dimension_group: es_update {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}._es_update_timestamp ;;
  }

  # --- Raw JSON payload ---
  dimension: parameters_json {
    type: string
    sql: ${TABLE}.parameters ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}.price_per_unit ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: updated_by_user_id {
    type: number
    sql: ${TABLE}.updated_by_user_id ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: updated_by_email {
    label: "Updated By Email"
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.employee_title ;;
  }

}
