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

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT"::text ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
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
    suggest_persist_for: "1 minute"
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, market_name]
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

  dimension: selected_hierarchy_dimension {
    type: string
    link: {
      label: "Service Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/49?Market=&Region=&District=&Market%20Type="}
    sql:   {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
      {% elsif market_name._in_query %}
           ${market_name}
         {% elsif district._in_query %}
           ${market_name}
         {% elsif region_name._in_query %}
           ${district}
         {% else %}
           ${region_name}
         {% endif %};;
  }
}
