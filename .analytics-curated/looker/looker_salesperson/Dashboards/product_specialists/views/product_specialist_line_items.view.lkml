view: product_specialist_line_items {
  sql_table_name: "ANALYTICS"."PUBLIC"."V_LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]


  dimension_group: gl_date_created {
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
    sql: CAST(${TABLE}."GL_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: gl_billing_approved_date {
    label: "Billing Approved Date"
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
    sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id_pk {
    type: number
    sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0) ) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
    value_format_name: id
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

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
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

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }

  dimension: override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."OVERRIDE_MARKET_TAX_RATE" ;;
  }

  dimension: tax_rate_id {
    type: number
    sql: ${TABLE}."TAX_RATE_ID" ;;
  }

  dimension: payouts_processed {
    type: yesno
    sql: ${TABLE}."PAYOUTS_PROCESSED" ;;
  }

  dimension: tax_rate_percentage {
    type: number
    sql: ${TABLE}."TAX_RATE_PERCENTAGE" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: rental_line_items {
    type: yesno
    hidden: yes
    sql: ${line_item_type_id} in (6,8,108,109) ;;
  }

  #only commissionable delivery items
  dimension: delivery_line_items {
    type: yesno
    hidden: yes
    sql: (${line_item_type_id} = 5 and ${gl_billing_approved_date_raw} > '2022-01-31' and ${gl_billing_approved_date_raw} < '2022-09-01' and ${amount}>=95) OR
         (${line_item_type_id} = 5 and ${gl_billing_approved_date_raw} > '2022-08-31' and ${amount}>=125);;
  }

  #as defined by Marc Santosuosso - removing some from dashboard 9/21/22 because not commission eligible
  dimension: ancillary_line_items {
    type: yesno
    hidden: yes
    sql: --${line_item_type_id} in (13,20,44,21,98,99,100,101,102,103,104,105) or
        ${line_item_type_id} in (44)
    OR  (${line_item_type_id} = 5 and ${gl_billing_approved_date_raw} > '2022-01-31' and ${gl_billing_approved_date_raw} < '2022-09-01' and ${amount}>=95)
    OR  (${line_item_type_id} = 5 and ${gl_billing_approved_date_raw} > '2022-08-31' and ${amount}>=125);;
  }

  dimension: labor_line_items {
    type: yesno
    hidden: yes
    sql: ${line_item_type_id} in (13,20) ;;
  }

  #as defined by Marc Santosuosso
  dimension: nonserialized_line_items {
    type: yesno
    hidden: yes
    sql: ${line_item_type_id} = 44 ;;
  }

 #as defined by Marc Santosuosso
  dimension: fuel_line_items {
    type: yesno
    hidden: yes
    sql: ${line_item_type_id} in (21,98,99,100,101,102,103,104,105) ;;
  }

  dimension: ancillary_recode {
    type: string
    label: "Ancillary Revenue Group"
    case: {
      when: {
        sql: ${TABLE}.line_item_type_id = 44 ;;
        label: "Nonserialized"
      }
      # when: {
      #   sql: ${TABLE}.line_item_type_id in (13,20) ;;
      #   label: "Labor"
      # }
      # when: {
      #   sql: ${TABLE}.line_item_type_id in (21,98,99,100,101,102,103,104,105) ;;
      #   label: "Fuel"
      # }
      when: {
        sql: (${TABLE}.line_item_type_id = 5 and ${TABLE}.gl_billing_approved_date > '2022-01-31' and ${TABLE}.gl_billing_approved_date < '2022-09-01' and ${TABLE}.amount >= 95)
            OR (${TABLE}.line_item_type_id = 5 and ${TABLE}.gl_billing_approved_date > '2022-08-31' and ${TABLE}.amount >= 125);;
        label: "Delivery"
      }
      else: "null"
    }
  }

  dimension: date_created_current_year_month {
    type: yesno
    hidden: yes
    sql: date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${gl_date_created_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension:  date_created_last_mtd {
    type: yesno
    hidden: yes
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
        and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
        and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  # dimension: Current_Month {
  #   description: "Dummy variable to overide tooltip box showing undefined"
  #   type: date_month_name
  #   sql: current_date;;
  #   }

#   measure: month_to_date_revenue {
#       type: sum
#       sql: ${amount} ;;
#       value_format_name: usd_0
#       filters: [current_year_month: "Yes"]
#       drill_fields: [salesperson_invoice_detail*]
#     }

  measure: last_mtd_rental_revenue {
    group_label: "Rental Revenue"
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes",
      date_created_last_mtd: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: mtd_rental_revenue {
    group_label: "Rental Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [date_created_current_year_month: "Yes",
      rental_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: total_rental_revenue {
    group_label: "Rental Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: mtd_delivery_revenue {
    group_label: "Delivery Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [date_created_current_year_month: "Yes",
      line_item_type_id: "5"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: last_mtd_delivery_revenue {
    group_label: "Delivery Revenue"
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "5",
      date_created_last_mtd: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: labor_revenue {
    group_label: "Ancillary Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [labor_line_items: "Yes"]
    drill_fields: [ancillary_revenue_detail_drill*]
  }

  measure: fuel_revenue {
    group_label: "Ancillary Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [fuel_line_items: "Yes"]
    drill_fields: [ancillary_revenue_detail_drill*]
  }

  measure: nonserialized_revenue {
    group_label: "Ancillary Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [nonserialized_line_items: "Yes"]
    drill_fields: [ancillary_revenue_detail_drill*]
  }

  measure: delivery_revenue {
    group_label: "Ancillary Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [delivery_line_items: "Yes"]
    drill_fields: [ancillary_revenue_detail_drill*]
  }

#     measure: MTD_Revenue {
#       description: "This is the total revenue with a tooltip box that shows the breakdown by rental and >$95 delivery charges."
#       type: sum
#       sql: ${amount} ;;
#       value_format_name: usd_0
#       filters: [current_year_month: "Yes"]
#       drill_fields: [salesperson_invoice_detail*]
#       ##  html: Rental - {{ month_to_date_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ month_to_date_delivery_revenue._rendered_value }};;
#     }

#     dimension: retail_line_items {
#       type: yesno
#       sql: ${line_item_type_id} in (24,80,50,81) ;;
#     }


#     dimension: commission_line_items {
#       type: yesno
#       sql: ${line_item_type_id} in (6,8,108,109) or (${line_item_type_id} = 5 and ${amount}>=95 and ${gl_billing_approved_date_raw}>'2022-01-31'::date) ;;
#     }




    measure: total_ancillary_revenue {
      group_label: "Ancillary Revenue"
      description: "Total to use for second drill downs"
      type: sum
      sql: ${amount} ;;
      filters: [ancillary_line_items: "Yes"]
      value_format_name: usd_0
      drill_fields: [ancillary_revenue_total_drill*]
    }

    measure: ancillary_grouped_revenue {
      group_label: "Ancillary Revenue"
      description: "Total to use for second drill down"
      type: sum
      sql: ${amount} ;;
      filters: [ancillary_line_items: "Yes"]
      value_format_name: usd_0
      drill_fields: [ancillary_revenue_detail_drill*]
    }

  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    drill_fields: [revenue_line_item_drill*]
  }


#     measure: last_month_rental_revenue {
#       type: sum
#       sql: ${amount};;
#       value_format_name: usd_0
#       filters: [rental_line_items: "Yes",
#         last_full_month: "Yes"]
#       drill_fields: [salesperson_invoice_detail*]
#     }

#     dimension: is_quarter_to_date {
#       type: yesno
#       sql: date_part(quarter,${gl_date_created_raw}) <= date_part(quarter,current_timestamp) ;;
#     }

#     dimension:  last_full_month {
#       type: yesno
#       sql: date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
#         and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
#     }

#     dimension:  dated_last_year_month{
#       type: yesno
#       sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
#           and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
#     }

#     dimension:  current_ytd_by_invoice_created_date{
#       type: yesno
#       sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
#           and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date))))
#           OR
#           (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date)))) ;;
#     }

#     dimension:  last_ytd_by_invoice_created_date{
#       type: yesno
#       sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
#           and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year'))))
#           OR
#           (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year')))) ;;
#     }

#     dimension:  last_qtd_by_invoice_created_date{
#       type: yesno
#       sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
#           and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '90 days'))))
#           OR
#           (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
#           and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '90 days')))) ;;
#     }



#     dimension: admin_link_to_invoice {
#       label: "Admin Link to Invoice"
#       type: string
#       html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
#       sql: ${invoice_id}  ;;
#     }

#     measure: number_of_line_items {
#       type: count
#       drill_fields: [line_item_id, invoices.invoice_id]
#     }

#     measure: total_amount {
#       type: sum
#       sql: ${amount} ;;
#       value_format_name: usd
#       description: "No filters"
#     }

# #Month to Date revenue
#     measure: month_to_date_retail_revenue {
#       type: sum
#       sql: ${amount} ;;
#       value_format_name: usd_0
#       filters: [retail_line_items: "Yes",
#         current_year_month: "Yes"]
#       drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name,invoices.invoice_id,asset_id,description, month_to_date_retail_revenue]
#     }

#     measure: number_of_retail_line_items {
#       type: count
#       filters: [retail_line_items: "Yes"]
#       drill_fields: [line_item_id, invoices.invoice_id,assets.asset_id,retail_revenue]
#     }


#     measure: total_delivery_revenue {
#       type: sum
#       sql: ${amount} ;;
#       value_format_name: usd_0
#       filters: [line_item_type_id: "5"]
#       drill_fields: [invoices.billing_approved_month,market_region_xwalk.market_name,companies.name,invoices.invoice_no,total_delivery_revenue]
#     }

  set: salesperson_invoice_detail {
    fields: [
      product_specialist_list.full_name_with_id,
      market_region_xwalk.market_name,
      market_region_xwalk.region_name,
      companies.name,
      invoices.invoice_no,
      invoices.invoice_id,
      invoices.billing_approved_date,
      invoices.invoice_date,
      total_rental_revenue
    ]
  }

  set: ancillary_revenue_detail_drill {
    fields: [gl_billing_approved_date_month,
      line_item_types.invoice_display_name,
      total_revenue
    ]
  }

  set: ancillary_revenue_total_drill {
    fields: [gl_billing_approved_date_month,
      ancillary_recode,
      ancillary_grouped_revenue
    ]
  }

  set: revenue_line_item_drill {
    fields:  [companies.name,
      invoices.invoice_no,
      invoices.invoice_id,
      invoices.billing_approved_date,
      total_revenue
    ]
  }
}
