view: gross_profit_pct_payout {
  derived_table: {
    sql:
SELECT
    0.55 AS min_profit,
    NULL AS max_profit,
    0.0015 AS payout_percentage
UNION ALL
SELECT
    0.525 AS min_profit,
    0.55 AS max_profit,
    0.0013 AS payout_percentage
UNION ALL
SELECT
    0.50 AS min_profit,
    0.525 AS max_profit,
    0.0012 AS payout_percentage
UNION ALL
SELECT
    0.475 AS min_profit,
    0.50 AS max_profit,
    0.0009 AS payout_percentage
UNION ALL
SELECT
    0.45 AS min_profit,
    0.475 AS max_profit,
    0.0007 AS payout_percentage
UNION ALL
SELECT
    0.425 AS min_profit,
    0.45 AS max_profit,
    0.0004 AS payout_percentage
UNION ALL
SELECT
    0.40 AS min_profit,
    0.425 AS max_profit,
    0.0003 AS payout_percentage
UNION ALL
SELECT
    0.375 AS min_profit,
    0.40 AS max_profit,
    0.0002 AS payout_percentage
UNION ALL
SELECT
    NULL AS min_profit,
    0.375 AS max_profit,
    0.0001 AS payout_percentage
    ;;
    }



  dimension: min_profit {
    type: number
    sql: ${TABLE}."MIN_PROFIT" ;;
  }

  dimension: max_profit {
    type: number
    sql: ${TABLE}."MAX_PROFIT" ;;
  }

  dimension: payout_percentage {
    type: number
    sql: ${TABLE}."PAYOUT_PERCENTAGE" ;;
  }


  measure: min_profit_m {
    type: number
    sql: ${TABLE}."MIN_PROFIT" ;;
  }

  measure: max_profit_m {
    type: number
    sql: ${TABLE}."MAX_PROFIT" ;;
  }

  measure: payout_percentage_m {
    type: number
    sql: ${TABLE}."PAYOUT_PERCENTAGE" ;;
  }



}
