view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    alias: [district_text]
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_name_link {
    label: "Market Name w/ Links"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    link: {
      label: "Markets Dashboard"
      url: "https://equipmentshare.looker.com/dashboards-legacy/30?Market={{ filterable_value }}"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/180?Market+Name={{ filterable_value }}&toggle=det"
    }
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_name_number {
    type: string
    sql: concat(${region},' - ',${region_name}) ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }


}
