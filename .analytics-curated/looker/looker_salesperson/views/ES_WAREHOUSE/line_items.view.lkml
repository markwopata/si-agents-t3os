view: line_items {
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
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
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
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
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

  dimension: ancillary_recode {
    type: string
    label: "Ancillary Revenue Groups"
    case: {
      when: {
        sql: ${TABLE}.line_item_type_id = 44 ;;
        label: "Nonserialized"
      }
      when: {
        sql: (${TABLE}.line_item_type_id = 5 and ${TABLE}.gl_billing_approved_date > '2022-01-31'::date and ${TABLE}.gl_billing_approved_date < '2022-09-01'::date and ${TABLE}.amount >= 95)
          OR (${TABLE}.line_item_type_id = 5 and ${TABLE}.gl_billing_approved_date > '2022-08-31'::date and ${TABLE}.amount >= 125);;
        label: "Delivery"
      }
      else: "null"
      }
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

  measure: month_to_date_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: month_to_date_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes",
              rental_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: month_to_date_delivery_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes",
      line_item_type_id: "5"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: month_to_date_ancillary_revenue {
    group_label: "Ancillary Revenue"
    description: "Total of line items for commission eligible delivery and bulk"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes",
      line_item_type_id: "44,5",
      commission_line_items: "Yes"]
    drill_fields: [ancillary_revenue_total_drill*]
  }

  measure: last_mtd_ancillary_revenue {
    group_label: "Ancillary Revenue"
    description: "Total of line items for commission eligible delivery and bulk"
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "44,5",
      commission_line_items: "Yes",
      billing_appr_last_mtd: "Yes"]
    drill_fields: [ancillary_revenue_total_drill*]
  }

  measure: total_ancillary_revenue {
    group_label: "Ancillary Revenue"
    description: "Total by line item for commission eligible delivery and bulk"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "44,5",
      commission_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }


  dimension: mtd {
    type:  number
    sql: CASE WHEN  concat(year(TO_DATE(${gl_billing_approved_date_date})),month(TO_DATE(${gl_billing_approved_date_date}))) = concat(year(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),month(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) THEN 1 ELSE 0 END ;;
  }

  dimension: mtd_previous {
    type: number
    sql:  CASE WHEN TO_DATE(${gl_billing_approved_date_date}) >= DATEADD(month, '-1',DATE_FROM_PARTS(year(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),month(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),1)) and TO_DATE(${gl_billing_approved_date_date}) <= DATEADD(month, '-1',CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 END;;
  }

  measure: total_ancillary_mtd {
    type: sum
    sql: CASE WHEN ${line_item_type_id} IN (44,5) AND (${mtd} = 1) AND ${commission_line_items} = 'Yes' THEN ${amount} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: total_ancillary_last_mtd {
    type: sum
    sql: CASE WHEN ${line_item_type_id} IN (44,5) AND (${mtd_previous} = 1) AND ${commission_line_items} = 'Yes' THEN ${amount} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_ancillary_rev_arrows {
    type: number
    sql: ${total_ancillary_mtd} - ${total_ancillary_last_mtd};;
    value_format_name:  usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }





  measure: MTD_Revenue {
    description: "This is the total revenue with a tooltip box that shows the breakdown by rental and >$95 delivery charges."
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  ##  html: Rental - {{ month_to_date_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ month_to_date_delivery_revenue._rendered_value }};;
  }

  # dimension: Current_Month {
  #   description: "Dummy variable to overide tooltip box showing undefined"
  #   type: date_month_name
  #   sql: current_date;;
  # }

  dimension: retail_line_items {
    type: yesno
    sql: ${line_item_type_id} in (24, 50, 80, 81, 110, 111, 123, 127, 141) ;;
  }

  dimension: rental_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109) ;;
  }

  dimension: commission_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109,44)
    or (${line_item_type_id} = 5 and ${amount}>=95 and ${gl_billing_approved_date_raw}>'2022-01-31'::date and ${gl_billing_approved_date_raw}<'2022-09-01'::date)
    or (${line_item_type_id} = 5 and ${amount}>=125 and ${gl_billing_approved_date_raw}>'2022-08-31'::date);;
  }

  dimension: current_year_month {
    type: yesno
    sql: date_part(month,${gl_billing_approved_date_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${gl_billing_approved_date_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension:  date_created_last_mtd{
    type: yesno
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  billing_appr_last_mtd{
    type: yesno
    sql: date_part(day,${gl_billing_approved_date_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_billing_approved_date_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_billing_approved_date_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    drill_fields: [invoices.invoice_no,
                   market_region_salesperson.Full_Name_with_ID,
                   sales_users.Full_Name_with_ID,
                   companies.name,
                   invoices.paid,
                   total_revenue]
  }

  measure: last_mtd_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes",
      billing_appr_last_mtd: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: last_mtd_delivery_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "5",
      date_created_last_mtd: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }


  measure: last_month_rental_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes",
      last_full_month: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes"]
  }

  measure: in_market_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [salesperson_to_market.is_main_market: "yes",
      rental_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: out_of_market_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [salesperson_to_market.is_main_market: "no",
      rental_line_items: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: count {
    type: count
    drill_fields: [line_item_id]
  }

  dimension: is_quarter_to_date {
    type: yesno
    sql: date_part(quarter,${gl_date_created_raw}) <= date_part(quarter,current_timestamp) ;;
  }

  dimension:  last_full_month {
    type: yesno
    sql: date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  dated_last_year_month{
    type: yesno
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  current_ytd_by_invoice_created_date{
    type: yesno
    sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date))))
          OR
          (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date)))) ;;
  }

  dimension:  last_ytd_by_invoice_created_date{
    type: yesno
    sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year'))))
          OR
          (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year')))) ;;
  }

  dimension:  last_qtd_by_invoice_created_date{
    type: yesno
    sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '90 days'))))
          OR
          (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '90 days')))) ;;
  }

  measure: last_mtd_retail_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      dated_last_year_month: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, invoices.invoice_id,asset_id,description,last_mtd_retail_revenue]
  }

