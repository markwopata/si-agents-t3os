# The name of this view in Looker is "High Risk Devices"
view: high_risk_devices {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "PUBLIC"."HIGH_RISK_DEVICES"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Serial Number" in Explore.

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: high_risk {
    type: string
    sql: "High Risk" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
