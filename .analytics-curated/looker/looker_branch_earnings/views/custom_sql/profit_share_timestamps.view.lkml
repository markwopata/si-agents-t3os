view: profit_share_timestamps {
  derived_table: {
    sql: select distinct ps.QUARTER_TIMESTAMP
    from ANALYTICS.GS.PROFIT_SHARING_STATEMENTS ps

    union all

    select distinct fps.QUARTER_TIMESTAMP
    from ANALYTICS.GS.FULL_YEAR_PROFIT_SHARING_STATEMENTS fps ;;
  }

dimension: profit_share_period {
  label: "Profit Share Period"
  type: string
  sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
}
}
