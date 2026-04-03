view: floor_rates_by_district {
  derived_table: {
    sql:
        select EQUIPMENT_CLASS_ID, rr.DISTRICT, mode(brr.PRICE_PER_MONTH) as floor_rate
        from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr
                 join RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
        where RATE_TYPE_ID = 3
          and ACTIVE
        group by 1, 2
    ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: floor_rate {
    type: number
    sql: ${TABLE}."FLOOR_RATE" ;;
  }
  }
