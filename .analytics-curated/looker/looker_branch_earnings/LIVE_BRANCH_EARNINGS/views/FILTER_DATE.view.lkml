view: FILTER_DATE {
  derived_table: {
    sql:
      SELECT  z.PERIOD
              , z.YEAR_MONTH

      FROM    (
                  SELECT  x.PERIOD
                          , x.YEAR_MONTH
                          , ROW_NUMBER() OVER (ORDER BY x.YEAR_MONTH) AS RowNbr

                  FROM    (
                              SELECT  DISTINCT
                                      d.PERIOD
                                      , d.YEAR_MONTH

                              FROM    ANALYTICS.BRANCH_EARNINGS.DIM_DATE_LIVE_BE d

                              WHERE   d.HAS_DATA = 'Yes'
                          ) x
              ) z

      WHERE   z.RowNbr >= 1
    ;;
  }

  dimension: FILTER_PERIOD {
    type: string
    suggest_persist_for: "30 minutes"
    order_by_field: FILTER_YEAR_MONTH
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: FILTER_YEAR_MONTH {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."YEAR_MONTH" ;;
  }
}
