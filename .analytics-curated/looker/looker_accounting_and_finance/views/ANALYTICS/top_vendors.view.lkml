view: top_vendors {
  sql_table_name: "ANALYTICS"."TREASURY"."TOP_VENDORS"
    ;;

  dimension: bill_date {
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: ap_mapping {
    type: string
    label: "AP Mapping"
    sql: ${TABLE}."AP_MAPPING" ;;
  }


  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: gl_account_name {
    type: string
    label: "GL Account Name"
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    type: string
    label: "GL Account Number"
    value_format: "#;(#);-"
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: vendor_terms {
    type: string
    sql: ${TABLE}."TERMNAME" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: is_mtd {
    type: yesno
    sql: ${bill_date} between '2023-02-01' and '2023-02-28'   ;;
  }

  dimension: is_qtd {
    type: yesno
    sql: ${bill_date} between '2023-01-01' and '2023-03-31'   ;;
}

  dimension: is_prior_qtd {
    type: yesno
    sql: ${bill_date} between '2022-10-01' and '2022-11-23'   ;;
  }

  dimension: is_ytd {
    type: yesno
    sql: ${bill_date} >= '2023-01-01'   ;;
}


  measure: bill_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [vendor_details_mtd*]
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  measure: bill_amount_mtd {
    type: sum
    label: "Bill Amount MTD"
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [vendor_details_mtd*]
    link: {label: "Drill Detail" url:"{{ bill_amount_mtd._link }}&f[top_vendors.is_mtd]=True&sorts=top_vendors.bill_amount_mtd+desc" }
    sql: iff(${is_mtd},${TABLE}."BILL_AMOUNT",null) ;;
  }

  measure: bill_amount_qtd {
    type: sum
    label: "Bill Amount QTD"
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [vendor_details_qtd*]
    link: {label: "Drill Detail" url:"{{ bill_amount_qtd._link }}&f[top_vendors.is_qtd]=True&sorts=top_vendors.bill_amount_qtd+desc" }
    sql: iff(${is_qtd},${TABLE}."BILL_AMOUNT",null) ;;
  }

  measure: bill_amount_prior_qtd {
    type: sum
    label: "Bill Amount Prior QTD"
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [vendor_details_prior_qtd*]
    link: {label: "Drill Detail" url:"{{ bill_amount_prior_qtd._link }}&f[top_vendors.is_prior_qtd]=True&sorts=top_vendors.bill_amount_prior_qtd+desc" }
    sql: iff(${is_prior_qtd},${TABLE}."BILL_AMOUNT",null) ;;
  }

  measure: bill_amount_ytd {
    type: sum
    label: "Bill Amount YTD"
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [vendor_details_ytd*]
    link: {label: "Drill Detail" url:"{{ bill_amount_ytd._link }}&f[top_vendors.is_ytd]=True&sorts=top_vendors.bill_amount_ytd+desc" }
    sql: iff(${is_ytd},${TABLE}."BILL_AMOUNT",null) ;;
  }

  measure: count {
    type: count
    value_format: "#;(#);-"
     drill_fields: [vendor_details*]
  }

 measure: count_mtd {
  type: number
  value_format: "#;(#);-"
  drill_fields: [vendor_details_mtd*]
  link: {label: "Drill Detail" url:"{{ count_mtd._link }}&f[top_vendors.is_mtd]=True&sorts=top_vendors.bill_amount_mtd+desc" }
  sql: sum(iff(${is_mtd},1,0)) ;;
}

  measure: count_qtd {
    type: number
    value_format: "#;(#);-"
    drill_fields: [vendor_details_qtd*]
    link: {label: "Drill Detail" url:"{{ count_qtd._link }}&f[top_vendors.is_qtd]=True&sorts=top_vendors.bill_amount_qtd+desc" }
    sql: sum(iff(${is_qtd},1,0)) ;;
  }

  measure: count_prior_qtd {
    type: number
    value_format: "#;(#);-"
    drill_fields: [vendor_details_prior_qtd*]
    link: {label: "Drill Detail" url:"{{ count_prior_qtd._link }}&f[top_vendors.is_prior_qtd]=True&sorts=top_vendors.bill_amount_prior_qtd+desc" }
    sql: sum(iff(${is_prior_qtd},1,0)) ;;
  }

  measure: count_ytd {
    type: number
    value_format: "#;(#);-"
    drill_fields: [vendor_details_ytd*]
    link: {label: "Drill Detail" url:"{{ count_ytd._link }}&f[top_vendors.is_ytd]=True&sorts=top_vendors.bill_amount_ytd+desc" }
    sql: sum(iff(${is_ytd},1,0)) ;;
  }


  set: vendor_details {
    fields: [
      vendor_id, vendor_name, vendor_category,vendor_terms, ap_mapping,bill_number, bill_date, gl_account_number, gl_account_name, location_id, location_name, bill_amount
    ]
  }


  set: vendor_details_mtd {
    fields: [
        vendor_id, vendor_name, vendor_category,vendor_terms, ap_mapping, bill_number, bill_date, gl_account_number, gl_account_name, location_id, location_name, bill_amount_mtd
    ]
  }

  set: vendor_details_qtd {
    fields: [
      vendor_id, vendor_name, vendor_category,vendor_terms, ap_mapping, bill_number, bill_date, gl_account_number, gl_account_name, location_id, location_name, bill_amount_qtd
    ]
  }

  set: vendor_details_prior_qtd {
    fields: [
      vendor_id, vendor_name, vendor_category,vendor_terms, ap_mapping, bill_number, bill_date, gl_account_number, gl_account_name, location_id, location_name, bill_amount_prior_qtd
    ]
  }

  set: vendor_details_ytd {
    fields: [
      vendor_id, vendor_name, vendor_category,vendor_terms, ap_mapping, bill_number, bill_date, gl_account_number, gl_account_name, location_id, location_name, bill_amount_ytd
    ]
  }

}
