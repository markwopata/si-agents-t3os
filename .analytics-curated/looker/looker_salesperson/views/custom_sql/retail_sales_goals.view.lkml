view: retail_sales_goals {
    sql_table_name: ANALYTICS.BI_OPS.RAM_GOALS ;;

    dimension: goal_id {
      type: string
      primary_key: yes
      sql: ${TABLE}.GOAL_ID ;;
    }

    dimension: user_id {
      type: number
      sql: ${TABLE}.USER_ID ;;
    }

    dimension: year {
      type: number
      sql: ${TABLE}.YEAR ;;
    }

    dimension: month {
      type: number
      sql: ${TABLE}.MONTH ;;
    }

    dimension: created_by_email {
      type: string
      sql: ${TABLE}.CREATED_BY_EMAIL ;;
    }

    dimension: date_created {
      type: date
      sql: ${TABLE}.DATE_CREATED ;;
    }

    measure: new_rev_goal {
      type: sum
      value_format_name: usd_0
      sql: ${TABLE}.NEW_REV_GOAL ;;
    }

    measure: used_rev_goal {
      type: sum
      value_format_name: usd_0
      sql: ${TABLE}.USED_REV_GOAL ;;
    }

    measure: rpo_rev_goal {
      type: sum
      value_format_name: usd_0
      sql: ${TABLE}.RPO_REV_GOAL ;;
    }

    measure: new_quotes_goal {
      type: sum
      sql: ${TABLE}.NEW_QUOTES_GOAL ;;
    }

    measure: used_quotes_goal {
      type: sum
      sql: ${TABLE}.USED_QUOTES_GOAL ;;
    }

    measure: rpo_quotes_goal {
      type: sum
      sql: ${TABLE}.RPO_QUOTES_GOAL ;;
    }

    measure: pct_deals_won_goal {
      type: average
      sql: ${TABLE}.PCT_DEALS_WON_GOAL ;;
    }

    dimension_group: goal_month {
      type: time
      timeframes: [month]
      sql: DATE_FROM_PARTS(${year}, ${month}, 1) ;;
    }
  }
