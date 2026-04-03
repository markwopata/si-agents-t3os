view: assets_sold_with_trackers {
  derived_table: {
    sql:

select
    i.invoice_date,
    coalesce(q.contact_email, u.email_address) email_address,
    coalesce(split_part(q.contact_name, ' ', 1), u.first_name) first_name,
    coalesce(split_part(q.contact_name, ' ', 2), u.last_name) last_name,
    MIN(i.invoice_date) OVER (PARTITION BY th.company_id) AS min_invoice_date,
    th.tracker_last_date_installed,
    i.invoice_id,
    o.order_id,
    th.asset_health_detail,
    th.keypad_install_status,
    th.tracker_install_status,
    li.line_item_id,
    li.line_item_type_id,
    li.description,
    a.asset_id,
    th.company_name,
    th.company_id,
    li.number_of_units,
    a.asset_equipment_class_name asset_class,
    a.asset_equipment_make make,
    a.asset_equipment_model_name model,
    a.asset_current_oec oec
from es_warehouse.public.line_items li
join platform.gold.v_assets a on li.asset_id = a.asset_id
join es_warehouse.public.invoices i on li.invoice_id = i.invoice_id
join es_warehouse.public.orders o on i.order_id = o.order_id
join business_intelligence.triage.stg_t3__telematics_health th on a.asset_id = th.asset_id
join es_warehouse.public.companies c on i.company_id = c.company_id
join es_warehouse.public.users u on o.user_id = u.user_id
left join quotes.quotes.quote q on o.order_id = q.order_id
where li.line_item_type_id in (24, 50, 111, 81, 123)
and year(i.invoice_date) > 2024
and th.company_name not in ('EquipmentShare.com-Retail Sale', 'EQUIPMENTSHARE.COM INC')
and th.company_id not in (
select distinct(company_id) from analytics.t3_saas_billing.customer_master
)
and th.tracker_install_status in ('CORRECT TRACKER', 'INCORRECT TRACKER')
      ;;
  }


  dimension: invoice_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}.line_item_id ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }


  dimension_group: invoice_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.invoice_date ;;
  }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Invoice Date"
    type: date
    datatype: date
    sql: ${TABLE}.invoice_date ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }

  # ---- Line Item Info ----
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  # ---- Company Info ----
  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  # ---- Contact Info ----
  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}.phone_number ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: keypad_install_status {
    type: string
    sql: ${TABLE}.keypad_install_status ;;
  }

  dimension: has_keypad {
    type: yesno
    sql: case when ${keypad_install_status} = 'KEYPAD' then true else false end;;
    skip_drill_filter: yes
  }

  measure: count {
    type: count
    drill_fields: [invoice_id, company_name, asset_id]
  }

  dimension: min_invoice_date {
    group_label: "Min Invoice Date"
    label: "Invoice Date"
    type: date
    datatype: date
    sql: ${TABLE}.min_invoice_date ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
    skip_drill_filter: yes
  }

  dimension: OEC {
    type: number
    sql: ${TABLE}.oec ;;
    value_format_name: usd_0
  }

  measure: oec_sum {
    group_label: "oec sum"
    label: "OEC"
    type: sum
    sql: ${OEC} ;;
    value_format_name: usd_0
  }


  measure: number_of_assets {
    label: "No. of Assets"
    type: sum
    sql: ${TABLE}.number_of_units ;;
    drill_fields: [formatted_date, invoice_id, asset_id, asset_class, make, model, OEC, has_keypad]
  }

}
