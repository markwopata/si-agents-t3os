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
      type: string
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

    measure: count {
      type: count
      drill_fields: [region_name, market_name]
    }

    dimension: city {
      type: string
      sql: SPLIT_PART(${market_name},',',1) ;;
    }

    dimension: district_text {
      type: string
      sql: ${TABLE}."DISTRICT" ::text ;;
    }

    dimension: region_district {
      type: string
      sql: ${TABLE}."REGION_DISTRICT"::text ;;
    }


    dimension: market_id_string {
      type: string
      sql: ${market_id}::text;;
    }

    dimension: District_Region_Market_Access {
      type: yesno
      sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id} in ({{ _user_attributes['market_id'] }}) ;;
    }

    measure: sales_rep_market_distinct_count {
      type: count_distinct
      sql: ${market_id} ;;
      description: "Used to toggle final market name on salesperson dashboard"
    }
  }
