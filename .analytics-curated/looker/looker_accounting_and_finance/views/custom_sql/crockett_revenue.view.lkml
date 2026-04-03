view: crockett_revenue {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select c.NAME as company_name, PAYOUT_MONTH, round(sum(REVENUE),2) as month_to_date_revenue
from ANALYTICS.CONTRACTOR_PAYOUTS.FLEX_PAYOUT_OUTPUT fpo
left join ES_WAREHOUSE.PUBLIC.COMPANIES c
on fpo.COMPANY_ID = c.COMPANY_ID
where fpo.COMPANY_ID = 73584
and PAYOUT_MONTH > '2022-06-01'
group by PAYOUT_MONTH, c.NAME
      ;;
  }
#
#   # Define your dimensions and measures here, like this:
  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }
#
  dimension: PAYOUT_MONTH {
    type: date
    sql: ${TABLE}.PAYOUT_MONTH ;;
  }
#
  dimension: month_to_date_revenue {
    type: number
    sql: ${TABLE}.month_to_date_revenue ;;
  }
}
