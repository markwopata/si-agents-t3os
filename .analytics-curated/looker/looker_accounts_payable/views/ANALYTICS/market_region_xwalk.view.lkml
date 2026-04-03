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
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
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

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }


  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${district} in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  dimension: dynamic_location {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: region_district_clean {
    type: string
    sql: concat(${region},'-',${district})::TEXT ;;
  }

  measure: count_of_markets {
    type: count_distinct
    sql: ${market_id} ;;
  }


  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }
}
