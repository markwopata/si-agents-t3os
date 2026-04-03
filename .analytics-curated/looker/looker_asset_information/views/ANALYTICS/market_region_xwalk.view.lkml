view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: region {
    group_label: "Region Number"
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    label: "Region"
    # suggest_persist_for: "1 minute"
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
    label: "Region - District Identifier"
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id}::text in ({{ _user_attributes['market_id'] }}) ;;
    suggest_persist_for: "1 minute"
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

  dimension: market_type {
    type: string
    sql: COALESCE(${TABLE}."MARKET_TYPE", 'No market type assigned') ;;
  }

  dimension: location_type {
    type: string
    # removed the CASE statement on this since the types are changing, but didn't want to completely remove it
    sql: ${market_type};;
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

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
