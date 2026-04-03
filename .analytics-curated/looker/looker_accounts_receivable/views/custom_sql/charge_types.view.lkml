view: charge_types {
  derived_table: {
    sql: select lit.line_item_type_id,
lit.name,
lit.invoice_display_name,
lit._es_update_timestamp AS line_item_creation_date,
a.accountno,
a.title,
a.whencreated,
gli_min.earliest_created_date as created_date,
lit.active
from es_warehouse.public.line_item_type_erp_refs lit_erp
left join es_warehouse.public.line_item_types lit on lit_erp.line_item_type_id = lit.line_item_type_id
left join analytics.intacct.glaccount a on lit_erp.intacct_gl_account_no = a.accountno
left join (
  select
    line_item_type_id,
    min(created_date) as earliest_created_date from es_warehouse.public.global_line_items group by line_item_type_id) gli_min on gli_min.line_item_type_id = lit_erp.line_item_type_id
order by a.accountno ;;
  }
  dimension: line_item_type_id {
    label: "Line Item Type ID"
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: name {
    label: "Line Item Name"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: invoice_display_name {
    label: "Invoice Display Name"
    type: string
    sql: ${TABLE}.invoice_display_name;;
  }

  dimension: accountno {
    label: "GL Account Number"
    type: number
    sql: ${TABLE}.accountno ;;
  }

  dimension: title {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: line_item_creation_date {
    label: "Line Item Update Date"
    type: date
    sql: ${TABLE}.line_item_creation_date ;;
  }

  dimension: whencreated {
    label: "GL Creation Date"
    type: date
    sql: ${TABLE}.whencreated ;;
  }

  dimension: created_dated {
    label: "Line Item Creation Date"
    type: date
    sql: ${TABLE}.created_date ;;
  }

  dimension: active {
    label: "Active"
    type: yesno
    sql: ${TABLE}.active ;;
  }
}
