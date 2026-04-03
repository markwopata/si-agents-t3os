view: line_items {
  sql_table_name: "GLOBAL_BILLING"."GLOBAL_BILLING"."LINEITEMS" ;;
  # sql_table_name: "PUBLIC"."LINE_ITEMS"
  #  ;;
  drill_fields: [id]

  dimension: id {
    label: "Line Item ID"
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
    value_format_name: id
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}."UUID" ;;
  }

  dimension: erp_line_item_id {
    type: string
    sql: ${TABLE}."ERP_LINE_ITEM_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
    value_format_name: usd
  }

  dimension: sub_total {
    type: number
    sql: ${price} * ${quantity} ;;
    value_format_name: usd
  }

  dimension: total {
    type: number
    sql: ${sub_total}+coalesce(${tax},0) ;;
    value_format_name: usd
  }

  dimension: metadata {
    type: string
    sql: ${TABLE}."METADATA" ;;
  }

  dimension: charge_id {
    type: number
    sql: ${TABLE}."CHARGEID" ;;
  }

  dimension: charge_uuid {
    type: string
    sql: ${TABLE}."CHARGE_UUID" ;;
  }

  dimension: manually_inserted {
    type: string
    sql: ${TABLE}."MANUALLYINSERTED" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  # dimension: event_id {
  #   type: number
  #   sql: ${TABLE}."EVENTID" ;;
  # }

  dimension: manually_updated {
    type: string
    sql: ${TABLE}."MANUALLYUPDATED" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICEID" ;;
    # html: <font color="blue"><u><a href="https://manage.estrack.io/billing/v2/invoices/{{ invoices.uuid._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
    html: <font color="blue"><u><a href="https://global.dev.estrack.io/billing/invoices/{{ invoices.uuid._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
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

  dimension_group: created {
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
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', ${TABLE}."CREATEDATETIME") ;;
  }

  dimension_group: deleted {
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
    sql: CAST(${TABLE}."DELETEDAT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_id {
    type: number
    # sql: ${metadata}:rental_id::number ;;
    sql: ${TABLE}."RENTALID" ;;
    value_format_name: id
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: billed_from_date {
    type: date
    # sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', to_date(to_char(${metadata}:rental.billed_from_date))) ;;
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', ${TABLE}."BILLEDFROM") ;;
  }

  dimension: billed_to_date {
    type: date
    # sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', to_date(to_char(${metadata}:rental.billed_to_date))) ;;
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', ${TABLE}."BILLEDTO") ;;
  }

  dimension: cycle_billing_date {
    type: date
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', to_date(to_char(${metadata}:rental.cycle_billing_date))) ;;
  }

  dimension: billing_week_days {
    type: number
    sql: ${metadata}:rental.billing_week_days ;;
  }

  dimension: asset_id {
    type: number
    sql: coalesce(${metadata}:assetId::number,${metadata}:asset_id::number,${metadata}:rental.asset_id::number) ;;
    value_format_name: id
  }

  dimension: transport_id {
    type: number
    sql: ${metadata}:transport_id::number ;;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: coalesce(${metadata}:assetClass::string,${metadata}:rental.asset_class::string) ;;
  }

  dimension:  dated_last_year_month{
    type: yesno
    sql: date_part(day,${invoices.issue_date}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${invoices.issue_date})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${invoices.issue_date}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension: MTD {
    type: yesno
    sql: month(${invoices.issue_raw}) = month(current_date);;
  }

  dimension: billed_line_item_based_on_invoice {
    label: "Billed Line Item"
    type: yesno
    sql:  line_items.id > 0 ;;
  }

  dimension_group: num_billed_days {
    label: "Days Billed"
    type: duration
    intervals: [day]
    sql_start: ${billed_from_date} ;;
    sql_end: ${billed_to_date} ;;
  }

  measure: total_revenue_without_tax {
    label: "Total Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [deleted_date: "NULL",
             invoices.deleted_date: "NULL"]
    drill_fields: [invoices.issue_date_date,companies.name, invoices.due_date, invoices.invoice_name, total]
  }

  measure: total_revenue_with_tax {
    type: sum
    sql: ${total};;
    value_format_name: usd_0
    filters: [deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
  }

  measure: mtd_rental_revenue {
    label: "Billed MTD Rental"
    type: sum
    sql: ${sub_total};;
    value_format_name: usd_0
    filters: [charge_id: "1",
             MTD: "Yes",
             deleted_date: "NULL",
             invoices.deleted_date: "NULL"]
  }

  measure: total_rental_revenue {
    label: "Rental Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "1",
              deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: total_rental_revenue_approved {
    label: "Rental Billed (Approved)"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "1",
      invoices.status: "Approved",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: total_rental_price {
    type: sum
    sql: ${price} ;;
    value_format_name: usd_0
    filters: [charge_id: "1",
              deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
    }

  measure: total_transport_price {
    type: sum
    sql: ${price} ;;
    value_format_name: usd
    filters: [charge_id: "7",
              deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
    drill_fields: [transport_details.transport_details*]
    }

  measure: last_mtd_rental_revenue {
    label: "Billed Last MTD Rental"
    type: sum
    sql: ${sub_total};;
    value_format_name: usd_0
    filters: [charge_id: "1",
      dated_last_year_month: "Yes",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
  }

  measure: rental_transport_price {
    type: sum
    sql: ${price} ;;
    value_format_name: usd
    filters: [charge_id: "1, 7",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
  }

  measure: rental_transport_revenue_without_tax {
    label: "Rental/Transport Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "1, 7",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: transport_revenue_without_tax {
    label: "Transport Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "7",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: rpp_revenue_without_tax {
    label: "RPP Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "2",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: checkin_revenue_without_tax {
    label: "Checkin Charges Billed"
    type: sum
    sql: ${sub_total} ;;
    value_format_name: usd_0
    filters: [charge_id: "3,4,5,6",
      deleted_date: "NULL",
      invoices.deleted_date: "NULL"]
    drill_fields: [invoice_detail*]
  }

  measure: outstanding_billed_price_rental_transport_without_tax {
    type: number
    sql:  ${rental_transport_price} - ${rental_transport_revenue_without_tax} ;;
    value_format_name: usd
    drill_fields: [invoice_detail*]
  }

  measure: outstanding_billed_price_transport_without_tax {
    type: number
    sql:  ${total_transport_price} - ${transport_revenue_without_tax} ;;
    value_format_name: usd
    drill_fields: [invoice_detail*]
  }

  measure: num_line_items {
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
  }

  measure: num_unassigned_line_items {
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
    filters: [invoices.id: "NULL",
              deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
    drill_fields: [unassigned_detail*]
  }

  measure: num_unassigned_completed_rentals_line_items {
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
    filters: [invoices.id: "NULL",
              rental_details.rental_status: "Completed",
              deleted_date: "NULL",
              invoices.deleted_date: "NULL"]
    drill_fields: [unassigned_detail*]
    link: {label: "Drill by Ordered Rental ID" url: "{{ num_unassigned_completed_rentals_line_items._link}}&sorts=line_items.rental_id+asc" }
  }

  set: invoice_detail {
    fields: [invoices.invoice_name, invoices.issue_date, companies.name, invoices.due_date, charges.name, sub_total, tax, total]
  }

  set: unassigned_detail {
    fields: [rental_id,
            rental_details.rental_status,
            invoices.invoice_name,
            id,
            description,
            charges.name,
            rental_details.customer,
            invoices.issue_date,
            rental_details.asset_id,
            rental_details.asset_class,
            rental_details.start_date,
            rental_details.end_date,
            quantity,
            price,
            created_time,
            billed_from_date,
            billing_week_days,
            cycle_billing_date,
            events.name,
            manually_inserted,
            manually_updated]
  }

}
