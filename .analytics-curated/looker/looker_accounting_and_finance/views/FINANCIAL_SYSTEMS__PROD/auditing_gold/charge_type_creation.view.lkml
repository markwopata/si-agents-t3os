view: charge_types {
  derived_table: {
    sql: select acd.pk_line_item_type_id as line_item_type_id,
      acd.line_item_type_name as name,
      acd.invoice_display_name,
      acd.number_account as accountno,
      acd.name_account as title,
      acd.timestamp_created as whencreated,
      acd.created_date as created_date,
      acd.is_active as active
      from financial_systems.auditing_gold.charge_type_creation_date_audit acd ;;
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
