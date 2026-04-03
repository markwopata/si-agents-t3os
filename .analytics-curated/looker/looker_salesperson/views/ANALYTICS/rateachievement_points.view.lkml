view: rateachievement_points {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_POINTS"
    ;;

  dimension: invoice_rental_id {
    primary_key: yes
    type: string
    sql: CONCAT(${invoice_id},'-',${rental_id}) ;;
    value_format_name: id
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
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

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: new_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

#  dimension: billing_approved_date {
#    type: date
#    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
#  }

  dimension_group: billing_approved {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: invoice_date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE_CREATED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: order_date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORDER_DATE_CREATED" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id

    link: {
      label: "View Company Invoices"
      url: "https://equipmentshare.looker.com/looks/22?f[users.Full_Name_with_ID]={{ _filters['users.Full_Name_with_ID'] | url_encode }}&f[rateachievement_points.company_id]={{ value | url_encode }}&f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}&f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}&f[market_region_xwalk.district]={{_filters['market_region_xwalk.district']  | url_encode }}&toggle=det"
    }
  }

  dimension: company_name {
    type: string
    sql: REPLACE(TRIM(${TABLE}."COMPANY_NAME"),CHAR(9), '') ;;

    link: {
      label: "View Company Invoices"
      url: "https://equipmentshare.looker.com/looks/22?f[users.Full_Name_with_ID]={{ _filters['users.Full_Name_with_ID'] | url_encode }}&f[rateachievement_points.company_name]={{ company_name._filterable_value | url_encode }}&f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}&f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}&f[market_region_xwalk.district]={{_filters['market_region_xwalk.district']  | url_encode }}&toggle=det"
    }

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: salesperson_name_with_link_to_invoices{
    type: string
    sql: ${TABLE}."SALESPERSON" ;;

    link: {
      label: "View Salesperon Invoices"
      url: "https://equipmentshare.looker.com/looks/22?f[rateachievement_points.salesperson]={{ salesperson._filterable_value | url_encode }}&f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}&f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}&f[market_region_xwalk.district]={{_filters['market_region_xwalk.district']  | url_encode }}&toggle=det"
    }
  }

  dimension: daily_billing_flag {
    type: yesno
    sql: ${TABLE}."DAILY_BILLING_FLAG" ;;
  }

  dimension: actual_rate {
    type: number
    sql: ${TABLE}."ACTUAL_RATE" ;;
  }

  dimension: online_rate {
    type: number
    sql: ${TABLE}."ONLINE_RATE" ;;
  }

  dimension: benchmark_rate {
    type: number
    sql: ${TABLE}."BENCHMARK_RATE" ;;
  }

  dimension: floor_rate {
    type: number
    sql: ${TABLE}."FLOOR_RATE" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  measure: discount_gauge {
    type: average
    sql: ${percent_discount}*100 ;;
  }

  dimension: rate_tier {
    type: number
    sql: ${TABLE}."RATE_TIER" ;;
  }


  dimension: revenue_below_floor {
    type: number
    sql: ${floor_rate} - ${amount} ;;
    value_format_name: usd
  }


  # Made these for conditionally coloring a discount % bar chart. Copy and reuse if you want to change the threshold values. -Jack G. 10/28/21
  # Thresholds set by Nick Guthrie on 10/28/21
  measure: discount_chart_green {
    type: number
    value_format_name: percent_1
    sql: IFF(${avg_percent_discount} <= 0.24, ${avg_percent_discount}, null) ;;
  }
  measure: discount_chart_yellow {
    type: number
    value_format_name: percent_1
    sql: IFF(${avg_percent_discount} > 0.24 and ${avg_percent_discount} <= 0.28, ${avg_percent_discount}, null) ;;
  }
  measure: discount_chart_orange {
    type: number
    value_format_name: percent_1
    sql: IFF(${avg_percent_discount} > 0.28 and ${avg_percent_discount} <= 0.32, ${avg_percent_discount}, null) ;;
  }
  measure: discount_chart_red {
    type: number
    value_format_name: percent_1
    sql: IFF(${avg_percent_discount} > 0.32, ${avg_percent_discount}, null) ;;
  }

  measure: weighted_percentage_discount_guage {
    type: number
    sql: case when sum(${online_rate}) != 0 and sum(${percent_discount}) is not null then (sum(${percent_discount}*${online_rate})/sum(${online_rate}))*100
         else null end;;
  }

  measure: weighted_percentage_discount {
    type: number
    sql: case when sum(${online_rate}) != 0 and sum(${percent_discount}) is not null then (sum(${percent_discount}*${online_rate})/sum(${online_rate}))
         else 1 end;;
    value_format: "0.0%"
  }

  measure: weighted_percentage_discount_formatted {
    type: number
    sql: ${weighted_percentage_discount} ;;
    html: {% if weighted_percentage_discount._value < 0.1599 %}

      <span style="color: goldenrod;"> {{weighted_percentage_discount._rendered_value }} </span>

      {% elsif weighted_percentage_discount._value >= 0.16 and weighted_percentage_discount._value <= 0.3099 %}

      <span style="color: #ee7772;"> {{weighted_percentage_discount._rendered_value }} </span>

      {% elsif weighted_percentage_discount._value <= 0.3099 %}

      <span style="color: #ee7772;"> {{weighted_percentage_discount._rendered_value }} </span>

      {% else %}

      <span style="color: #b02a3e;"> {{weighted_percentage_discount._rendered_value }} </span>

      {% endif %};;
  }

  measure: avg_percent_discount {
    type: average
    sql: ${percent_discount} ;;
    value_format: "0.00%"
  }

  measure: total_inv_amt {
    type: sum
    sql: ${amount} ;;
    #sql: ${amount};;
    value_format_name:  usd_0
  }

  measure: total_amt {
    type: sum
    sql: ${amount};;
    value_format_name:  usd_0
  }


  measure: total_points {
    type: sum
    sql: ${amount} - ${benchmark_rate} ;;
    value_format_name: usd_0
  }

  measure: total_discount {
    type: sum
    sql: ${online_rate} - ${amount};;
    value_format_name:  usd_0
  }

  measure: total_discount_with_drills {
    type: sum
    sql: ${online_rate} - ${amount};;
    value_format_name:  usd_0
    drill_fields: [discount_by_customer*]
  }

  measure: total_online_amount {
    type: sum
    sql: ${online_rate} ;;
    value_format_name:  usd_0
  }

  measure: count {
    type: count
    drill_fields: [invoice_id,invoice_date_created_date,company_name,equipment_class,total_points]
  }

  measure: count_of_invoices {
    label: "Number of Invoices"
    type: count_distinct
    sql: ${invoice_id} ;;
    drill_fields: [invoice_id_with_link,asset_id,invoice_date_created_date,company_name,equipment_class,total_discount]
    }

  measure: count_of_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [invoice_id,asset_id,invoice_date_created_date,company_name,equipment_class,total_points]
  }

  dimension: invoice_id_with_link {
    type: string
    sql: ${invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/invoices/{{ rateachievement_points.invoice_id._value }}" target="_blank">{{ rateachievement_points.invoice_id._value }}</a></font></u> ;;
  }

  dimension: company_name_trim {
    type: string
    sql: TRIM(${company_name}) ;;
  }

  dimension: month_date_created {
    type: date
    sql: date_trunc('month',${invoice_date_created_date}) ;;
  }


 set: discount_by_customer {
   fields: [
    company_name,
    companies_revenue_last_30_days.total_rev,
    count_of_invoices,
    avg_percent_discount,
    total_discount
    ]
 }
}
