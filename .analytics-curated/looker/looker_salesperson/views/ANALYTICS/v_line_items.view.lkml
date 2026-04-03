view: v_line_items {
  sql_table_name: "ANALYTICS"."PUBLIC"."V_LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
    value_format_name: id
  }

  dimension_group: gl_date_created {
    description: "This field is the date created for invoice line items and the credit note date created for credit note line items."
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
    description: "This field is the billing approved date for invoice line items and the credit note date created for credit note line items."
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



  dimension: invoice_id_pk {
    type: number
    sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0) ) ;;
    primary_key: yes
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
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
    # hidden: yes
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format_name: usd_0
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
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
    value_format_name: id
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, invoices.invoice_id]
  }

  dimension:  last_ytd_by_invoice_created_date{
    type: yesno
    sql: (date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month from ${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year from ${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year'))))
          OR
          (date_part(month,${gl_date_created_raw})  < date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year')))) ;;
  }

  dimension:  current_month_last_year_by_invoice_created_date{
    type: yesno
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year'))) ;;
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

  dimension: current_year_month {
    type: yesno
    sql: date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${gl_date_created_raw})  = date_part(year,(date_trunc('year', current_date))) ;;

  }

  dimension: ytd_billing_approved {
    type: yesno
    sql: ${gl_billing_approved_date_year}=year(current_date()) ;;
  }

  measure: rpp_amount_current_year {
    type: sum
    filters: [line_item_type_id: "9"]
    sql:
    case when date_part(year,${gl_date_created_raw})  = date_part(year,(date_trunc('year', current_date))) then
    ${amount} end ;;
    value_format_name: usd
    drill_fields: [rpp_charge_detail*]
  }

  measure: rpp_amount_last_year {
    type: sum
    filters: [line_item_type_id: "9"]
    sql:
    case when date_part(year,${gl_date_created_raw})  = date_part(year,(date_trunc('year', current_date - interval '1 year'))) then
    ${amount} end ;;
    value_format_name: usd
    drill_fields: [rpp_charge_detail*]
  }

  measure: month_to_date_rpp_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [current_year_month: "Yes",
      line_item_type_id: "9"]
    drill_fields: [rpp_charge_detail*]
  }

  measure: last_year_month_to_date_rpp_revenue{
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [current_month_last_year_by_invoice_created_date: "Yes",
      line_item_type_id: "9"]
  }

  measure: mtd_vs_lmtd_rpp_revenue {
    type: number
    sql: ${month_to_date_rpp_revenue} - ${last_year_month_to_date_rpp_revenue} ;;
    value_format_name: usd
    drill_fields: [rpp_charge_detail*]
  }

  measure: current_year_to_date_rpp_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [current_ytd_by_invoice_created_date: "Yes",
      line_item_type_id: "9"]
    drill_fields: [rpp_charge_detail*]
  }

  measure: last_year_to_date_rpp_revenue{
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [last_ytd_by_invoice_created_date: "Yes",
      line_item_type_id: "9"]
  }

  measure: ytd_vs_lytd_rpp_revenue {
    type: number
    sql: ${current_year_to_date_rpp_revenue} - ${last_year_to_date_rpp_revenue} ;;
    value_format_name: usd
    drill_fields: [rpp_charge_detail*]
  }

  measure: total_amount  { ## no drills
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: total_amount_5020 {
    type: sum
    sql: CASE WHEN ${line_item_type_id} IN (130,129,132,131) THEN ${amount} ELSE NULL END ;;
    value_format_name: usd_0
  }

  dimension: mtd {
    type:  number
    sql: CASE WHEN  concat(year(TO_DATE(${gl_billing_approved_date_date})),month(TO_DATE(${gl_billing_approved_date_date}))) = concat(year(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),month(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) THEN 1 ELSE 0 END ;;
  }

  dimension: mtd_previous {
    type: number
    sql:  CASE WHEN TO_DATE(${gl_billing_approved_date_date}) >= DATEADD(month, '-1',DATE_FROM_PARTS(year(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),month(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),1)) and TO_DATE(${gl_billing_approved_date_date}) <= DATEADD(month, '-1',CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN 1 ELSE 0 END;;
  }

  measure: total_amount_5020_mtd {
    type: sum
    sql: CASE WHEN ${line_item_type_id} IN (130,129,132,131) AND (${mtd} = 1) THEN ${amount} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: total_amount_5020_last_mtd {
    type: sum
    sql: CASE WHEN ${line_item_type_id} IN (130,129,132,131) AND ${mtd_previous} = 1 THEN ${amount} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_fuel_rev_arrows {
    type: number
    sql: ${total_amount_5020_mtd} - ${total_amount_5020_last_mtd};;
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

  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    drill_fields: [market_region_salesperson.Full_Name_with_ID, sales_users.Full_Name_with_ID, companies.name, total_revenue]
  }

  ##added to get new drill fields for revenue by rep on Customer Dashboard - Jolene 1/20/22
  measure: total_revenue_reps {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    drill_fields: [company_salesperson_rank.salesperson_name,invoices.invoice_id,invoices.start_date,invoices.end_date,total_rental_revenue]
  }

  measure: total_revenue_drill_into_market {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    drill_fields: [market_region_xwalk.market_name, total_revenue]
  }

  measure: total_parts_extended_drill_month {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    drill_fields: [gl_date_created_month, total_revenue]
    link: {
      label: "Revenue By Month"
      url: "
      {% assign vis_config = '{ \"type\" : \"looker_line\",
      \"interpolation\" : \"monotone\"
      }' %}

      {{ link }}&vis_config={{ vis_config | encode_uri }}&sorts=line_items.date_created_month+asc&toggle=dat,pik,vis&limit=500&column_limit=15"
    }
  }
  # {% assign vis_config = '{
  #   \"stacking\" : \"normal\",
  #   \"legend_position\" : \"right\",
  #   \"x_axis_gridlines\" : false,
  #   \"y_axis_gridlines\" : true,
  #   \"show_view_names\" : false,
  #   \"y_axis_combined\" : true,
  #   \"show_y_axis_labels\" : true,
  #   \"show_y_axis_ticks\" : true,
  #   \"y_axis_tick_density\" : \"default\",
  #   \"show_x_axis_label\" : true,
  #   \"show_x_axis_ticks\" : true,
  #   \"show_null_points\" : false,
  #   \"interpolation\" : \"monotone\",
  #   \"type\" : \"looker_line\",
  #   \"colors\": [
  #     \"#5245ed\",
  #     \"#ff8f95\",
  #     \"#1ea8df\",
  #     \"#353b49\",
  #     \"#49cec1\",
  #     \"#b3a0dd\"
  #   ],
  #   \"x_axis_label\" : \"Month Number\"
  # }' %}

  measure: total_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "8, 6, 108, 109"]
  }

  measure: retail_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "24, 50, 80, 81, 110, 111"]
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, invoices.admin_link_to_invoice, retail_revenue]
  }

  measure: ytd_customer_damage_revenue {
    type: running_total
    sql: ${customer_damage_revenue};;
    value_format_name: usd_0
  }

  measure: customer_damage_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "25, 26"]
    html: {{ytd_customer_damage_revenue._rendered_value}} YTD;;
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.admin_link_to_invoice, customer_damage_revenue]
  }

  measure: warranty_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23" , credit_note_id: "null"]
    html: {{warranty_revenue._rendered_value}} of {{ytd_warranty_revenue._rendered_value}} Requested YTD ;;
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.admin_link_to_invoice,work_orders.work_order_id_with_link_to_work_order, warranty_revenue_no_html]
  }
  measure: warranty_revenue_no_html {
    label: "Warranty Revenue"
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23" , credit_note_id: "null"]
  }
  measure: ytd_warranty_revenue {
    type: running_total
    sql: ${warranty_revenue};;
    value_format_name: usd_0
  }

  measure: warranty_credit {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23" , credit_note_id: "not null" ]
    html: {{warranty_credit._rendered_value}} of {{ytd_warranty_credit._rendered_value}} Denied YTD ;;
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.admin_link_to_invoice,work_orders.work_order_id_with_link_to_work_order, warranty_credit_no_html]
  }

  measure: warranty_credit_no_html {
    label: "Denied Warranty"
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23" , credit_note_id: "not null" ]
  }

  measure: ytd_warranty_credit {
    type: running_total
    sql: ${warranty_credit};;
    value_format_name: usd_0
  }
  measure: warranty_recovery {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23"]
    html: {{warranty_recovery._rendered_value}} of {{ytd_warranty_recovery._rendered_value}} Paid or Pending YTD ;;
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name,assets.assset_id, invoices.admin_link_to_invoice,work_orders.work_order_id_with_link_to_work_order, credit_note_id, warranty_recovery_no_html ]
  }
  measure: warranty_recovery_no_html {
    label: "Net Warranty"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "22, 23"]
  }
  measure: ytd_warranty_recovery {
    type: running_total
    sql: ${warranty_recovery};;
    value_format_name: usd_0
  }

  measure: parts_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "11, 12, 25, 29, 49"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, parts_revenue]
  }

  measure: service_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "13, 20, 26"]
    drill_fields: [invoices.billing_approved_month,market_region_xwalk.market_name,companies.name,invoices.invoice_link,service_revenue]
  }

  measure: tools_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "28"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, tools_revenue]
  }

  measure: fuel_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "2, 7, 21, 98, 99, 100, 101"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, tools_revenue]
  }

  # https://app.clubhouse.io/businessanalytics/story/34351/year-to-date-parts-sales-by-branch-by-month
  # Renae wants to see a breakdown of the following line types by branch on the new parts dashboard we're building in 2021:
  # Parts Retail Sale
  # Parts Freight Revenue
  # Merchandise/Supplies
  # Tools Revenue
  # Damage Parts
  # Service Equipment Parts
  # Rental Extra Equipment (diapers, socks etc.)
  # Warranty Parts Revenue
  # Warranty Labor Revenue
  measure: parts_extended_revenue {
    description: "Includes 9 line items identified by Renae that are important for her metrics. See LookML for type names."
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "49, 29, 12, 28, 25, 11, 16, 23, 22"]
    drill_fields: [market_region_xwalk.market_name, total_parts_extended_drill_month]
  }

  dimension: billing_approved_is_month_to_date {
    type: yesno
    sql: date_part(day,${gl_billing_approved_date_raw}) <= date_part(day,current_timestamp) ;;
  }

  measure: current_month_revenue_approved_date {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109",
      billing_approved_current_month: "yes"]
    link: {
      label: "Month To Date Revenue based on Invoice Billing Approved Date & Credit Note Create Date"
      # url: "https://equipmentshare.looker.com/looks/19?&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }
  measure: trailing_30_revenue_approved_date {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109",
      billing_approved_trailing_30: "yes"]
  }
  measure: current_month_revenue_create_date {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109",
      date_created_is_month_to_date: "yes"]
    link: {
      label: "Month To Date Revenue based on Invoice Create Date & Credit Note Create Date"
      # url: "https://equipmentshare.looker.com/looks/19?&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }
  dimension:  dated_last_year_month{
    type: yesno
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  measure: last_mtd_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109",
      dated_last_year_month: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  measure: last_month_rental_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109",
      last_full_month: "Yes"]
    drill_fields: [salesperson_invoice_detail*]
  }

  dimension:  billing_approved_last_month {
    type: yesno
    sql: date_part(month,${gl_billing_approved_date_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
      and date_part(year,${gl_billing_approved_date_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  billing_approved_current_month {
    type: yesno
    sql: date_part(day,${gl_billing_approved_date_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_billing_approved_date_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${gl_billing_approved_date_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
  }
  dimension: billing_approved_trailing_30 {
    type: yesno
    sql: ${gl_billing_approved_date_date} <= current_date AND ${gl_billing_approved_date_date} >= (current_date - INTERVAL '30 days') ;;
  }
  dimension:  last_full_month {
    type: yesno
    sql: date_part(month,${gl_date_created_raw}) = date_part(month,(date_trunc('month', current_date - interval '1 month')))
      and date_part(year,${gl_date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  measure: total_delivery_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5"]
    drill_fields: [gl_billing_approved_date_month,market_region_xwalk.market_name,companies.name,invoices.invoice_link,total_delivery_revenue]
  }

  measure: total_delivery_revenue_last_month {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5", billing_approved_last_month: "Yes"]
  }

  measure: total_delivery_revenue_current_mtd {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5", billing_approved_current_month: "Yes"]
  }

  measure: total_rental_revenue_last_month {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [line_item_type_id: "6, 8, 108, 109", billing_approved_last_month: "Yes"]
  }

  measure: total_rental_revenue_current_mtd {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [line_item_type_id: "6, 8, 108, 109", billing_approved_current_month: "Yes"]
  }

  measure: delivery_recovery_rate_last_month {
    type: number
    sql: ${total_delivery_revenue_last_month} / case when ${total_rental_revenue_last_month} = 0 then null else ${total_rental_revenue_last_month} end ;;
    value_format_name: percent_1
    drill_fields: [delivery_recovery_rate_detail*]
  }

  measure: delivery_recovery_rate_current_mtd {
    type: number
    sql: ${total_delivery_revenue_current_mtd} / case when ${total_rental_revenue_current_mtd} = 0 then null else ${total_rental_revenue_current_mtd} end ;;
    value_format_name: percent_1
    drill_fields: [delivery_recovery_rate_detail*]
  }

  measure: delivery_recovery_rate {
    type: number
    sql: ${total_delivery_revenue} / case when ${total_rental_revenue} = 0 then null else ${total_rental_revenue} end ;;
    value_format_name: percent_1
  }

  dimension: date_created_is_month_to_date {
    type: yesno
    sql: date_part(day,${gl_date_created_raw}) <= date_part(day,current_timestamp);;
  }

  set: rpp_charge_detail {
    fields: [
      companies.name,
      date_created_date,
      month_to_date_rpp_revenue,
      last_year_month_to_date_rpp_revenue,
      mtd_vs_lmtd_rpp_revenue,
      current_year_to_date_rpp_revenue,
      last_year_to_date_rpp_revenue,
      ytd_vs_lytd_rpp_revenue
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
      total_rental_revenue
    ]
  }

  set: delivery_recovery_rate_detail {
    fields: [invoices.billing_approved_month,
      market_region_xwalk.market_name,
      total_delivery_revenue,
      total_rental_revenue,
      delivery_recovery_rate]
  }

  dimension:  billing_appr_last_mtd{
    type: yesno
    sql: date_part(day,${gl_billing_approved_date_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${gl_billing_approved_date_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${gl_billing_approved_date_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
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

  set: ancillary_revenue_total_drill {
    fields: [gl_billing_approved_date_month,
      ancillary_recode,
      total_ancillary_revenue
    ]
  }

  dimension: commission_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109,44)
          or (${line_item_type_id} = 5 and ${amount}>=95 and ${gl_billing_approved_date_raw}>'2022-01-31'::date and ${gl_billing_approved_date_raw}<'2022-09-01'::date)
          or (${line_item_type_id} = 5 and ${amount}>=125 and ${gl_billing_approved_date_raw}>'2022-08-31'::date);;
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
}
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
