view: po_budget_timeline {
  derived_table: {
    sql:
    with sub_renters as (
    SELECT
      ASSET_ID, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT
    FROM business_intelligence.triage.stg_t3__company_values
    QUALIFY ROW_NUMBER() OVER(PARTITION BY ASSET_ID ORDER BY START_DATE desc) = 1 --most recent
    )

  SELECT
  generated_date,
  po_name,
  company_id,
  user_company_id,
  rental_rate_filter,
  vendor,
  rental_status,
  purchase_order_id,
  jobsite,
  asset_class,
  pdt.asset_id,
  custom_name,
  order_id,
  billing_approved_date,
  total_billed_amount as billed_amount,
  budget_amount,
  cumulative_amount,
  remaining_budget,
  su.sub_renting_company,
  su.sub_renting_contact,
  ordered_by
  FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__PO_BUDGET_TIMELINE pdt
  left join sub_renters su on su.asset_id = pdt.asset_id
  WHERE
      {% condition po_filter %} po_name {% endcondition %}
      and {% condition asset_filter %} custom_name {% endcondition %}
      and {% condition class_filter %} asset_class {% endcondition %}
      and {% condition jobsite_filter %} jobsite {% endcondition %}
      and {% condition vendor_filter %} vendor {% endcondition %}
      and {% condition order_id_filter %} order_id {% endcondition %}
      and {% condition rental_status_filter %} rental_status {% endcondition %}
      and {% condition rental_rate_filter %} CAST(rental_rate_filter AS BOOLEAN) {% endcondition %}
      and (company_id = {{ _user_attributes['company_id'] }}::integer
          or user_company_id = {{ _user_attributes['company_id'] }}::integer)
      and generated_date >= {% date_start date_filter %}
      and generated_date <= {% date_end date_filter %}
      and {% condition sub_renting_company_filter %} sub_renting_company {% endcondition %}
      and {% condition sub_renting_contact_filter %} sub_renting_contact {% endcondition %}
      and {% condition ordered_by_filter %} ordered_by {% endcondition %}
      and {% condition class_filter %} asset_class {% endcondition %}
  ;;
  }

  filter: po_filter {
    type: string
  }

  filter: date_filter {
    type: date
  }

  filter: asset_filter {
    type: string
  }

  filter: class_filter {
    type: string
  }

  filter: jobsite_filter {
    type: string
  }

  filter: vendor_filter {
    type: string
  }

  filter: rental_status_filter {
    type: string
  }

  filter: rental_rate_filter {
    type: yesno
  }

  filter: order_id_filter {
    type: string
  }

  filter: sub_renting_company_filter {
    type: string
  }

  filter: sub_renting_contact_filter {
    type: string
  }

  filter: ordered_by_filter {
    type: string
  }

  dimension: primary_key {
    primary_key: yes
    sql: concat(${po_name},${billing_approved_date_raw}) ;;
  }

  dimension: po_name {
    # primary_key: yes
    type: string
    label: "Purchase Order"
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: id {
    type: string
    sql: concat(${TABLE}."GENERATED_DATE",
    ${TABLE}."PO_NAME",
    ${TABLE}."COMPANY_ID",
    ${TABLE}."USER_COMPANY_ID",
    ${TABLE}."RENTAL_RATE_FILTER",
    ${TABLE}."VENDOR",
    ${TABLE}."RENTAL_STATUS",
    ${TABLE}."PURCHASE_ORDER_ID",
    ${TABLE}."JOBSITE",
    ${TABLE}."ASSET_CLASS",
    ${TABLE}."ASSET_ID",
    ${TABLE}."CUSTOM_NAME",
    ${TABLE}."ORDER_ID",
    ${TABLE}."BILLING_APPROVED_DATE",
    ${TABLE}."BILLED_AMOUNT",
    ${TABLE}."BUDGET_AMOUNT",
    ${TABLE}."CUMULATIVE_AMOUNT",
    ${TABLE}."REMAINING_BUDGET")
;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_company_id {
    type: number
    sql: ${TABLE}."USER_COMPANY_ID" ;;
  }

  dimension: billed_amount {
    type: number
    label: "Billed Amount"
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: budget_amount {
    type: number
    label: "Budget Amount"
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
  }

  dimension: cumulative_spend {
    type: number
    label: "Cumulative Billed Amount"
    sql: ${TABLE}."CUMULATIVE_AMOUNT" ;;
  }

  dimension: remaining_budget {
    type: number
    label: "Remaining Budget"
    sql: ${TABLE}."REMAINING_BUDGET" ;;
  }

  dimension_group: billing_approved_date {
    group_label: "Invoice Dates"
    label: "Invoice Date"
    type: time
    sql: ${TABLE}."GENERATED_DATE" ;;
  }

  dimension_group: invoice_date_formatted {
    group_label: "Invoice Dates"
    label: "Invoice"
    type: time
    sql: ${billing_approved_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_spend {
    label: "Total Spend"
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_budget {
    type: number
    sql: sum(coalesce(${budget_amount}, 0))/ COUNT(coalesce(${po_name},'x')) ;;
    value_format_name: usd
  }

  measure: total_remaining_budget {
    type: number
    sql: SUM(coalesce(${remaining_budget}, 0)) / COUNT(coalesce(${po_name},'x'))
    ;;
    value_format_name: usd
  }

  measure: cumulative_amount_spent {
    type: sum
    sql: coalesce(${cumulative_spend}, 0) ;;
    value_format_name: usd
  }

  set: detail {
    fields: [
      po_name,
      invoice_date_formatted_date,
      billed_amount,
      budget_amount,
      remaining_budget]
  }


}
