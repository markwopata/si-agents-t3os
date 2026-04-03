# This table in Snowflake needs to be updated every year after tax reporting is complete.
# Pull a new copy of the table from the IRS and append it to this data with a new payroll_year. -Jack G
view: annual_vehicle_lease_value {
  sql_table_name: "ANALYTICS"."TAX"."ANNUAL_VEHICLE_LEASE_VALUE"
    ;;


  # If the asset value is > 59999 then use (value * 0.25) + 500
  dimension: annual_lease_value {
    type: number
    sql: ${TABLE}."ANNUAL_LEASE_VALUE" ;;
  }

  dimension: lower_bound {
    type: number
    sql: ${TABLE}."LOWER_BOUND" ;;
  }

  dimension: payroll_year {
    type: number
    sql: ${TABLE}."PAYROLL_YEAR" ;;
  }

  dimension: upper_bound {
    type: number
    sql: ${TABLE}."UPPER_BOUND" ;;
  }

  dimension: pkey {
    type: string
    primary_key: yes
    sql: CONCAT(${annual_lease_value}, ${payroll_year}) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
