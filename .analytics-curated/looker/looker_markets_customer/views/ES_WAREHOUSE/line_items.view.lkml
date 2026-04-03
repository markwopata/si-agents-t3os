view: line_items {
  sql_table_name: "ANALYTICS"."PUBLIC"."V_LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]

  dimension_group: zzz_test_timezone {
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
    sql: CURRENT_TIMESTAMP() ;;
  }

  measure: testing_one_two {
    type: max
    sql: 1 ;;
  }

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
  # Added IFF to change name. Requested by Renae and Troy in May 2021. -Jack Goslin 6/16/21
  dimension: line_item_type_name {
    type: string
    sql: IFF(${line_item_types.name} = 'Damage Parts', 'Customer Damage Parts', ${line_item_types.name}) ;;
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
    drill_fields: [market_region_salesperson.Full_Name_with_ID, companies.name, invoices.invoice_link, retail_revenue]
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
    filters: [line_item_type_id: "2, 7, 21, 98, 99, 100, 101, 103"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, fuel_revenue]
  }

  # Add nonserialized revenue measure based on logic provided by Jason Jones to create ancilliary revenue grouping - 2023.02.13 BES
  measure: nonserialized_revenue {
    label: "Bulk Revenue"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "44"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, nonserialized_revenue]
  }

  # Add rpp revenue measure based on logic provided by Jason Jones to create ancilliary revenue grouping - 2023.02.13 BES
  measure: rpp_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "9"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_link, rpp_revenue]
  }

  # Add ancillary revenue measure based on logic provided by Jason Jones for visual drill through in revenue tile. - 2023.02.13 BES
  # Removed nonserialized from ancilliary and 'other' measure per Mark Wopata - 2023.02.16 BES
  measure: ancillary_revenue {
    description: "Combination of revenue from retail, parts, service, tools, fuel, and rpp line items"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "2, 7, 9, 11, 12, 13, 20, 21, 24, 25, 26, 28, 29, 49, 50, 80, 81, 98, 99, 100, 101, 110, 111"]
    drill_fields: [invoices.billing_approved_month, retail_revenue, parts_revenue, rpp_revenue, service_revenue, fuel_revenue, tools_revenue]
    link: {
      label: "Drill into Ancilliary Revenue"
      url: "
      {% assign vis_config = '{
      \"stacking\" : \"\",
      \"legend_position\" : \"right\",
      \"x_axis_gridlines\" : false,
      \"y_axis_gridlines\" : true,
      \"show_view_names\" : false,
      \"y_axis_combined\" : true,
      \"show_y_axis_labels\" : true,
      \"show_y_axis_ticks\" : true,
      \"y_axis_tick_density\" : \"default\",
      \"y_axis_scale_mode\" : \"linear\",
      \"show_x_axis_label\" : true,
      \"show_x_axis_ticks\" : true,
      \"show_null_points\" : true,
      \"interpolation\" : \"linear\",
      \"type\" : \"looker_column\",
      \"show_totals_labels\" : true,
      \"show_silhoutte\": false,
      \"totals_color\": \"#808080\",
      \"limit_displayed_rows\" : false,
      \"colors\": [
      \"#FFBF00\",
      \"#50CB78\",
      \"#C0C0C0\",
      \"#3EB0D5\",
      \"#808080\",
      \"#B32F37\"
      ],
      \"x_axis_label\" : \"Month Number\"
      }' %}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&f[invoices.billing_approved_month]={{gl_billing_approved_date_month._value }}&toggle=dat,pik,vis&limit=500&column_limit=15"
    }
  }

  # Add other revenue measure based on logic provided by Jason Jones for visual drill through in ancilliary revenue tile  - 2023.02.13 BES
  measure: other_revenue {
      description: "Combination of revenue from tools, fuel, and rpp line items"
      type: sum
      value_format_name: usd_0
      sql: ${amount};;
      filters: [line_item_type_id: "28, 2, 7, 21, 98, 99, 100, 101, 9, 103"]
      drill_fields: [invoices.billing_approved_month, rpp_revenue, fuel_revenue, tools_revenue]
      link: {
        label: "Drill into Other Revenue"
        url: "
        {% assign vis_config = '{
        \"stacking\" : \"\",
        \"legend_position\" : \"right\",
        \"x_axis_gridlines\" : false,
        \"y_axis_gridlines\" : true,
        \"show_view_names\" : false,
        \"y_axis_combined\" : true,
        \"show_y_axis_labels\" : true,
        \"show_y_axis_ticks\" : true,
        \"y_axis_tick_density\" : \"default\",
        \"y_axis_scale_mode\" : \"linear\",
        \"show_x_axis_label\" : true,
        \"show_x_axis_ticks\" : true,
        \"show_null_points\" : true,
        \"interpolation\" : \"linear\",
        \"type\" : \"looker_column\",
        \"limit_displayed_rows\" : false,
        \"show_totals_labels\" : true,
        \"show_silhoutte\": false,
        \"totals_color\": \"#808080\",
        \"colors\": [
        \"#808080\",
        \"#FFBF00\",
        \"#50CB78\",
        \"#353b49\",
        \"#49cec1\",
        \"#b3a0dd\"
        ],
        \"x_axis_label\" : \"Month Number\"
        }' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&f[invoices.billing_approved_month]={{gl_billing_approved_date_month._value }}&toggle=dat,pik,vis&limit=500&column_limit=15"
      }
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
    drill_fields: [market_region_xwalk.market_name, line_item_type_name, total_parts_extended_drill_month]
  }

  measure: parts_extended_revenue_new_drill {
    description: "Includes 9 line items identified by Renae that are important for her metrics. See LookML for type names. Duplicated for Parts Sales DB"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "49, 29, 12, 28, 25, 11, 16, 23, 22"]
    drill_fields: [market_region_xwalk.selected_hierarchy_dimension, line_item_type_name, total_parts_extended_drill_month]
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

  # for calculating revenue within certain time periods based on intervals specified
  dimension_group: period_ago {
    type: duration
    hidden: yes
    intervals: [day]
    sql_start: ${gl_billing_approved_date_raw};;
    sql_end: CURRENT_DATE() ;;
  }

  dimension: billing_approved_current_90 {
    type: yesno
    sql: ${days_period_ago} <= 90 ;;
  }

  dimension:  billing_approved_last_90 {
    type: yesno
    sql: ${days_period_ago} > 90 and ${days_period_ago} <= 180 ;;
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

  measure: total_rental_revenue_current_90 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [line_item_type_id: "6, 8, 108, 109", billing_approved_current_90: "Yes"]
  }

  measure: total_rental_revenue_last_90 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [line_item_type_id: "6, 8, 108, 109", billing_approved_last_90: "Yes"]
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

  dimension_group: gl_billing_approved_month {
    group_label: "Billing Approved Month Only"
    label: "Billing Approved"
    description: "This field is the billing approved date for invoice line items and the credit note date created for credit note line items."
    type: time
    timeframes: [
      month
    ]
    sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
    ##This field is used so other date durations cant be used during drill downs which won't break Market Dashboard Revenue Tiles drill downs
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
}
