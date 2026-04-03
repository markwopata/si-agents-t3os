# The analytics.tax.annual_vehicle_lease_value table in Snowflake needs to be updated every year after tax reporting is complete.
# Pull a new copy of the table from the IRS and append it to the table with a new payroll_year. -Jack G
# https://www.irs.gov/publications/p15b#en_US_2022_publink1000193789
view: vehicle_lease_value {
  derived_table: {
    sql:
SELECT ua.asset_id,
       val.payroll_year,
       IFF(COALESCE(aph.purchase_price, aph.oec, 0) > 59999, COALESCE(aph.purchase_price, aph.oec, 0) * 0.25 + 500, val.annual_lease_value) AS annual_lease_value
  FROM sworks.vehicle_usage_tracker.user_asset_assignments ua
       LEFT JOIN es_warehouse.public.asset_purchase_history aph
                  ON ua.asset_id = aph.asset_id
       LEFT JOIN analytics.tax.annual_vehicle_lease_value val
                 ON COALESCE(aph.purchase_price, aph.oec, 0) BETWEEN val.lower_bound AND val.upper_bound

;;
  }

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ${payroll_year}) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: payroll_year {
    type: number
    sql: ${TABLE}."PAYROLL_YEAR" ;;
  }

  dimension: annual_lease_value {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."ANNUAL_LEASE_VALUE" ;;
  }
}
