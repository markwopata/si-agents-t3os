view: telematics_regions {
  sql_table_name: "ANALYTICS"."LOOKER_INPUTS"."TELEMATICS_REGIONS"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: telematics_region {
    type: number
    sql: ${TABLE}."TELEMATICS_REGION" ;;
  }

  dimension: telematics_region_name {
    type: string
    sql: ${TABLE}."TELEMATICS_REGION_NAME" ;;
  }

  parameter: region_breakdown_selection {
    type: string
    allowed_value: { value: "Telematics Regions"}
    allowed_value: { value: "ES Ops Regions"}
  }

  dimension: dynamic_region_selections {
    type: string
    label_from_parameter: region_breakdown_selection
    sql:
    {% if region_breakdown_selection._parameter_value == "'Telematics Regions'" %}
      ${telematics_region_name}
    {% elsif region_breakdown_selection._parameter_value == "'ES Ops Regions'" %}
      ${market_region_xwalk.region_name}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: count {
    type: count
    drill_fields: [telematics_region_name, market_name]
  }
}
