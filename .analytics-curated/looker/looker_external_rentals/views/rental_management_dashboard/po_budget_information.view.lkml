view: po_budget_information {
  derived_table: {
    sql:
    with sub_renters as (
    SELECT
      ASSET_ID, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT
    FROM business_intelligence.triage.stg_t3__company_values
    QUALIFY ROW_NUMBER() OVER(PARTITION BY ASSET_ID ORDER BY START_DATE desc) = 1 --most recent
    )

SELECT
PO.ASSET_ID,
PO.RENTAL_STATUS_ID,
RS.NAME AS RENTAL_STATUS,
RENTAL_RATE_FILTER,
RENTAL_END_DATE,
RENTAL_START_DATE,
JOBSITE,
INVOICE_NO,
CUSTOM_NAME,
ASSET_CLASS,
VENDOR,
ORDER_ID,
INVOICE_DATE,
COMPANY_ID,
USER_COMPANY_ID,
PO_NAME,
PURCHASE_ORDER_ID,
LIFETIME_AMOUNT, -- By ROW
LIFETIME_AMOUNT_2, -- By PO Lifetime
BUDGET_AMOUNT,
LIFETIME_BUDGET_REMAINING,
ASSETS_ON_PO,
ASSET_COUNT,
SELECTED_DATE_RANGE_SPEND,
BUDGET_REMAINING,
PCNT_BUDGET_REMAINING,
BUDGET_STATUS,
su.sub_renting_company,
su.sub_renting_contact,
ordered_by
      FROM
BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__PO_BUDGET_INFORMATION PO
LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTAL_STATUSES RS on rs.rental_status_id = po.rental_status_id
LEFT JOIN sub_renters su on su.asset_id = PO.asset_id
      WHERE
          {% condition po_filter %} po_name {% endcondition %}
          and {% condition jobsite_filter %} jobsite {% endcondition %}
          and {% condition asset_filter %} custom_name {% endcondition %}
          and {% condition class_filter %} asset_class {% endcondition %}
          and {% condition vendor_filter %} vendor {% endcondition %}
          and {% condition order_id_filter %} order_id {% endcondition %}
          and {% condition rental_rate_filter %} CAST(rental_rate_filter AS BOOLEAN) {% endcondition %}
          and {% condition rental_status_filter %} rental_status {% endcondition %}
          and (company_id = {{ _user_attributes['company_id'] }}::integer or user_company_id = {{ _user_attributes['company_id'] }}::integer)
          and invoice_date::date >= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %})
          and invoice_date::date <= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %})
          and {% condition sub_renting_company_filter %} sub_renting_company {% endcondition %}
          and {% condition sub_renting_contact_filter %} sub_renting_contact {% endcondition %}
          and {% condition ordered_by_filter %} ordered_by {% endcondition %}
          and {% condition class_filter %} asset_class {% endcondition %}
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  filter: po_filter {
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

  dimension: po_name {
    label: "PO"
    primary_key: yes
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: purchase_order_id{
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: budget_remaining {
    type: number
    sql: ${TABLE}."BUDGET_REMAINING" ;;
    value_format_name: usd
  }

  dimension: selected_date_range_spend {
    label: "Spend"
    type: number
    sql: ${TABLE}."SELECTED_DATE_RANGE_SPEND" ;;
    value_format_name: usd
  }

  dimension: pcnt_budget_remaining {
    label: "% of Budget Remaining"
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
  }

  dimension: asset_count {
    label: "# of Assets"
    type: number
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  dimension: assets_on_po {
    label: "Assets on PO"
    skip_drill_filter: yes
    type: string
    sql: ${TABLE}."ASSETS_ON_PO";;
  }

  dimension: lifetime_budget_remaining {
    type: number
    sql: ${TABLE}."LIFETIME_BUDGET_REMAINING";;
  }

  dimension: lifetime_amount {
    type: number
    sql: ${TABLE}."LIFETIME_AMOUNT";;
  }

  dimension: lifetime_amount_2 {
    type: number
    sql: ${TABLE}."LIFETIME_AMOUNT_2";;
  }

  dimension: budget_status {
    type: string
    sql: ${TABLE}."BUDGET_STATUS";;
  }


  measure: budget_remaining_from_timeframe {
    label: "Budget Remaining During Timeframe"
    type: sum
    sql: ${budget_remaining} ;;
    value_format_name: usd_0
  }

  measure: total_budget_amount {
    type: max
    sql: coalesce(${budget_amount},0) ;;
    value_format_name: usd_0
  }

  measure: percent_of_budget_remaining {
    label: "% of Budget Remaining"
    type: max
    sql: ${pcnt_budget_remaining} ;;
    value_format_name: percent_1
  }

  measure: total_asset_count {
    label: "Current Rentals OLD"
    type: max
    sql: ${asset_count} ;;
    html: {{rendered_value}} <font size='1'>assets</font> ;;
  }

  measure: total_asset_count_formatted {
    label: "Current Rentals"
    type: max
    sql: ${asset_count} ;;
    html: {{rendered_value}} <font size='1'>assets ({{assets_on_po._rendered_value}})</font>;;
  }

  measure: total_spend_from_timeframe {
    label: "Total Spend"
    type: sum
    sql: coalesce(${selected_date_range_spend},0) ;;
    required_fields: [purchase_order_id]
    value_format_name: usd
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [invoice_detail*]
  }

  measure: lifetime_budget_remaining_total {
    label: "Lifetime Budget Remaining"
    sql: case when ${total_budget_amount} = 0 then 0 else ${total_budget_amount} - ${lifetime_spend_2} end;;
    value_format_name: usd
  }

  measure: lifetime_spend {
    label: "Lifetime Spend Amount"
    type: sum
    sql: coalesce(${lifetime_amount},0) ;;
    value_format_name: usd
  }

  measure: lifetime_spend_2 {
    label: "Lifetime Spend Amount 2"
    type: max
    sql: coalesce(${lifetime_amount_2},0) ;;
    # filters: {
    #   field: date_filter
    #   ##value: "is any time"
    # }
    value_format_name: usd
  }


  dimension: po_budget_insight {
    label: "Lifetime Budget Status"
    type: string
    sql: ${budget_status};;
    required_fields: [purchase_order_id]
    html: {% if value == "Over Budget" %}
          <p style="color: #cd4a32; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == "Within Budget" %}
          <p style="color: #00CB86; font-size:100%; text-align:center">{{ rendered_value }}</p>
          {% elsif value == "No Budget Set" %}
          <font color="blue"><u><a href="https://app.estrack.com/#/company-admin/work/purchase-orders/edit/{{ purchase_order_id._value }}" target="_blank">{{value}}</a></font?</u>
          {% endif %};;
  }

  set: detail {
    fields: [
      po_name,
      total_spend_from_timeframe,
      budget_amount,
      budget_remaining,
      pcnt_budget_remaining,
      asset_count
    ]
  }

  set: invoice_detail {
    fields: [
      po_drill_details.po_name,
      po_drill_details.purchase_order_id,
      po_drill_details.invoice_link,
      po_drill_details.invoice_date,
      po_drill_details.total_billed_amount,
      po_drill_details.total_rental_only_billed_amount,
      po_drill_details.total_non_rental_billed_amount,
      po_drill_details.total_budget_amount]
  }
}
