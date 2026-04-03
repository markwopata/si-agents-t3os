view: market_region_xwalk {
  sql_table_name: analytics.public.market_region_xwalk;;

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
    suggest_persist_for: "1 minute"
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

  dimension: hard_down {
    type: yesno
    sql: case when right(${market_name}, 9) = 'Hard Down' then true else false end ;;
  }

  dimension: special_locations_tf {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' OR
        ${market_name} ILIKE '%Mobile Tool Trailer%' OR
        ${market_name} ILIKE '%Onsite Yard%' OR
        ${market_name} ILIKE '%Containers%' then true else false end ;;
  }

  dimension: special_locations_type {
    type: string
    sql: CASE WHEN ${market_name} ILIKE '%Landmark%' THEN 'Landmark'
        when ${market_name} ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN ${market_name} ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN ${market_name} ILIKE '%Containers%' then 'Container' ELSE ${market_type} END ;;
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

  dimension: selected_hierarchy_dimension {
    type: string
    link: {
      label: "Purchase Orders Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/525?Vendor+ID=&Po+Date=not+null&Part+Number=&Deliver+to+Branch=&Requesting+Branch=&Name=&Created+By=&Price+per+Unit=&Po+Number=&Po+Status=&Item+Name=&Amount="}
    sql: {% if drop_down_selection._parameter_value == "'Region'" %}
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

  dimension: region_district_clean {
    type: string
    sql: concat(${region},'-',${district})::TEXT ;;
  }

  measure: count_of_markets {
    type: count_distinct
    sql: ${market_id} ;;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
  }

  dimension: market_start_month {
    type: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }

  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
  }


  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }
}
