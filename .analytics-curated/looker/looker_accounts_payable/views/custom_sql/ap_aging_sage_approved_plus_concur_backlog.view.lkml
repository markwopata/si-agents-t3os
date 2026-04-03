
view: ap_aging_sage_approved_plus_concur_backlog {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select * from analytics.procure_2_pay.aap_aging_sage_approved_plus_concur_backlog  ;;
    # persist_for: "24 hours"
      }

#
#   # Define your dimensions and measures here, like this:
  dimension:  vendor_category {
    type: string
    sql: ${TABLE}.vendor_category;;
  }

  dimension:  account_number {
    type: string
    sql: ${TABLE}.account_number;;
  }
  dimension: vendor_id {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.vendor_id ;;
  }
  dimension: vendor_name {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.vendor_name ;;
  }
  dimension: bill_number {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.bill_number ;;
  }
  dimension: bill_date {
    # description: "Unique ID for each user that has ordered"
    type: date
    sql: ${TABLE}.bill_date ;;
  }
  dimension: terms {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.terms ;;
  }
  dimension: due_date {
    # description: "Unique ID for each user that has ordered"
    type: date
    sql: ${TABLE}.due_date ;;
  }
  dimension: total_due {
    # description: "Unique ID for each user that has ordered"
    type: number
    sql: ${TABLE}.total_due ;;
    value_format: "$#,##0"
  }

  # dimension: vendor_due_subtotal {
  #   # description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.vendor_due_subtotal ;;
  # }
  dimension: source {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.source ;;
  }
  dimension: source_state {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: concat(${source}, ' ', ${state}, ' - ', ${past_due_bucket2});;
  }
  dimension: source_state_limit {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: concat(${source}, ' ', ${state}, ' ', ${past_due_bucket2}, ' ',${credit_limit} );;
  }
  dimension: vendor_state_age {
    # description: "Unique ID for each user that has ordered"
    type: string
    sql: concat(${vendor_id}, ' ', ${state}, ' ', ${past_due_bucket2});;
  }

  dimension: days_till_due {
    type: number
    sql:${TABLE}.days_past_due ;;
  }


  # dimension: past_due_bucket {
  #   type: string
  #   sql: ${TABLE}.PAST_DUE_BUCKET  ;;
  # }
  dimension: past_due_bucket {
    type: string
    label: "Past Due Bucket"
    sql: case
         when ${days_till_due} <= 0 then 'Current'
         when ${days_till_due} between 1 and 14 then '1-14'
         when ${days_till_due} between 15 and 30 then '15-30'
         when ${days_till_due} between 31 and 45 then '30+'
         when ${days_till_due} between 46 and 60 then '45+'
         when ${days_till_due} between 61 and 90 then '60+'
         when ${days_till_due} between 91 and 120 then '90+'
         when ${days_till_due} >= 121 then '120+'
         else 'unknown'
         end ;;
  }


  dimension: past_due_bucket_sort {
    label: "Sort Key"
    type: number
    sql: case
         when ${past_due_bucket} = 'Current' then 1
         when ${past_due_bucket} = '1-14' then 2
         when ${past_due_bucket} = '15-30' then 3
         when ${past_due_bucket} = '30+' then 4
         when ${past_due_bucket} = '45+' then 5
         when ${past_due_bucket} = '60+' then 6
         when ${past_due_bucket} = '90+' then 7
         when ${past_due_bucket} = '120+' then 8
         when ${past_due_bucket} = 'unknown' then 9
         end ;;
  }

  dimension: past_due_bucket2 {
    type: string
    label: "Age"
    sql: case
         when ${days_till_due} <= 0 then 'Current'

         when ${days_till_due} > 0 then 'Past Due'

         else 'unknown'
         end ;;
  }

  dimension: past_due_bucket_sort2 {
    label: "Sort Key2"
    type: number
    sql: case
         when ${past_due_bucket} = 'Current' then 1

         when ${past_due_bucket} = 'Past Due' then 2

         when ${past_due_bucket} = 'unknown' then 3
         end ;;
  }
  measure: backlog_less {
    label: "Concur Backlog <=30"
    type: sum
    sql: ${TABLE}.total_due ;;
    filters: [source_state: "Concur Backlog <=30"]
    value_format: "$#,##0"
  }

  measure: backlog_greater {
    label: "Concur Backlog 30+"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Concur Backlog 30+"]
    value_format: "$#,##0"
  }
  measure: sage_selected_less {
    label: "Sage Selected <=30"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Selected <=30"]
    value_format: "$#,##0"
  }
  measure: sage_selected_greater {
    label: "Sage Selected 30+"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Selected 30+"]
    value_format: "$#,##0"
  }
  measure: sage_posted_less {
    label: "Sage Posted <=30"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Posted <=30"]
    value_format: "$#,##0"
  }
  measure: sage_posted_greater {
    label: "Sage Posted 30+"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Posted 30+"]
    value_format: "$#,##0"
  }
  measure: sage_partially_paid_less {
    label: "Sage Partially Paid <=30"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Partially Paid <=30"]
    value_format: "$#,##0"
  }
  measure: sage_partially_paid_greater {
    label: "Sage Partially Paid 30+"
    type: sum
    sql: ${TABLE}.total_due;;
    filters: [source_state: "Sage Partially Paid 30+"]
    value_format: "$#,##0"
  }
  # measure: total_pending {
  #   label: "Pending Total"
  #   type: sum
  #   sql: ${sum_total_due} ;;
  #   filters: [source_state: "Pending"]
  # }


  dimension: credit_limit {
    type: string
    sql:${TABLE}.creditlimit ;;
    value_format: "$#,##0"
  }
  measure: total_credit_limit {
    label: "Credit Limit"
    type: max
    sql:${TABLE}.creditlimit ;;
    value_format: "$#,##0"
  }
  dimension: credit_limit_delta {
    label: "Credit Remaining"
    type: string
    sql:${TABLE}.credit_remaining ;;
    value_format: "$#,##0"
  }


  # measure: credit_limit_remainder {
  #   label: "Credit Limit Remainder"
  #   type: number
  #   sql:${TABLE}.creditlimit - ${TABLE}.total_due ;;
  #   value_format: "$#,##0"
  # }
  dimension: state {
    type: string
    sql:${TABLE}.state ;;

  }
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
  # measure: total_amount_usd {
  #   type: sum
  #   sql: ROUND(${amount}) ;;
  #   value_format_name: usd
  #   label: "Total Amount (Rounded USD)"
  # }

  measure: sum_total_due{
    # description: "Use this for counting lifetime orders across many users"
    type: sum
    sql: ${TABLE}.total_due ;;
    value_format: "$#,##0"
    label: "Total"
    drill_fields: [
      vendor_id,
      vendor_name,
      bill_number,
      bill_date,
      terms,
      credit_limit,
      due_date,
      total_due,
      source,
      state,
      days_till_due,
      past_due_bucket
    ]
}
  measure: count{
    # description: "Use this for counting lifetime orders across many users"
    type: count
    label: "Count"
    drill_fields: [
      vendor_id,
      vendor_name,
      bill_number,
      bill_date,
      terms,
      credit_limit,
      due_date,
      total_due,
      source,
      state,
      days_till_due,
      past_due_bucket
    ]
  }
}
