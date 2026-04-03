view: region_market_comparison_xwalk {
  sql_table_name: "GS"."REGION_MARKET_COMPARISON_XWALK"
    ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: mkt_link {
    type: string
    sql: ${TABLE}."MKT_LINK" ;;
    html: <font color="blue "><u><a href="{{value}}" target="_blank">Market Comparison Tool - {{ market_region_xwalk.region_name._value}}</a></font></u> ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_comparison_link {
    type: string
    sql: ${TABLE}."REGION_COMPARISON_LINK" ;;
    html: <font color="blue "><u><a href="{{value}}" target="_blank">Region Comparison Tool</a></font></u> ;;
  }

  dimension: sage_how_link {
    type: string
    sql: ${TABLE}."SAGE_HOW_LINK" ;;
    html: <font color="blue "><u><a href="{{value}}" target="_blank">How-To Access Sage P&L Details</a></font></u> ;;
  }

  dimension: region_name {
    type: string
    sql: ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
