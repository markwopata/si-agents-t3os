view: warranty_goal_2_percent_per_year {
 sql_table_name: ANALYTICS.WARRANTIES.WARRANTY_OEC_GOAL ;;

dimension: year {
  type: number
  value_format_name: id
  sql: ${TABLE}.year ;;
}

dimension: make  {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: year_oec {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.year_total ;;
}

measure: total_oec {
  type: sum
  value_format_name: usd_0
  sql: ${year_oec} ;;
}

  dimension: claim_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.goal ;;
  }

  measure: total_claim_goal {
    type: sum
    value_format_name: usd_0
    sql: ${claim_goal} ;;
  }

  dimension: weekly_claim_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.weekly_claim_goal ;;
  }

  measure: total_weekly_goal {
    type: sum
    value_format_name: usd_0
    sql: ${weekly_claim_goal} ;;
  }
}

view: weekly_claim_goal {
  derived_table: {
    sql: with generated_dates_2 as (
    SELECT dateadd(week, '-' || row_number() over (order by null), date_trunc(week, current_date())
        ) as generated_date
    FROM table(generator(rowcount => 1000))
)

, invoices as (
    select gd2.generated_date
        , aa.make
        , sum(total_amt) as claim_amount
    from generated_dates_2 gd2
    join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on date_trunc(week, wi.date_created) = gd2.generated_date
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wi.asset_id
    group by gd2.generated_date, aa.make
)

select gd2.generated_date
    , t.make
    , t.goal
    , weekly_claim_goal
    , claim_amount
from generated_dates_2 gd2
join ${warranty_goal_2_percent_per_year.SQL_TABLE_NAME} t
    on left(date_trunc(year, gd2.generated_date), 4) = t.year
left join invoices i
    on i.generated_date = gd2.generated_date
        and i.make = t.make ;;
  }

  dimension: report_week {
    type: date
    sql: ${TABLE}.generated_date ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: unique_key {
    primary_key: yes
    type: string
    sql: concat(${report_week}, ${make}) ;;
  }

  dimension: year_claim_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.goal ;;
  }

  measure: total_year_claim_goal {
    type: sum
    value_format_name: usd_0
    sql: ${year_claim_goal} ;;
  }

  dimension: claim_total {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claim_amount ;;
  }

  measure: total_claims {
    type: sum
    value_format_name: usd_0
    sql: ${claim_total} ;;
  }

  dimension: weekly_claim_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.weekly_claim_goal;;
  }

  measure: total_goal {
    type: sum
    value_format_name: usd_0
    sql: ${weekly_claim_goal} ;;
  }

  dimension: percent_to_goal {
    type: number
    value_format_name: percent_1
    sql: ${claim_total} / ${weekly_claim_goal};;
  }
}


view: monthly_claim_goal {
  derived_table: {
    sql: with generated_dates_2 as (
          SELECT dateadd(month, '-' || row_number() over (order by null), date_trunc(month, dateadd(month, 1, current_date()))
              ) as generated_date
          FROM table(generator(rowcount => 1000))
      )

      select gd2.generated_date
      , t.make
      , t.goal / 12 as monthly_claim_goal
      from generated_dates_2 gd2
      join ${warranty_goal_2_percent_per_year.SQL_TABLE_NAME} t
      on left(date_trunc(year, gd2.generated_date), 4) = t.year;;
  }

  dimension_group: report_month {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.generated_date AS TIMESTAMP_NTZ) ;;
}

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  # dimension: claim_total {
  #   type: number
  #   value_format_name: usd_0
  #   sql: ${TABLE}.claim_amount ;;
  # }

  # measure: total_claims {
  #   type: sum
  #   value_format_name: usd_0
  #   sql: ${claim_total} ;;
  # }

  dimension: monthly_claim_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.monthly_claim_goal;;
  }

  measure: total_goal {
    type: sum
    value_format_name: usd_0
    sql: ${monthly_claim_goal} ;;
  }

  # dimension: percent_to_goal {
  #   type: number
  #   value_format_name: percent_1
  #   sql: ${claim_total} / ${weekly_claim_goal};;
  # }
}
