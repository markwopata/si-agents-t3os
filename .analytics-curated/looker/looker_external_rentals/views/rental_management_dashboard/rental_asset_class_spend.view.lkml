view: rental_asset_class_spend {
  derived_table: {
    sql:
with by_day_util as (
select
  asset_id,
  COALESCE(SUM(on_time_utc),0)/3600 as RUN_TIME
from business_intelligence.triage.stg_t3__by_day_utilization
where (rental_company_id = {{ _user_attributes['company_id'] }}::integer
      or owner_company_id = {{ _user_attributes['company_id'] }}::integer)
      and date >= {% date_start date_filter %}
      and date <= {% date_end date_filter %}
group by asset_id
),
sub_renters as (
SELECT
  ASSET_ID, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT
FROM business_intelligence.triage.stg_t3__company_values
QUALIFY ROW_NUMBER() OVER(PARTITION BY ASSET_ID ORDER BY START_DATE desc) = 1 --most recent
)

select
  racs.ASSET_ID,
  CUSTOM_NAME,
  COMPANY_ID,
  VENDOR,
  PURCHASE_ORDER,
  JOBSITE,
  RENTAL_STATUS,
  ORDER_ID,
  INVOICE_NO,
  INVOICE_ID,
  BILLING_APPROVED_DATE,
  INVOICE_DATE,
  LINE_ITEM_TOTAL,
  RENTAL_RATE_FILTER,
  racs.ASSET_CLASS,
  ASSET_LIST,
  bdu.RUN_TIME,
  su.sub_renting_company,
  su.sub_renting_contact,
  ordered_by
FROM business_intelligence.triage.stg_t3__rental_asset_class_spend racs
left join by_day_util bdu on bdu.asset_id = racs.asset_id
left join sub_renters su on su.asset_id = racs.asset_id
      where
          invoice_date >= {% date_start date_filter %}
          and invoice_date <= {% date_end date_filter %}
          and {% condition po_filter %} purchase_order {% endcondition %}
          and {% condition jobsite_filter %} jobsite {% endcondition %}
          and {% condition vendor_filter %} vendor {% endcondition %}
          and {% condition rental_status_filter %} rental_status {% endcondition %}
          and company_id = {{ _user_attributes['company_id'] }}::integer
          and {% condition order_id_filter %} order_id {% endcondition %}
          and {% condition rental_rate_filter %} rental_rate_filter {% endcondition %}
          and {% condition asset_filter %} custom_name {% endcondition %}
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_link {
    type: string
    label: "Invoice #"
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{ invoice_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  measure: asset_invoice_list {
    label: "Invoices on Asset"
    type: list
    list_field: invoice_no
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: asset_list {
    label: "Asset(s)"
    type: string
    sql: ${TABLE}."ASSET_LIST" ;;
  }

  dimension: line_item_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_TOTAL" ;;
  }

  dimension: run_time {
    type: number
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: billing_approved_date_formatted {
    group_label: "HTML Passed Date Format"
    label: "Invoice Date"
    sql: ${billing_approved_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: invoice_date_formatted {
    group_label: "HTML Passed Date Format" label: "Invoice Date"
    sql: ${invoice_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_billed_amount {
    type: sum
    sql:${line_item_total};;
    value_format_name: usd
    html: <a href="#drillmenu" target="_self">{{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>;;
    drill_fields: [detail*]
  }

  measure: total_billed_amount_no_icon {
    group_label: "Drill Down"
    label: "Total Billed Amount"
    type: sum
    sql: ${line_item_total} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_assets_billed {
    type: count_distinct
    sql: ${asset_id} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} <font size='1'>assets</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>;;
    drill_fields: [asset_detail*]
  }

  measure: total_run_time {
    type: sum
    sql: round(coalesce(${run_time},0),2) ;;
    html: {{rendered_value}} <font size='1'>hrs.</font> ;;
  }

  set: detail {
    fields: [
      asset_class,
      invoice_date_formatted,
      invoice_link,
      total_billed_amount_no_icon,
      asset_list
    ]
  }

  set: asset_detail {
    fields: [
      asset_list,
      asset_class,
      invoice_link,
      total_billed_amount_no_icon
    ]
  }

}
