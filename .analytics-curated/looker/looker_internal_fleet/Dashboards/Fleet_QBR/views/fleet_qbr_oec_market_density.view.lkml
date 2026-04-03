view: fleet_qbr_oec_market_density {
  derived_table: {
    sql:
        Select
        market_id,
        market_name,
        market_status,
        market_type,
        region_id,
        region_name,
        district_id,
        district_name,
        usable_acres,
        oec_in_market,
        oec_per_acre
        from data_science_stage.fleet_testing.qbr_market_oec_density
          ;;
  }

  dimension: market_id {
    type: number
    primary_key: yes
    hidden: yes
    description: "market ID field, one market per row"
    sql:  ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type:  string
    description: "colloquial name of market"
    sql:${TABLE}."MARKET_NAME";;
  }

  dimension: market_type {
    type:  string
    description: "branch type (e.g. Core, Advanced...)"
    sql:${TABLE}."MARKET_TYPE";;
  }

  dimension: market_status {
    type:  string
    description: "current/open, etc."
    sql:${TABLE}."MARKET_STATUS";;
  }

  dimension: region_id {
    type:  number
    description: "region identifier"
    sql:${TABLE}."REGION_ID";;
  }

  dimension: region_name {
    type:  string
    description: "colloquial name of region"
    sql:${TABLE}."REGION_NAME";;
  }

  dimension: district_id {
    type:  number
    description: "district identifier"
    sql:${TABLE}."DISTRICT_ID";;
  }

  dimension: district_name {
    type:  string
    description: "colloquial name of district"
    sql:${TABLE}."DISTRICT_NAME";;
  }

  dimension: usable_acreage {
    type:  number
    description: "recorded acreage available for storing assets off-rent"
    value_format: "###.##"
    sql:  ${TABLE}."USABLE_ACRES" ;;
  }

  dimension: oec_in_market {
    type:  number
    description: "total value of OEC currently recorded in the market"
    value_format: "$#,###"
    sql:  ${TABLE}."OEC_IN_MARKET" ;;
  }

  dimension: oec_per_acre {
    type:  number
    description: "oec_in_market/usable_acreage"
    value_format: "$#,###"
    sql:  ${TABLE}."OEC_PER_ACRE" ;;
  }


}
