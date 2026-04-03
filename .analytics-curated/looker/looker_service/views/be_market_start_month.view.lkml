view: be_market_start_month {
derived_table: {
  sql: select r.MARKET_ID
    , r.MARKET_START_MONTH
    , COALESCE(x.MARKET_NAME, r.MARKET_NAME) AS MARKET_NAME
    , r.BRANCH_EARNINGS_START_MONTH
  FROM ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE r
  LEFT OUTER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK x
    ON r.MARKET_ID = x.MARKET_ID
  WHERE r.MARKET_ID BETWEEN 0 AND 500000
    AND r.MARKET_ID != 15967 ;;
}

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: BRANCH_EARNINGS_START_MONTH {
    type: date
    sql: ${TABLE}.BRANCH_EARNINGS_START_MONTH ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${BRANCH_EARNINGS_START_MONTH}, current_date)+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }
}
