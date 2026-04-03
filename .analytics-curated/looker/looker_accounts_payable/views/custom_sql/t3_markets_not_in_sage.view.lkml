view: t3_markets_not_in_sage {
  derived_table: {
    sql: SELECT
          M.MARKET_ID,
          M.NAME,
          M.DATE_CREATED,
          M.DATE_UPDATED,
          D.DEPARTMENTID AS "INTACCT_ID"

      FROM "ES_WAREHOUSE"."PUBLIC"."MARKETS" M

      LEFT JOIN "ANALYTICS"."INTACCT"."DEPARTMENT" D

      ON CAST(M.MARKET_ID AS VARCHAR) = D.DEPARTMENTID

      WHERE M.COMPANY_ID = 1854

      AND M.ACTIVE = 'TRUE'

      AND D.DEPARTMENTID IS NULL

      AND M.MARKET_ID != '13481'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: intacct_id {
    type: string
    sql: ${TABLE}."INTACCT_ID" ;;
  }

  set: detail {
    fields: [market_id, name, date_created_time, date_updated_time, intacct_id]
  }
}
