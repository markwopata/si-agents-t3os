view: ar_payment_posting_team_matrix {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_PAYMENT_POSTING_TEAM_MATRIX" ;;


  ############ DIMENSIONS ############

  dimension: key {
    type: string
    sql: ${posted_user_id} || '-' ||  ${entered_date}::date ;;
  }

  dimension: customer_id {
    type: string
    value_format_name: id
    #html: <a href='https://equipmentshare.looker.com/dashboards/1263?Customer+ID={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: date_applied {
    type: date
    sql: ${TABLE}."DATE_APPLIED"  ;;
  }

  dimension: date_reversed {
    type: date
    sql: ${TABLE}."REVERSED_DATE"  ;;
  }



  dimension_group: applied {
    type: time
    intervals: [day,hour]
    sql: ${TABLE}."DATE_APPLIED"  ;;
  }

  dimension_group: entered {
    type: time
    intervals: [day,hour]
    sql: ${TABLE}."DATE_ENTERED" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: payment_id {
    type: string
    value_format_name: id
    html: <a href='https://admin.equipmentshare.com/#/home/payments/{{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }

  dimension: posted {
    type: number
    sql: ${TABLE}."POSTED" ;;
  }

  dimension: posted_name {
    type: string
    sql: ${TABLE}."POSTED_NAME" ;;
  }

  dimension: posted_user_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."POSTED_USER_ID" ;;
  }

  dimension: encrypted_id {
    type: string
    sql: ${TABLE}."ENCRYPTED_ID" ;;
  }

  dimension: reversed {
    type: number
    sql: ${TABLE}."REVERSED" ;;
  }

  dimension: reversed_by {
    type: string
    sql: ${TABLE}."REVERSED_BY" ;;
  }

  dimension: reversed_by_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."REVERSED_BY_USER_ID" ;;
  }

  dimension: user_email_address  {
    type:  string
    sql: ${TABLE}."USER_EMAIL_ADDRESS" ;;
  }

  dimension: is_user  {
    type: yesno
    sql: ${user_email_address} = '{{ _user_attributes['email'] }}' OR
         ('{{ _user_attributes['email'] }}' in (
        'ryan.stevens@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'lisa.evans@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'jabbok@equipmentshare.com',
        'angie.wallace@equipmentshare.com',
        'jenny.sperry@equipmentshare.com',
        'kris@equipmentshare.com'
       )) ;;
  }




  ############ MEASURES ############

  measure: payments_applied_count {
    type: sum
    value_format_name: decimal_0
    #drill_fields: [ar_details*]
    sql: ${TABLE}."POSTED" ;;
  }

  measure: reversed_payments_count {
    type: sum
    value_format_name: decimal_0
    #drill_fields: [ar_details*]
    sql: ${TABLE}."REVERSED" ;;
  }

  measure: payments_applied_count_daily {
    type: sum
    value_format_name: decimal_0
    #drill_fields: [date_applied_details*]
    sql: ${TABLE}."POSTED" ;;
  }

  measure: checks_count {
    type: count
    filters: [ payment_type: "Check" ]
  }

  measure: ach_count {
    type: count
    filters: [ payment_type: "ACH" ]
  }

  measure: credit_cash_count {
    type: count
    filters: [ payment_type: "Credit Card, Cash" ]
  }

  measure: checks_time_per_payment {
    type: number
    label: "Checks Time per Payment (hrs)"
    sql: ROUND((${checks_count} * 0.53) / 60, 2) ;;
  }

  measure: ach_time_per_payment {
    type: number
    label: "Ach Time per Payment (hrs)"
    sql: ROUND((${ach_count} * 0.49) / 60, 2) ;;
  }

  measure: credit_cash_time_per_payment {
    type: number
    label: "Credit/Cash Time per Payment (hrs)"
    sql: ROUND((${credit_cash_count} * 0.43) / 60, 2) ;;
  }

  measure: total_time_spent {
    type: number
    label: "Total Time Spent (hrs)"
    sql:
    ROUND( ${checks_time_per_payment} + ${ach_time_per_payment} + ${credit_cash_time_per_payment}, 2) ;;
    #drill_fields: [ total_time_spent_details* ]
  }



  measure: combined_hours   {
    value_format_name: decimal_2
    type:  number
    sql:  ${total_time_spent} + ${total_ar_activity_hours.hours} ;;
  }


  measure: percent_reversed {
    value_format_name: percent_2
    type: number
    #drill_fields: [ar_details*]
    sql:  IFF(${payments_applied_count} = 0, 0, ${reversed_payments_count} / ${payments_applied_count}) ;;
  }

  measure: hours_evaluation {
    type: string
    sql:case
        when ${combined_hours} < 5 then 'Below Par'
        when ${combined_hours} >= 5 and ${combined_hours} < 7 then 'Good'
        when ${combined_hours} >= 7 then 'Excellent'
        end
             ;;
  }






############## DRILL FIELDS ##############


  #set: ar_details {
  #  fields: [invoice_no,payment_id,entered_date,date_applied,date_reversed,customer_name,customer_id,payment_type,posted_name,posted_user_id,reversed_by,reversed_by_user_id]
  #}

#  set: date_applied_details {
#    fields: [posted_name,posted_user_id,entered_minute,payments_applied_count]
#  }

 # set: total_time_spent_details {
 #   fields: [posted_name, checks_time_per_payment, ach_time_per_payment, credit_cash_time_per_payment, total_time_spent]
#  }

}
