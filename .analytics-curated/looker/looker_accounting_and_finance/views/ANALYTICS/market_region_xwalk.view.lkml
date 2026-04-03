view: market_region_xwalk {
  sql_table_name: "PUBLIC"."MARKET_REGION_XWALK"
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
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: market_id_string {
    type: string
    sql: ${market_id}::text;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  dimension: Salesperson_Region_Access_by_Market{
    type: yesno
    sql: ('salesperson' = ({{ _user_attributes['department'] }}) AND ${in_region} = ${region_name});;
  }


  dimension: in_region {
    type: string
    sql:
    (select ${region_name} from analytics.market_region_xwalk where ({{ _user_attributes['market_id'] }}) = ${market_id}) ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }

  dimension: city {
    type: string
    sql: SPLIT_PART(${market_name},',',1) ;;
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

  dimension: location_type {
    type: string
    sql: case when ${market_name} like '%Pump & Power%' then 'Pump & Power'
          when ${market_name} like '%Industrial%' then 'Industrial'
          else 'Rental Yard'
          END;;
  }
}
