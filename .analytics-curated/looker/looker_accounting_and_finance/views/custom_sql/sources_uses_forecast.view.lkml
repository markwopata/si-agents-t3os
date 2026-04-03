view: sources_uses_forecast {
  derived_table: {
    sql: select *
          from analytics.treasury.sources_uses_forecast
          where timestamp = (select max(timestamp) from analytics.treasury.sources_uses_forecast)
          --and date::Date <> '2023-06-12'
          ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.DATE ;;
  }

  dimension: sources_uses {
    type: string
    sql: ${TABLE}.SOURCEUSE ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: forecast_title {
    type: string
    sql: '1Q\'26 Forecast' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  dimension: filter_note {
    type: string
    sql: 'Treasury Cash Summary' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}.AMOUNT ;;
  }

  measure: amount_mm {
    type: sum
    value_format: "$#;($#);-"
    sql: case when ${TABLE}.AMOUNT = 0 then 0 else ${TABLE}.AMOUNT/1000000 end ;;
  }

  measure: abs_amount {
    type: sum
    sql: abs(${TABLE}.AMOUNT) ;;
  }

  }
