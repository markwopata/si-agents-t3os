view: ideal_core_mix {
    sql_table_name: "ANALYTICS"."PUBLIC"."IDEAL_CORE_FLEET_VW" ;;


    dimension:  equipment_class_id {
      primary_key: yes
      type: number
      value_format: "0"
      sql:  ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension:  class {
      type: number
      sql:  ${TABLE}."CLASS" ;;
    }

    dimension:  asset_count {
      type: number
      value_format: "#,##0"
      sql:  ${TABLE}."ASSET_COUNT" ;;
    }

    dimension:  oec {
      type: number
      value_format: "$#,##0.00"
      sql:  ${TABLE}."OEC" ;;
    }

    dimension:  market_count {
      type: number
      value_format: "#,##0"
      sql:  ${TABLE}."MARKET_COUNT" ;;
    }

    dimension:  oec_percentage {
      type: number
      value_format: "0.00%"
      sql:  ${TABLE}."OEC_PERCENTAGE" ;;
    }

  }

