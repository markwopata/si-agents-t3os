view: quarterly_company_market_assignments {
  derived_table: {
    sql:

      select *
      from analytics.bi_ops.quarterly_company_market_assignments
      WHERE quarter = date_trunc('quarter', current_date);;
  }


  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: company {
    type: number
    sql: ${TABLE}.company ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }


  dimension: company_market_assignment {
    type: string
    sql: ${TABLE}.market ;;
  }


}
