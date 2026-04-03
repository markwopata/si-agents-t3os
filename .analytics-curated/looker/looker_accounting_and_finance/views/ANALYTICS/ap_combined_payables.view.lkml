view: ap_combined_payables {
  sql_table_name: "ANALYTICS"."TREASURY"."AP_COMBINED_PAYABLES_2";;

############### DIMENSIONS ##########################

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: first_4_characters {
    type: string
    sql: LEFT(${TABLE}.ACCOUNT_NUMBER, 4) ;;
    label: "GL"
  }




  dimension: account_title {
    type: string
    sql: ${TABLE}."ACCOUNT_TITLE" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: cf {
    type: string
    sql: ${TABLE}."CF" ;;
  }

  dimension: lookup_key {
    type: string
    sql: ${TABLE}."LOOKUP_KEY" ;;
  }

  dimension: preferred_payment_method {
    type: string
    sql: ${TABLE}."PREFERRED_PAYMENT_METHOD" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }






  dimension: payment_speed {
    type: string
    sql: case
              when ${vendor_id} in ('V12324','V32106') and ${type} = 'weekly' and ${end_of_week}::date <= ${due_date}::date then 'On Time'
              when ${vendor_id} in ('V12324','V32106') and ${type} = 'weekly' and ${end_of_week}::date > ${due_date}::date  then 'Past Due'
              when ${type} = 'weekly' and (${due_date}::date - ${end_of_week}::date) >= 7   then 'Early'
              when ${type} = 'weekly' and (${due_date}::date - ${end_of_week}::date) between 0  and 6 then 'On Time'
              when ${type} = 'weekly' and ${due_date}::date < ${end_of_week}::date  then 'Past Due'
              else 'Past Due'
              end ;;
  }


  ############### DATES ##########################

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

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

  dimension: end_of_week {
    type: date
    sql: '2023-11-15'::date ;;
  }

  ############### Boolean ##########################


  dimension: is_ytd {
    type: yesno
    sql: EXTRACT(Year from ${payment_date}::DATE) = EXTRACT(Year from ${end_of_week}::DATE);;
  }


  dimension: is_qtd {
    type: yesno
    sql: EXTRACT(Quarter from ${payment_date}::DATE) = EXTRACT(Quarter from ${end_of_week}::DATE);;
  }


  dimension: is_mtd {
    type: yesno
    sql: EXTRACT(Month from ${payment_date}::DATE) = EXTRACT(Month from ${end_of_week}::DATE);;
  }

  dimension: is_prior_week {
    type: yesno
    sql: EXTRACT(Week from ${payment_date}::DATE) = EXTRACT(Week from ${end_of_week}::DATE) - 1;;
  }

  dimension: is_current_week {
    type: yesno
    sql: EXTRACT(Week from ${payment_date}::DATE) = EXTRACT(Week from ${end_of_week}::DATE)  ;;
  }


  ############### MEASURES ##########################

  measure: payment_amount {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT"  ;;
  }


  measure: payment_amount_ytd {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_ytd*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.is_ytd]='Yes'"
    }
    sql: iff(${is_ytd},  ${TABLE}."PAYMENT_AMOUNT" , 0) ;;
  }




  measure: payment_amount_qtd {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_qtd*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.is_qtd]='Yes'"
    }
    sql: iff(${is_qtd},  ${TABLE}."PAYMENT_AMOUNT" , 0) ;;
  }



  measure: payment_amount_mtd {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_mtd*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.is_mtd]='Yes'"
    }
    sql: iff(${is_mtd} ,  ${TABLE}."PAYMENT_AMOUNT" , 0) ;;
  }



  measure: payment_amount_prior_week {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_prior_week*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.is_prior_week]='Yes'"
    }
    sql: iff(${is_prior_week} ,  ${TABLE}."PAYMENT_AMOUNT" , 0) ;;
  }



  measure: payment_amount_current_week {
    type: sum
   value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_curr_week_other*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.type]='ytd'&f[ap_combined_payables.is_current_week]='Yes'"
    }
    sql: iff(${is_current_week} and ${type} = 'ytd',  ${TABLE}."PAYMENT_AMOUNT" , 0) ;;
  }



  measure: payment_amount_weekly_payables {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_curr_week_ap*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.type]='weekly'&f[ap_combined_payables.is_current_week]='Yes'"
    }
    sql: iff(${type} = 'weekly' and ${is_current_week}, ${TABLE}."PAYMENT_AMOUNT", 0) ;;
  }

  measure: payment_amount_ap {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_ap*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.type]='weekly'"
    }
    sql: iff(${type} = 'weekly' , ${TABLE}."PAYMENT_AMOUNT", 0) ;;
  }

  measure: payment_amount_other {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details_other*]
    link: {
      label: "Drill-down"
      url: "{{ link }}&f[ap_combined_payables.type]='ytd'"
    }
    sql: iff(${type} = 'ytd' , ${TABLE}."PAYMENT_AMOUNT", 0) ;;
  }



  measure: count {
    type: count
    value_format: "#,##0;(#,##0);-"
    drill_fields: [ap_details*]
  }

  measure: days_to_pay {
    type: average
    value_format: "#;(#);-"
    sql: ${due_date}::date - ${end_of_week}::DATE ;;
  }


############### DRILL DOWN FIELDS ##########################

  set: ap_details {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount
    ]
  }

  set: ap_details_ytd {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_ytd
    ]
  }

  set: ap_details_qtd {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_qtd
    ]
  }

  set: ap_details_mtd {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_mtd
    ]
  }

  set: ap_details_prior_week {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,  payment_amount_prior_week
    ]
  }

  set: ap_details_curr_week_other {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_current_week
    ]
  }

  set: ap_details_curr_week_ap {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_weekly_payables, days_to_pay
    ]
  }

  set: ap_details_ap {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_ap, days_to_pay
    ]
  }

  set: ap_details_other {
    fields: [
      vendor_id, vendor_name ,  bill_number, cf, account_number, account_title, preferred_payment_method,
      payment_date,date, due_date,  payment_speed,payment_amount_other
    ]
  }

}
