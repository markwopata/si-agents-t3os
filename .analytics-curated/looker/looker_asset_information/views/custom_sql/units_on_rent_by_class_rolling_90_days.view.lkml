view: units_on_rent_by_class_rolling_90_days {
  sql_table_name: "PUBLIC"."UNITS_ON_RENT_BY_CLASS_ROLLING_90_DAYS"
    ;;

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: rental_day {
      type: date
      sql: ${TABLE}."DTE" ;;
    }

  # dimension: rank {
  #   type: number
  #   sql: ${TABLE}."RN" ;;
  # }

    # dimension: equipment_class_id {
    #   type: number
    #   sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    #   ###primary_key: yes
    # }

    dimension: equipment_class {
      type: string
      sql: ${TABLE}."CLASS" ;;
    }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: equipment_market {
    type: string
    sql: concat(${equipment_class},' ',${market_id}) ;;
    primary_key: yes
  }

    dimension: units_on_rent {
      type: number
      sql: ${TABLE}."UNITS_ON_RENT" ;;
    }

    dimension: oec_on_rent {
      type: number
      sql: ${TABLE}."OEC_ON_RENT" ;;
    }

    # dimension: last_updated {
    #   type: date
    #   sql: ${TABLE}."LAST_UPDATED" ;;
    # }

    measure: Unit_Total {
      type:  sum
      sql: ${units_on_rent} ;;
    }

  dimension: is_top_20_class {
    type: yesno
    sql:
    exists(
      select *
      from (
        select ${TABLE}."CLASS" as class
        from units_on_rent_by_class_rolling_90_days
        group by ${TABLE}."CLASS"
        order by sum(${units_on_rent}) desc
        limit 20
      ) top_20
      where ${TABLE}."CLASS"  = top_20.class
    ) ;;
  }

  dimension: is_top_20_category {
    type: yesno
    sql:
    exists(
      select *
      from (
        select ${TABLE}."CATEGORY" as category
        from units_on_rent_by_class_rolling_90_days
        group by ${TABLE}."CATEGORY"
        order by sum(${units_on_rent}) desc
        limit 20
      ) top_20
      where ${TABLE}."CATEGORY"  = top_20.category
    ) ;;
  }

  measure: rank_dynamic {
    type: number
    sql: ROW_NUMBER() OVER ( ORDER BY sum(${TABLE}."UNITS_ON_RENT") DESC) END  ;;
  }

    measure: OEC_Total {
      type:  sum
      sql: ${oec_on_rent} ;;
      value_format:"0.0,,\" M\""
    }

    set: detail {
      fields: [rental_day, equipment_class,equipment_category, units_on_rent, oec_on_rent]
    }

  }
