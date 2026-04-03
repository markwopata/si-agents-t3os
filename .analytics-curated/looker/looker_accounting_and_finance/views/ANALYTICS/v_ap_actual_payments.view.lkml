view: v_ap_actual_payments {
  sql_table_name: "ANALYTICS"."TREASURY"."V_AP_ACTUAL_PAYMENTS_2"
    ;;


  dimension: current_week {
    type: number
    sql: ${TABLE}."CURRENT_WEEK" ;;
  }

  dimension: dayinquarter {
    type: number
    sql: ${TABLE}."DAYINQUARTER" ;;
  }

  dimension: mtd {
    type: number
    sql: ${TABLE}."MTD" ;;
  }

  dimension: prior_mtd {
    type: number
    sql: ${TABLE}."PRIOR_MTD" ;;
  }

  dimension: prior_qtd {
    type: number
    sql: ${TABLE}."PRIOR_QTD" ;;
  }

  dimension: prior_week {
    type: number
    sql: ${TABLE}."PRIOR_WEEK" ;;
  }

  dimension: prior_two_weeks {
    type: number
    sql: ${TABLE}."PRIOR_TWO_WEEKS" ;;
  }


  dimension: prior_ytd {
    type: number
    sql: ${TABLE}."PRIOR_YTD" ;;
  }

  dimension: qtd {
    type: number
    sql: ${TABLE}."QTD" ;;
  }

  dimension: ytd {
    type: number
    sql: ${TABLE}."YTD" ;;
  }

###############DIMENSIONS##########################
  dimension: expense_category {
    type: string
    sql: ${TABLE}."TAG" ;;
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

  dimension: vendor {
    type: string
    sql: concat(${vendor_name},' - ', ${vendor_id}) ;;
  }

  dimension: gl_account_name {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }


###############DATES##########################
  dimension_group: payment_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

###############MEASURES##########################
  measure: payment_amount {
    type: sum
    value_format: "$#,##0MM;-$#,##0MM;-"
    drill_fields: [ap_pmt_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT"/1000000 ;;
  }

  measure: payment_amounts {
    type: sum
    value_format: "$#,##0.#0;-$#,##0.#0;-"
    drill_fields: [ap_pmt_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  measure: payment_amount_ytd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details_ytd*]
    link: {
      label: "Drill Down to Details"
      url: "{{link}}&f[v_ap_actual_payments.ytd]=1
      &f[v_ap_actual_payments.expense_category]={{ v_ap_actual_payments.expense_category._filterable_value | url_encode }}"
    }
    sql: case when ${ytd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_ytd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details*]
    sql: case when ${prior_ytd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }


  measure: payment_amount_qtd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details_qtd*]
    link: {
      label: "Drill Down to Details"
      url: "{{link}}&f[v_ap_actual_payments.qtd]=1
      &f[v_ap_actual_payments.expense_category]={{ v_ap_actual_payments.expense_category._filterable_value | url_encode }}"
    }
    sql: case when ${qtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_qtd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details*]
    sql: case when ${prior_qtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_mtd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details_mtd*]
    link: {
      label: "Drill Down to Details"
      url: "{{link}}&f[v_ap_actual_payments.mtd]=1
      &f[v_ap_actual_payments.expense_category]={{ v_ap_actual_payments.expense_category._filterable_value | url_encode }}"
    }
    sql: case when ${mtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_mtd {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details*]
    sql: case when ${prior_mtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_curr_week {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details_curr_week*]
    link: {
      label: "Drill Down to Details"
      url: "{{link}}&f[v_ap_actual_payments.current_week]=1
      &f[v_ap_actual_payments.expense_category]={{ v_ap_actual_payments.expense_category._filterable_value | url_encode }}"
    }
    sql: case when ${current_week} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_week {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details*]
    sql: case when ${prior_week} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_two_weeks {
    type: sum
    #value_format: "$#,##0;-$#,##0;-"
    drill_fields: [ap_pmt_details*]
    sql: case when ${prior_two_weeks} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }



  measure: payment_amount_qtd_var {
    type: sum
    sql: case when ${qtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_qtd_var {
    type: sum
    sql: case when ${prior_qtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_mtd_var {
    type: sum
    sql: case when ${mtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_mtd_var {
    type: sum
    sql: case when ${prior_mtd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_ytd_var {
    type: sum
    sql: case when ${ytd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_ytd_var {
    type: sum
    sql: case when ${prior_ytd} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_curr_week_var {
    type: sum
    sql: case when ${current_week} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_week_var {
    type: sum
    sql: case when ${prior_week} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }

  measure: payment_amount_prior_two_weeks_var {
    type: sum
    sql: case when ${prior_two_weeks} = 1 then ${TABLE}."PAYMENT_AMOUNT" else 0 end ;;
  }




  ###############DRILL DOWN FIELDS##########################

  set: ap_pmt_details {
    fields: [
      vendor_id, vendor_name,vendor_category, bill_number, payment_date_date, gl_account_number, gl_account_name,  expense_category, payment_amounts
    ]
  }

  set: ap_pmt_details_ytd {
    fields: [
      vendor_id, vendor_name,vendor_category, bill_number, payment_date_date, gl_account_number, gl_account_name,  expense_category, payment_amount_ytd
    ]
  }

  set: ap_pmt_details_qtd {
    fields: [
      vendor_id, vendor_name,vendor_category, bill_number, payment_date_date, gl_account_number, gl_account_name,  expense_category, payment_amount_qtd
    ]
  }

  set: ap_pmt_details_mtd {
    fields: [
      vendor_id, vendor_name,vendor_category, bill_number, payment_date_date, gl_account_number, gl_account_name,  expense_category, payment_amount_mtd
    ]
  }

  set: ap_pmt_details_curr_week {
    fields: [
      vendor_id, vendor_name,vendor_category, bill_number, payment_date_date, gl_account_number, gl_account_name,  expense_category, payment_amount_curr_week
    ]
  }

}