#Month to Date revenue
  measure: year_to_date_retail_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      current_ytd_by_invoice_created_date: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name,invoices.invoice_id,asset_id,description, year_to_date_retail_revenue]
  }

  measure: last_ytd_retail_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      last_ytd_by_invoice_created_date: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, invoices.invoice_id,asset_id,description,last_ytd_retail_revenue]
  }


#Month to Date revenue
  measure: quarter_to_date_retail_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      is_quarter_to_date: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name,invoices.invoice_id,asset_id,description, quarter_to_date_retail_revenue]
  }

  measure: last_qtd_retail_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      last_qtd_by_invoice_created_date: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, invoices.invoice_id,asset_id,description,last_qtd_retail_revenue]
  }

  dimension: admin_link_to_invoice {
    label: "Admin Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  measure: number_of_qtd_retail_line_items {
    type: count
    filters: [retail_line_items: "Yes",
      is_quarter_to_date: "Yes"]
    drill_fields: [line_item_id, invoices.invoice_id,asset_id,description,retail_revenue]
  }

  measure: retail_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, retail_revenue]
  }

  measure: number_of_line_items {
    type: count
    drill_fields: [line_item_id, invoices.invoice_id]
  }

  measure: number_of_mtd_retail_line_items {
    type: count
    filters: [retail_line_items: "Yes",
      current_year_month: "Yes"]
    drill_fields: [line_item_id, invoices.invoice_id,asset_id,description, retail_revenue]
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    description: "No filters"
  }

