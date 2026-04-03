view: ad_spend_long {
  derived_table: {
    sql:
          select WEEK_OF,
                 'LinkedIn' SOURCE,
                 linked_in AMOUNT
                from analytics.greenhouse.ad_spend
          union all
          select WEEK_OF,
                 'Indeed' SOURCE,
                 INDEED AMOUNT
                from analytics.greenhouse.ad_spend
          union all
          select WEEK_OF,
                 'Glassdoor' SOURCE,
                 GLASSDOOR AMOUNT
                from analytics.greenhouse.ad_spend
          union all

          select WEEK_OF,
                 SOURCE,
                  sum(amount) AMOUNT
          from (
                     select WEEK_OF,
                            'Other Online' SOURCE,
                            DRIBBLE amount
                     from analytics.greenhouse.ad_spend
              union all
                      select WEEK_OF,
                            'Other Online' SOURCE,
                            INSTAGRAM amount
                     from analytics.greenhouse.ad_spend
              union all
                      select WEEK_OF,
                            'Other Online' SOURCE,
                            STACK_OVERFLOW amount
                     from analytics.greenhouse.ad_spend
              union all
                      select WEEK_OF,
                            'Other Online' SOURCE,
                            FACEBOOK amount
                     from analytics.greenhouse.ad_spend
                 ) group by week_of, source

       ;;
  }

  dimension: compound_primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}."WEEK_OF", ' ', ${TABLE}."SOURCE") ;;
  }

  dimension_group: week_of {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}."WEEK_OF":: DATE ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: total_spend {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    #drill_fields: [source,amount]
  }

  measure: linkedin_spend {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [source: "LinkedIn"]
  }

  measure: glassdoor_spend {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [source: "Glassdoor"]
  }

  measure: indeed_spend {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [source: "Indeed"]
  }

  measure: other_spend {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [source: "Other Online"]
  }
}
