include: "/_base/analytics/public/market_region_xwalk.view.lkml"

view: +market_region_xwalk {
  label: "Market Region Xwalk"

  dimension: _id_dist {
    value_format_name: id
  }

  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [raw,date, week, month, quarter, year]
    sql: ${branch_earnings_start} ;;
  }

  # dimension: abbreviation {
  #   type: string
  #   sql: ${TABLE}."ABBREVIATION" ;;
  # }
  # dimension: area_code {
  #   type: string
  #   sql: ${TABLE}."AREA_CODE" ;;
  # }
  dimension_group: date_updated {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${date_updated} ;;
  }
  # dimension: district {
  #   type: string
  #   sql: ${TABLE}."DISTRICT" ;;
  # }
  # dimension: is_dealership {
  #   type: yesno
  #   sql: ${TABLE}."IS_DEALERSHIP" ;;
  # }
  dimension: market_id {
    value_format_name:id
  }
  # dimension: market_name {
  #   type: string
  #   sql: ${TABLE}."MARKET_NAME" ;;
  # }
  # dimension: market_type {
  #   type: string
  #   sql: ${TABLE}."MARKET_TYPE" ;;
  # }
  dimension: market_type_id {
    value_format_name: id
  }
  # dimension: region {
  #   type: number
  #   sql: ${TABLE}."REGION" ;;
  # }
  # dimension: region_district {
  #   type: string
  #   sql: ${TABLE}."REGION_DISTRICT" ;;
  # }
  # dimension: region_name {
  #   type: string
  #   sql: ${TABLE}."REGION_NAME" ;;
  # }
  # dimension: state {
  #   type: string
  #   sql: ${TABLE}."STATE" ;;
  # }
  dimension: city {
    type: string
    sql: SPLIT_PART(${market_name},',',1) ;;
  }
  dimension: district_text {
    type: string
    sql: ${district}::text ;;
  }
  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }
  dimension: district_extend {
    label: "District Extend"
    description: "Coalesces the District field and Corporate"
    type: string
    sql:  COALESCE(${district}, 'Corporate') ;;
  }
  dimension: region_extend {
    label: "Region Extend"
    description: "Coalesces the Region field and Corporate"
    type: string
    sql:  COALESCE(${region_name}, 'Corporate') ;;
  }
  # measure: count {
  #   type: count
  #   drill_fields: [market_name, region_name]
  # }
}