#Month to Date revenue
  measure: month_to_date_retail_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [retail_line_items: "Yes",
      current_year_month: "Yes"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name,invoices.invoice_id,asset_id,description, month_to_date_retail_revenue]
  }

  measure: number_of_retail_line_items {
    type: count
    filters: [retail_line_items: "Yes"]
    drill_fields: [line_item_id, invoices.invoice_id,assets.asset_id,retail_revenue]
  }

  measure: service_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "20,13"]
    drill_fields: [invoices.billing_approved_month,market_region_xwalk.market_name,companies.name,invoices.invoice_no,service_revenue]
  }

  measure: parts_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "11,12"]
    drill_fields: [invoices.billing_approved_month,market_region_xwalk.market_name,companies.name,invoices.invoice_no,parts_revenue]
  }

  measure: total_delivery_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5"]
    drill_fields: [invoices.billing_approved_month,market_region_xwalk.market_name,companies.name,invoices.invoice_no,total_delivery_revenue]
  }

  measure: total_rental_revenue_kpi_test {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_line_items: "Yes"]
    html:
    <div style="border-radius: 5px;">
    <div style="display: inline-block; padding-bottom: 20px;">
        <p style="font-size: 1.25rem;">MTD Revenue</p>
        <p style="font-size: 2rem;">$100.50K</p>
    </div>
    <div style="display: inline-block; border-left: .5px solid #DCDCDC; padding-left: 10px;">
        <p style="font-size: 1.5rem;">vs Goal <font color="#00CB86"><strong>↑100K</strong></font></p>
        <p style="font-size: 1.5rem;">vs Last Year <font color="#DA344D"><strong>↓250K</strong></font></p>
    </div>
</div>
 ;;
  }

  measure: difference_current_last_mtd_rental_revenue_K {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    value_format: "$0.00,\" K\""
    sql: ${month_to_date_rental_revenue} - ${last_mtd_revenue} ;;
  }

  measure: difference_current_last_mtd_rental_revenue_M {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    value_format: "$0.00,,\" M\""
    sql: ${month_to_date_rental_revenue} - ${last_mtd_revenue} ;;
  }


  measure: difference_current_last_mtd_rental_revenue {
    group_label: "Current vs Last MTD Rental Revenue"
    type: number
    sql: ${month_to_date_rental_revenue} - ${last_mtd_revenue} ;;
    required_fields: [difference_current_last_mtd_rental_revenue_M,difference_current_last_mtd_rental_revenue_K]
    html: <div style="border-radius: 5px;">
            <p style="font-size: 1.25rem;">Current vs Last MTD Rental Revenue</p>
            <p style="font-size: 2rem;">
              {% if value >= 1000000 %}
                <font color="#00CB86">
                <strong>↑{{difference_current_last_mtd_rental_revenue_M._rendered_value}}</strong></font>
              {% elsif value >= 1000 %}
                <font color="#00CB86">
                <strong>↑{{difference_current_last_mtd_rental_revenue_K._rendered_value}}</strong></font>
              {% elsif value >= 0 %}
                <font color="#00CB86">
                <strong>↑{{rendered_value}}</strong></font>
              {% elsif value <= -1000000 %}
                <font color="#DA344D">
                <strong>↓{{difference_current_last_mtd_rental_revenue_M._rendered_value}}</strong></font>
              {% elsif value <= -1000 %}
                <font color="#DA344D">
                <strong>↓{{difference_current_last_mtd_rental_revenue_K._rendered_value}}</strong></font>
              {% else %}
                <font color="#DA344D">
                <strong>↓{{rendered_value}}</strong></font>
              {% endif %}
            </p>
        </div> ;;
  }

  set: ancillary_revenue_total_drill {
    fields: [gl_billing_approved_date_month,
      ancillary_recode,
      total_ancillary_revenue
      ]
  }

  set: salesperson_invoice_detail {
    fields: [
      market_region_salesperson.Full_Name_with_ID,
      companies.name,
      invoices.invoice_no,
      invoices.invoice_id,
      invoices.billing_approved_date,
      invoices.invoice_date,
      total_revenue
    ]
  }
}
