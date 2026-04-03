view: fleet_qbr_purchasing_by_vendor {
  derived_table: {
    sql:
      Select
      vendor_name_clean,
      vendor_parent,
      q1_actual_invoiced,
      q2_actual_invoiced,
      q3_actual_invoiced,
      Q4_TO_DATE_ACTUAL_INVOICED,
      open_order,
      expected_delivery,
      total_spend
      from data_science_stage.fleet_testing.asset_purchases_by_vendor
      --note: table is pre-suppressed for vendor total spend > 1000000
        ;;
  }

  dimension: p_key {
    type:  string
    description: "one row per vendor"
    primary_key: yes
    hidden: yes
    sql:${TABLE}."VENDOR_NAME_CLEAN";;
  }

  dimension: vendor_name {
    type: string
    description: "vendor from which asset was purchased. May differ from OEM. Lightly cleaned to remove punctuation and render to proper case"
    sql: ${TABLE}."VENDOR_NAME_CLEAN" ;;
  }

  dimension: vendor_parent {
    type: string
    description: "Grouped parent supplier for vendors"
    sql: ${TABLE}."VENDOR_PARENT" ;;
  }

  measure: q1_actual_invoiced {
    type: sum
    description: "calculated OEC for invoiced purchases in Q1"
    value_format: "$#,##0"
    sql: ${TABLE}."Q1_ACTUAL_INVOICED" ;;
  }

  measure: q2_actual_invoiced {
    type: sum
    description: "calculated OEC for invoiced purchases in Q2"
    value_format: "$#,##0"
    sql: ${TABLE}."Q2_ACTUAL_INVOICED" ;;
  }

  measure: q3_actual_invoiced {
    type: sum
    description: "calculated OEC for invoiced purchases in Q3"
    value_format: "$#,##0"
    sql: ${TABLE}."Q3_ACTUAL_INVOICED" ;;
  }

  measure: q4_actual_invoiced {
    type: sum
    description: "calculated OEC for invoiced purchases in Q4"
    value_format: "$#,##0"
    sql: ${TABLE}."Q4_TO_DATE_ACTUAL_INVOICED" ;;
  }


  measure: purchased_open_orders {
    type: sum
    description: "calculated OEC for purchases where order status is Shipped, Okay to Ship, or Ordered, but has not been invoiced"
    value_format: "$#,##0"
    sql: ${TABLE}."OPEN_ORDER" ;;
  }

  measure: purchased_expected_delivery {
    type: sum
    description: "calculated OEC for purchases where order has not been invoiced but asset is promised this year, defined as promise date in 2024 or 2099"
    value_format: "$#,##0"
    sql: ${TABLE}."EXPECTED_DELIVERY" ;;
  }

    measure: total_spend {
      type: sum
      description: "total calculated OEC for invoiced + expected delivery"
      value_format: "$#,##0"
      sql: ${TABLE}."TOTAL_SPEND" ;;
    }
}
