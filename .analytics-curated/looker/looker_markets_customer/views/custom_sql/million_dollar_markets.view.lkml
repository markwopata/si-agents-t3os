
view: million_dollar_markets {
  derived_table: {
    sql: with market_rental_revenue1 as (
          select lines.BRANCH_ID,
                 date_trunc('month', lines.GL_BILLING_APPROVED_DATE)::DATE as month_beginning,
                 sum(lines.AMOUNT) as total
          from ANALYTICS.PUBLIC.V_LINE_ITEMS lines
          where lines.LINE_ITEM_TYPE_ID in (8,6,108,109) and lines.GL_DATE_CREATED > '2017-01-01'
          group by lines.BRANCH_ID, month_beginning
          having sum(lines.amount) > 1000000
      ),
      market_revenue_conditional_check1 as (
          select BRANCH_ID,
                 month_beginning,
                  conditional_true_event(total > 1000000) over (partition by BRANCH_ID order by month_beginning) as one_mil_hit
          from market_rental_revenue1
      ),
      market_rental_revenue2 as (
          select lines.BRANCH_ID,
                 date_trunc('month', lines.GL_BILLING_APPROVED_DATE)::DATE as month_beginning,
                 sum(lines.AMOUNT) as total
          from ANALYTICS.PUBLIC.V_LINE_ITEMS lines
          where lines.LINE_ITEM_TYPE_ID in (8,6,108,109) and lines.GL_DATE_CREATED > '2017-01-01'
          group by lines.BRANCH_ID, month_beginning
          having sum(lines.amount) > 2000000
      ),
      market_revenue_conditional_check2 as (
          select BRANCH_ID,
                 month_beginning,
                  conditional_true_event(total > 2000000) over (partition by BRANCH_ID order by month_beginning) as two_mil_hit
          from market_rental_revenue2
      ),
      market_rental_revenue3 as (
       select lines.BRANCH_ID,
                 date_trunc('month', lines.GL_BILLING_APPROVED_DATE)::DATE as month_beginning,
                 sum(lines.AMOUNT) as total
          from ANALYTICS.PUBLIC.V_LINE_ITEMS lines
          where lines.LINE_ITEM_TYPE_ID in (8,6,108,109) and lines.GL_DATE_CREATED > '2017-01-01'
          group by lines.BRANCH_ID, month_beginning
          having sum(lines.amount) > 3000000
      ),
      market_revenue_conditional_check3 as (
          select BRANCH_ID,
                 month_beginning,
                  conditional_true_event(total > 3000000) over (partition by BRANCH_ID order by month_beginning) as third_mil_hit
          from market_rental_revenue3
      ),
      market_first_mil_hit as (
          select BRANCH_ID,
                 month_beginning as month_hit_one_mil,
                 one_mil_hit
          from market_revenue_conditional_check1
          where one_mil_hit = 1
      ),
      market_second_mil_hit as(
          select BRANCH_ID,
                 month_beginning as month_hit_two_mil,
                 two_mil_hit
          from market_revenue_conditional_check2
          where two_mil_hit = 1
          ),
      market_third_mil_hit as (
          select BRANCH_ID,
                 month_beginning as month_hit_three_mil,
                 third_mil_hit
          from market_revenue_conditional_check3
          where third_mil_hit = 1
      )
      select cast(markets.MARKET_ID as string) as market_id,
             markets.MARKET_NAME,
             first.month_hit_one_mil,
             second.month_hit_two_mil,
             third.month_hit_three_mil
      from ANALYTICS.PUBLIC.MARKET_REGION_XWALK markets
      left join market_first_mil_hit first on first.BRANCH_ID = markets.MARKET_ID
      left join market_second_mil_hit second on second.BRANCH_ID = markets.MARKET_ID
      left join market_third_mil_hit third on third.BRANCH_ID = markets.MARKET_ID ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: month_hit_one_mil {
    label: "Market Surpasses One Million Threshold"
    type: date
    sql: ${TABLE}."MONTH_HIT_ONE_MIL" ;;
    html: {{ rendered_value | date: "%B %Y" }} ;;
  }

  dimension: month_hit_two_mil {
    label: "Market Surpasses Two Million Threshold"
    type: date
    sql: ${TABLE}."MONTH_HIT_TWO_MIL" ;;
    html: {{ rendered_value | date: "%B %Y" }} ;;
  }

  dimension: month_hit_three_mil {
    label: "Market Surpasses Three Million Threshold"
    type: date
    sql: ${TABLE}."MONTH_HIT_THREE_MIL" ;;
    html: {{ rendered_value | date: "%B %Y" }} ;;
  }

  set: detail {
    fields: [
        market_id,
  market_name,
  month_hit_one_mil,
  month_hit_two_mil,
  month_hit_three_mil
    ]
  }
}
