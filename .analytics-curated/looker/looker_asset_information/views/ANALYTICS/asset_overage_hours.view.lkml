view: asset_overage_hours {
  sql_table_name: "PUBLIC"."ASSET_OVERAGE_HOURS"
    ;;

  # dimension: daily_billed_amt {
  #   type: number
  #   sql: ${TABLE}."DAILY_BILLED_AMT" ;;
  # }

  # dimension: delivered_asset {
  #   type: number
  #   sql: ${TABLE}."delivered_asset" ;;
  # }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  # dimension: driver_final_hours_reading {
  #   type: number
  #   sql: ${TABLE}."DRIVER_FINAL_HOURS_READING" ;;
  # }

  # dimension: driver_total_hours_incurred {
  #   type: number
  #   sql: ${TABLE}."DRIVER_TOTAL_HOURS_INCURRED" ;;
  # }


  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }


  # dimension: hourly_billed_amt {
  #   type: number
  #   sql: ${TABLE}."HOURLY_BILLED_AMT" ;;
  # }

  # dimension: unapproved_invoice_amt {
  #   type: number
  #   sql: ${TABLE}."UNAPPROVED_INVOICE_AMT" ;;
  # }

  dimension_group: unapproved_invoice_end {
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
    sql: CAST(${TABLE}."INVOICE_END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: unapproved_invoice_id {
    type: number
    sql: ${TABLE}."UNAPPROVED_INVOICE_ID" ;;
  }

  dimension_group: unapproved_invoice_start {
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
    sql: CAST(${TABLE}."INVOICE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  # dimension: overage_days {
  #   type: number
  #   sql: ${TABLE}."OVERAGE_DAYS" ;;
  # }

  dimension: overage_hours {
    type: number
    sql: ${TABLE}."OVERAGE_HOURS" ;;
  }

  dimension: overage_ind {
    type: string
    sql: ${TABLE}."OVERAGE_IND" ;;
  }

  # dimension: overage_surcharge {
  #   type: number
  #   sql: ${TABLE}."OVERAGE_SURCHARGE" ;;
  # }

  # dimension: rate_achiev_asset {
  #   type: number
  #   sql: ${TABLE}."RATE_ACHIEV_ASSET" ;;
  # }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension_group: rental_end {
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
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  # dimension_group: true_rental_end {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: ${TABLE}."TRUE_RENTAL_END_DATE" ;;
  # }


  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension_group: rental_start {
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
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  # dimension_group: true_rental_start {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: ${TABLE}."TRUE_RENTAL_START_DATE" ;;
  # }

  dimension: return_asset {
    type: number
    sql: ${TABLE}."RETURN_ASSET" ;;
  }

  # dimension: return_asset_hours {
  #   type: number
  #   sql: ${TABLE}."RETURN_ASSET_HOURS" ;;
  # }

  # dimension: total_days_billed {
  #   type: number
  #   sql: ${TABLE}."TOTAL_DAYS_BILLED" ;;
  # }

  dimension: total_hours_billed {
    type: number
    sql: ${TABLE}."TOTAL_HOURS_BILLED" ;;
  }

  dimension: total_hours_incurred {
    type: number
    sql: ${TABLE}."TOTAL_HOURS_INCURRED" ;;
  }

  dimension: total_rental_days {
    type: number
    sql: ${TABLE}."TOTAL_RENTAL_DAYS" ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }

  dimension: order_id_with_link {
    type: string
    sql: ${order_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/orders/{{ asset_overage_hours.order_id._value }}/edit" target="_blank">{{ asset_overage_hours.order_id._value }}</a></font></u> ;;
  }

  dimension: invoice_id_with_link {
    type: string
    sql: ${unapproved_invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/invoices?query={{ asset_overage_hours.unapproved_invoice_id._value }}" target="_blank">{{ asset_overage_hours.unapproved_invoice_id._value }}</a></font></u> ;;
  }


  measure: count_invoices_link_to_overtime_hours {
    type: count
    filters: {
      field: overage_ind
      value: "charge_overage"}
    drill_fields: [unapproved_invoice_id]

    # link: {
    #   label: "View Overage Invoices"
    #   url: "https://equipmentshare.looker.com/looks/65?f[asset_overage_hours.market_name]={{ _filters['asset_overage_hours.market_name'] | url_encode }}&f[asset_overage_hours.region_name]={{_filters['asset_overage_hours.region_name']  | url_encode }}&f[asset_overage_hours.district]={{_filters['asset_overage_hours.district']  | url_encode }}&toggle=det"
    # }

  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: market_id_string {
    type: string
    sql: ${market_id}::text;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${district} in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  dimension: Salesperson_Region_Access_by_Market{
    type: yesno
    sql: ('salesperson' = ({{ _user_attributes['department'] }}) AND ${in_region} = ${region_name});;
  }

  dimension: in_region {
    type: string
    sql:
    (select ${region_name} from analytics.public.market_region_xwalk where ({{ _user_attributes['market_id'] }}) = ${market_id}) ;;
  }

  # dimension: city {
  #   type: string
  #   sql: SPLIT_PART(${market_name},',',1) ;;
  # }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
  }
}
