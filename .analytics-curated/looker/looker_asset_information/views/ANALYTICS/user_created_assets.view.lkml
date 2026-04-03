view: user_created_assets {
  sql_table_name: "ANALYTICS"."BI_OPS"."USER_CREATED_ASSETS" ;;

  dimension_group: added_date {
    type: time
    sql: ${TABLE}."ADDED_DATE" ;;
    html: {{ rendered_value | date: "%B %d, %Y" }};;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    label: "Asset ID With T3 Link"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER";;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL" ;;
  }

}
