view: invoices {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."INVOICES"
    ;;
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: in_dispute {
    type: string
    sql: ${TABLE}.extended_data:in_dispute ;;
  }

  measure: total_amount_in_dispute {
    type: sum
    sql: ${billed_amount};;
    value_format_name: usd
    filters: [in_dispute: "true"]
    drill_fields: [
      invoice_date,
      companies.company_id,
      companies.name,
      users.Full_Name,
      invoice_no,
      total_amount_in_dispute
    ]
  }

  measure: count_of_invoices_in_dispute {
    type: count_distinct
    sql: ${invoice_no};;
    filters: [in_dispute: "true"]
    drill_fields: [
      invoice_date,
      companies.name,
      companies.company_id,
      users.Full_Name,
      invoice_no,
      total_amount_in_dispute
    ]
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice_CST {
    type:  time
    datatype: date
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: convert_timezone('America/Chicago',${TABLE}."INVOICE_DATE") ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }

  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }

  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }

  dimension: overdue_by {
    type:  number
    sql:  datediff(day,${due_raw},current_date()) ;;
  }

  dimension: due_date_outstanding {
    type: number
    sql: ${TABLE}."DUE_DATE_OUTSTANDING" ;;
  }

  dimension: invoice_status {
    sql: case
    when ${TABLE}.billing_approved = 'no' then 'UNAPPROVED'
    when ${TABLE}.billing_approved = 'yes' and ${TABLE}.paid = 'yes' then 'PAID'
    when ${TABLE}.billing_approved = 'yes' and ${TABLE}.paid = 'no' and ${TABLE}.due_date_outstanding = 0 then 'UNPAID'
    when ${TABLE}.billing_approved = 'yes' and ${TABLE}.paid = 'no' and ${TABLE}.due_date_outstanding > 0 and ${TABLE}.owed_amount <> ${TABLE}.billed_amount then 'PAST DUE, PARTIALLY PAID'
    else 'PAST DUE'
    end;;
  }

  measure: number_of_invoices {
    type: count
    drill_fields: [invoice_id, orders.order_id, line_items.count]
  }

  measure: Invoice_Billed_Amount {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
  }

  dimension: Days_from_today_to_due_date{
    type:  number
    # sql:  datediff(day, current_date(), ${due_raw}) ;;
    sql:  datediff(day, ${due_raw}, current_date()) ;;
#     DATE_PART('day',NOW()::timestamp-${due_raw}::timestamp) ;;
  }

  dimension: Days_from_today_to_billing_approved_date{
    type:  number
    sql:  datediff(day,${billing_approved_raw},current_date()) ;;
  }

  dimension: Days_from_today_to_date_created{
    type:  number
    sql:  datediff(day,${date_created_raw},current_date()) ;;
  }

  dimension: Days_from_date_paid_to_date_created{
    type:  number
    sql: datediff(day,${date_created_date},coalesce(${paid_date},${payment_applications.date_date},'9999-12-31'::date)) ;;
  }

  # Add dimension to calculate between the invoice date and the paid date for customer rebate calculations
  dimension: Days_from_date_paid_to_invoice_date {
    type: number
    sql: datediff(day, ${invoice_date}, ${customer_rebates_paid_date}) ;;
  }

  dimension_group: customer_rebates_paid {
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
    sql: coalesce(${paid_date},${payment_applications.date_date},'9999-12-31'::date) ;;
  }

  dimension: customer_rebate_pay_period {
    type: yesno
    sql: ${invoice_date}::DATE between ${customer_rebates.rebate_start_period_raw}::DATE and ${customer_rebates.rebate_end_period_raw}::DATE ;;
  }

  # switch customer rebate dimensions and measures to use billing approved date
  dimension: customer_rebate_pay_period_cutoff {
    type: yesno
    sql: ${Days_from_date_paid_to_invoice_date} <= ${customer_rebates.paid_in_days} ;;
    html:

    {% if value == 'No' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% elsif value == 'Yes' %}

    <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }

  dimension: customer_rebate_paid_ind{
    type: yesno
    sql: ${Days_from_date_paid_to_invoice_date} is not null
    and ${Days_from_date_paid_to_invoice_date} > 0;;
  }

  measure: customer_rebate_avg_date_paid {
    type: average
    sql: ${Days_from_date_paid_to_invoice_date} ;;
    filters: [customer_rebate_paid_ind: "Yes"]
    sql_distinct_key: ${payment_applications.payment_application_id} ;;
    drill_fields: [detail*, admin_link_to_invoice,date_created_date,payment_applications.date_date,Days_from_date_paid_to_invoice_date,Total_Paid_Amount_Rebates]
    value_format: "#"
  }

  measure: customer_rebate_count_invoices_paid_late {
    type: count
    filters: [customer_rebate_pay_period_cutoff: "No"]
  }

  measure: Invoice_Total_Amount_KPI{
    hidden: yes
    type: sum
    sql: coalesce(${owed_amount},0) ;;
        # CASE
        #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
        #   ELSE ${billed_amount}
        # END ;;
    # value_format: "$#,##0.00"
      value_format_name: usd
      drill_fields: [markets.market_id,markets.name,Invoice_Total_Amount_KPI]
      # filters: [paid: "no", billing_approved: "yes"]
    filters: [billing_approved: "yes"]
      link: {
        label: "View AR History"
        url: "https://equipmentshare.looker.com/looks/35?&f[collector_customer_assignments.final_collector]={{ _filters['collector_customer_assignments.final_collector'] | url_encode }}&f[markets.name]={{ _filters['markets.name'] | url_encode }}&toggle=det"
      }
    }

    measure: collector_manager_drill_Invoice_Total_Amount_KPI{
      hidden: yes
      type: sum
      sql: coalesce(${owed_amount},0) ;;
        # CASE
        #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
        #   ELSE ${billed_amount}
        # END ;;
      value_format_name: usd
      drill_fields: [collector_customer_assignments.final_collector,by_company_drill_invoice_total_amount]
      # filters: [paid: "no", billing_approved: "yes"]
      filters: [billing_approved: "yes"]
      link: {
        label: "View AR History"
        url: "https://equipmentshare.looker.com/looks/35?&f[collector_customer_assignments.final_collector]={{ _filters['collector_customer_assignments.final_collector'] | url_encode }}&f[markets.name]={{ _filters['markets.name'] | url_encode }}&toggle=det"
      }
    }

  measure: by_company_drill_invoice_total_amount{
    hidden: yes
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    value_format_name: usd
    drill_fields: [companies.company_name_with_link_to_customer_dashboard,collector_manager_drill_Invoice_Total_Amount_KPI]
    # filters: [paid: "no", billing_approved: "yes"]
    filters: [billing_approved: "yes"]
    link: {
      label: "View AR History"
      url: "https://equipmentshare.looker.com/looks/35?&f[collector_customer_assignments.final_collector]={{ _filters['collector_customer_assignments.final_collector'] | url_encode }}&f[markets.name]={{ _filters['markets.name'] | url_encode }}&toggle=det"
    }
  }

  measure: Due_Date_Amount_Below_30_Days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 0 AND < 31"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "1"]
    filters: [billing_approved: "yes",due_date_outstanding: "1"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_Below_30_Days
    ]
  }

  measure: Due_Date_Amount_31_to_60_days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 31 AND < 61"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "31"]
    filters: [billing_approved: "yes",due_date_outstanding: "31"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_31_to_60_days
    ]
  }

  measure: Due_Date_Amount_61_to_90_days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 61 AND < 91"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "61"]
    filters: [billing_approved: "yes",due_date_outstanding: "61"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_61_to_90_days
    ]
  }

  measure: Due_Date_Amount_91_to_120_days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 91 AND < 121"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "91"]
    filters: [billing_approved: "yes",due_date_outstanding: "91"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_91_to_120_days
    ]
  }

  measure: Due_Date_Amount_over_90_days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 91 AND < 121"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "91"]
    filters: [billing_approved: "yes",due_date_outstanding: "91,121"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_91_to_120_days
    ]
  }
  measure: Due_Date_Amount_over_120_days{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 121"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "121"]
    filters: [billing_approved: "yes",due_date_outstanding: "121"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Due_Date_Amount_over_120_days
    ]
  }

  measure: past_due_amount_over_0 {
    type: yesno
    sql: ${Due_Date_Total_Amount} > 0  ;;
  }

  measure: Due_Date_Total_Amount{
    type: sum
     sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    # filters: [billing_approved: "yes",paid: "no",Days_from_today_to_due_date: ">= 0"]
    # filters: [billing_approved: "yes",paid: "no",due_date_outstanding: "1,31,61,91,121"]
    filters: [billing_approved: "yes",due_date_outstanding: "1,31,61,91,121"]
    value_format_name: usd
    drill_fields: [
      companies.name,
      locations.delivery_location,
      locations.company_address,
      users.Full_Name,
      invoice_no,
      invoice_status,
      purchase_orders.name,
      invoice_date,
      due_date,
      overdue_by,
      billed_amount,
      Due_Date_Total_Amount
    ]
  }

  measure: current_amount_over_0 {
    type: yesno
    sql: ${Current_Total_Amount} > 0  ;;
  }

  measure: Current_Total_Amount{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # CASE
    #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
    #   ELSE ${billed_amount}
    # END ;;
    filters: [billing_approved: "yes",
      Days_from_today_to_due_date: "<0",
      owed_amount: "> 0"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Current_Total_Amount
    ]
  }

  dimension: clawback_eligible {
    type: yesno
    sql: ${invoice_date} >= '2019-11-01' ;;
  }

  dimension: invoice_1_to_30 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) <= 30 ;;
