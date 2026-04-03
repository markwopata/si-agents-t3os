view: oes_export {
  derived_table: {
    sql:
      SELECT
        ASSET_ID AS PRODUCT,
        MAKE_AND_MODEL,
        SUB_RENTING_COMPANY,
        RENTAL_START_DATE AS START_DATE,
        SCHEDULED_OFF_RENT_DATE AS END_DATE
      FROM business_intelligence.triage.stg_t3__on_rent
      WHERE COMPANY_ID = 152078
      GROUP BY ALL
    ;;
    }

    dimension: product {
      type: string
      sql: ${TABLE}.PRODUCT ;;
    }

    dimension: make_and_model {
      type: string
      sql: ${TABLE}.MAKE_AND_MODEL ;;
    }

    dimension: sub_renting_company {
      type: string
      sql: ${TABLE}.SUB_RENTING_COMPANY ;;
    }

    dimension_group: start_date {
      #label: "Start Date"
      type: time
      #timeframes: [raw, date, week, month, quarter, year]
      sql: ${TABLE}.START_DATE ;;
    }

    dimension_group: end_date {
      #label: "End Date"
      type: time
      #timeframes: [raw, date, week, month, quarter, year]
      sql: ${TABLE}.END_DATE ;;
    }

    measure: count {
      type: count
      drill_fields: [product, make_and_model, sub_renting_company]
    }
  }
