#
# The purpose of this view is to pull out logic specific to rebate calculations from the primary
# invoice view using refinement structure.
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/233015/research-customer-rebate-dashboard-credits-amanda-johnson]
#
# Britt Shanklin | Built 2023-03-01

include: "/views/ES_WAREHOUSE/invoices_rebates.view.lkml"

view: +invoices_rebates {
  view_label: "Invoices With Customer Rebates"

  # dimension: paid_amount_excluding_credits {
  #   type: number
  #   hidden: yes
  #   value_format_name: usd
  #   sql: ${payment_applications.amount} ;;
  # }

  # measure: Total_Paid_Amount_Rebates {
  #   type: sum
  #   sql: coalesce(${paid_amount_excluding_credits}, 0);;
  #   value_format_name: usd
  #   filters: [billing_approved: "Yes",customer_rebate_pay_period: "Yes"]
  #   sql_distinct_key: ${payment_applications.payment_application_id} ;;
  # }

  measure: Total_Outstanding_Amount_Rebates {
    type: sum
    sql: coalesce(${owed_amount}, 0) ;;
    value_format_name: usd
    filters: [billing_approved: "Yes",customer_rebate_pay_period: "Yes"]
  }

  measure: Total_Billed_Amount_Rebates {
    type: sum
    sql: coalesce(${billed_amount},0) ;;
    value_format_name: usd
    filters: [billing_approved: "Yes",customer_rebate_pay_period: "Yes"]
  }

  dimension: customer_rebate_pay_period {
    type: yesno
    sql: ${billing_approved_date}::DATE between ${customer_rebates.rebate_start_period_raw}::DATE and ${customer_rebates.rebate_end_period_raw}::DATE ;;
  }

  # switch customer rebate dimensions and measures to use billing approved date
  dimension: customer_rebate_pay_period_cutoff {
    type: yesno
    sql: ${Days_from_date_paid_to_billing_approved_date} <= ${customer_rebates.paid_in_days} ;;
    html:

    {% if value == 'No' %}

          <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% else %}

      <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% endif %}
      ;;
  }


    # {% if value == 'No' %}

    #       <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    #   {% elsif value == 'Yes' %}

    #   <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    #   {% else %}

    #   <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    #   {% endif %}
    #   ;;


  dimension: customer_rebate_paid_ind{
    type: yesno
    sql: ${Days_from_date_paid_to_billing_approved_date} is not null
      and ${Days_from_date_paid_to_billing_approved_date} > 0;;
  }

  measure: customer_rebate_avg_date_paid {
    type: average
    sql: ${Days_from_date_paid_to_billing_approved_date} ;;
    filters: [customer_rebate_paid_ind: "Yes"]
    # sql_distinct_key: ${payment_applications.payment_application_id} ;;
    drill_fields: [detail*, admin_link_to_invoice,date_created_date,invoices_rebates.paid_date,Days_from_date_paid_to_billing_approved_date]
    value_format: "#"
  }

  measure: customer_rebate_count_invoices_paid_late {
    type: count
    filters: [customer_rebate_pay_period_cutoff: "No"]
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
    sql: coalesce(${paid_date},'9999-12-31'::date) ;;
  }

  # Add dimension to calculate between the invoice date and the paid date for customer rebate calculations
  dimension: Days_from_date_paid_to_billing_approved_date {
    type: number
    sql: CASE WHEN ${paid_date} is null then null else datediff(day, ${billing_approved_date}, ${customer_rebates_paid_date}) end ;;
  }

}
