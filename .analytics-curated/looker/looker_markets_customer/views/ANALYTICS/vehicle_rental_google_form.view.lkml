view: vehicle_rental_google_form {
  sql_table_name: "PUBLIC"."VEHICLE_RENTAL_GOOGLE_FORM"
    ;;

  dimension: alternate_email {
    type: string
    sql: ${TABLE}."ALTERNATE_EMAIL" ;;
  }

  dimension: coi_submitted {
    type: string
    sql: ${TABLE}."COI_SUBMITTED" ;;
  }

  dimension: confirmed_rental_tax {
    type: string
    sql: ${TABLE}."CONFIRMED_RENTAL_TAX" ;;
  }

  dimension: contract_created_by {
    type: string
    sql: ${TABLE}."CONTRACT_CREATED_BY" ;;
  }

  dimension: customer_picking_up_driving_off_vehicle {
    type: string
    sql: ${TABLE}."CUSTOMER_PICKING_UP_DRIVING_OFF_VEHICLE" ;;
  }

  dimension: double_check_es_admin {
    type: string
    sql: ${TABLE}."DOUBLE_CHECK_ES_ADMIN" ;;
  }

  dimension: drivers_license {
    type: string
    html: <font color="blue "><u><a href="{{ vehicle_rental_google_form.drivers_license._value }}" target="_blank">Driver's License</a></font></u> ;;
    sql: ${TABLE}."DRIVERS_LICENSE" ;;
  }

  dimension: order_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: timestamp {
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
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  dimension: verified_drivers_license {
    type: string
    sql: ${TABLE}."VERIFIED_DRIVERS_LICENSE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