#     current_date - ${invoice_date} <= 30;;
  }

  measure: Outstanding_1_to_30{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # filters: [invoice_1_to_30: "Yes" , owed_amount: "> 0"]
    filters: [outstanding: "= 1" , owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_1_to_30
    ]
  }

  dimension: invoice_31_to_60 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 30 AND datediff(day,${invoice_date},current_date()) <= 60 ;;
#     current_date - ${invoice_date} > 30 and current_date - ${invoice_date} <= 60;;
  }

  measure: Outstanding_31_to_60{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # filters: [invoice_31_to_60: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 31", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_31_to_60
    ]
  }

  dimension: invoice_61_to_90 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 60 AND datediff(day,${invoice_date},current_date()) <= 90 ;;
#     current_date - ${invoice_date} > 60 and current_date - ${invoice_date} <= 90;;
  }

  measure: Outstanding_61_to_90{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # filters: [invoice_61_to_90: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 61", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_61_to_90
    ]
  }

  dimension: invoice_91_to_120 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 90 AND datediff(day,${invoice_date},current_date()) <= 120 ;;
#     current_date - ${invoice_date} > 90 and current_date - ${invoice_date} <= 120;;
  }

  measure: Outstanding_91_to_120{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # filters: [invoice_91_to_120: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 91", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_91_to_120
    ]
  }

  dimension: invoice_120_plus {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 120 ;;
#     current_date - ${invoice_date} > 120 ;;
  }

  measure: Outstanding_120_plus{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # filters: [invoice_120_plus: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 121", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_120_plus
    ]
  }

  # dimension: invoice_is_past_current_date{
  #   type: yesno
  #   sql: current_date - ${invoice_date} >= 1 ;;
  # }

  measure: Outstanding_total{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    filters: [owed_amount: "> 0"]
    value_format_name: usd
    drill_fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Outstanding_total
    ]
  }

  measure: Outstanding_120_plus_clawback{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    filters: [invoice_120_plus: "Yes", clawback_eligible: "Yes", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: Outstanding_120_plus_clawback_4{
    type: sum
    sql: ${owed_amount}*.04 ;;
    filters: [invoice_120_plus: "Yes", clawback_eligible: "Yes", owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: amount_for_current_and_due_over_zero_flag {
    type: yesno
    sql: ${Due_Date_Total_Amount} > 0 OR ${Current_Total_Amount} > 0 ;;
    description: "Used to exclude results that have no current or past due totals"
  }

  measure: Invoice_Total_Amount{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
        # CASE
        #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
        #   ELSE ${billed_amount}
        # END ;;
    filters: [billing_approved: "yes"]
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure:  AR_Total {
    type: number
    sql: ${Invoice_Total_Amount} - ${customer_credit_notes.Total_Available_Credit_Amount} - ${payments.Total_Pre_Overpayment_Amount} ;;
    value_format_name: usd
  }

  dimension: admin_link_to_invoice {
    label: "Admin Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: track_link {
    label: "Track Link"
    type: string
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/dashboard/invoices/{{invoice_id}}?status=outstanding" target="_blank">Track</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  measure: Total_Outstanding {
    type: sum
    value_format_name: usd
    sql: coalesce(${owed_amount},0) ;;
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,owed_amount]
    # filters: [paid: "no",billing_approved: "yes"]
    filters: [billing_approved: "yes"]
  }

  measure: Total_Revenue {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    filters: [billing_approved: "yes"]
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,billed_amount]
  }

  dimension: fix_payment_measures {
    type: string
    sql: concat(${payment_applications.payment_application_id},${credit_note_allocations.credit_note_allocation_id}) ;;
  }

  measure: Total_Paid_Amount {
    type: sum
    # sql: ${billed_amount} ;;
    sql: ${payment_applications.amount} + ${credit_note_allocations.amount};;
    value_format_name: usd
    # filters: [billing_approved: "yes",paid: "yes"]
    filters: [billing_approved: "yes"]
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_id,billed_amount]
    sql_distinct_key: ${fix_payment_measures} ;;
  }

  measure: Total_Paid_Amount_Rebates {
    type: sum
    # sql: ${billed_amount} ;;
    # sql: ${payment_applications.amount} + ${credit_note_allocations.amount} ;;
    sql: ${billed_amount} - ${owed_amount} ;;
    value_format_name: usd
    # filters: [billing_approved: "yes",paid: "yes",customer_rebate_pay_period: "yes"]
    filters: [billing_approved: "yes",customer_rebate_pay_period: "yes"]
    drill_fields: [date_created_date,companies.name,admin_link_to_invoice, track_link,customer_rebates_paid_date ,Days_from_date_paid_to_date_created,  customer_rebates.paid_in_days,invoice_id,billed_amount]
    #sql_distinct_key: ${fix_payment_measures} ;;
  }

  measure: Total_Outstanding_Amount_Rebates {
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    # sql: ${payment_applications.amount} + ${credit_note_allocations.amount} ;;
    value_format_name: usd
    # filters: [billing_approved: "yes",paid: "no",customer_rebate_pay_period: "yes"]
    filters: [billing_approved: "Yes",customer_rebate_pay_period: "Yes"]
    drill_fields: [date_created_date,companies.name, admin_link_to_invoice,track_link,customer_rebates_paid_date,Days_from_date_paid_to_date_created, customer_rebates.paid_in_days,invoice_no,billed_amount]
  }

  measure: Total_Billed_Amount_Rebates {
    type: sum
    sql: coalesce(${billed_amount},0) ;;
    # sql: ${payment_applications.amount} + ${credit_note_allocations.amount} ;;
    value_format_name: usd
    # filters: [billing_approved: "yes",paid: "no",customer_rebate_pay_period: "yes"]
    filters: [billing_approved: "Yes",customer_rebate_pay_period: "Yes"]
    drill_fields: [date_created_date,companies.name, admin_link_to_invoice,track_link,Days_from_date_paid_to_date_created, customer_rebates.paid_in_days,invoice_id,billed_amount]
  }

  # measure: customer_rebates_tiers {
  #   type: sum
  #   sql: ${billed_amount};;
  #   value_format_name: usd
  #   filters: [billing_approved: "yes",paid: "yes",customer_rebate_pay_period: "yes"]
  #   drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,billed_amount]
  # }

  measure: dso {
    type: number
    sql: (${Total_Outstanding}/case when ${Total_Revenue} = 0 then null else ${Total_Revenue} end)*180 ;;
    value_format_name: decimal_0
    drill_fields: [dso_detail*]
  }

  measure: dso_companies_drill {
    type: number
    sql: (${Total_Outstanding}/case when ${Total_Revenue} = 0 then null else ${Total_Revenue} end)*180 ;;
    value_format_name: decimal_0
    drill_fields: [dso_companies_detail*]
  }

  measure: Invoice_Total_Amount_KPI_salesperson{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
        # CASE
        #   WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
        #   ELSE ${billed_amount}
        # END ;;
    value_format_name: usd
    drill_fields: [companies.name,
      locations.delivery_location,
      locations.company_address,
      users.Full_Name,
      invoice_no,
      invoice_status,
      purchase_orders.name,
      invoice_date,
      due_date,
      overdue_by,
      billed_amount,
      Due_Date_Total_Amount]
    filters: [billing_approved: "yes"]
  }

  measure: Invoices_before_sept{
    type: sum
    sql: coalesce(${owed_amount},0) ;;
    filters: [clawback_eligible: "No"]
    value_format_name: usd_0
  }

  dimension: view_invoice {
    group_label: "Link to Invoice"
    label: "Invoice No"
    type: string
    required_fields: [invoice_id]
    sql: ${invoice_no} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{invoice_id._value}}" target="_blank">{{invoice_no._value}}</a></font></u>
    ;;
  }

  set: detail {
    fields: [
      invoice_date,
      companies.name,
      users.Full_Name,
      invoice_no,
      Total_Revenue
    ]
  }

  set: dso_detail {
    fields: [
      market_region_xwalk.market_name,
      invoice_date,
      invoice_no,
      Total_Outstanding,
      Total_Revenue
    ]
  }

  set: dso_companies_detail {
    fields: [
      companies.name,
      Total_Outstanding,
      Total_Revenue,
      dso
    ]
  }

}
