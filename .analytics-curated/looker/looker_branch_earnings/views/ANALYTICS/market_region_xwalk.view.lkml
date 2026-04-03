view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: abbreviation {
    description: "Market abbreviation used for invoice numbering e.g. RIC21"
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: area_code {
    description: "Phone area code."
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    description: "District in the format of 2-7."
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.district
    suggest_persist_for: "4 hours"
  }

  dimension: region_district {
    description: "District in the format of 2-7. This is the same as district field, but kept for backwards compatibility."
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.district
    suggest_persist_for: "4 hours"
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
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.market_name
  }

  dimension: market_name_link {
    label: "Market Name w/ Links"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    link: {
      label: "Markets Dashboard"
      url: "@{db_market_dashboard}?Market={{ filterable_value }}"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?Market+Name={{ filterable_value }}&toggle=det"
    }
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.market_type
  }

  dimension: region {
    description: "Region number, e.g. 7."
    type: number
    sql: ${TABLE}."REGION" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.region
    suggest_persist_for: "24 hours"
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.region_name
    suggest_persist_for: "24 hours"
  }

  dimension: region_name_number {
    type: string
    sql: concat(${region},' - ',${region_name}) ;;
  }

  dimension: state {
    description: "Name of the state branch is located in e.g. Missouri."
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: market_type_id {
    type: number
    sql:${TABLE}."MARKET_TYPE_ID" ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: 'developer' = {{ _user_attributes['department'] }} or
          (
            (
              ${district} in ({{ _user_attributes['district'] }})
              OR ${region_name} in ({{ _user_attributes['region'] }})
              OR ${market_id} in ({{ _user_attributes['market_id'] }})
            )
            AND (
              ${market_type_id} not in (4,14)
              or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) in (
                'jabbok@equipmentshare.com'
              )
            )
          );;
  }

  dimension: District_Region_Market_Access_Materials {
    type: yesno
    sql: 'developer' = {{ _user_attributes['department'] }} or
          (
            (
              ${district} in ({{ _user_attributes['district'] }})
              OR ${region_name} in ({{ _user_attributes['region'] }})
              OR ${market_id} in ({{ _user_attributes['market_id'] }})
            ));;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}.division_name ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }
}
